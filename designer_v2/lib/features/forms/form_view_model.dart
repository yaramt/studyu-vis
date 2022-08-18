import 'dart:async';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';

enum FormMode {
  create,
  readonly,
  edit,
}

class FormInvalidException implements Exception {}
class FormConfigException implements Exception {
  FormConfigException([this.message]);
  final String? message;
}

abstract class IFormViewModelDelegate<T extends FormViewModel> {
  void onSave(T formViewModel, FormMode prevFormMode);
  void onCancel(T formViewModel, FormMode prevFormMode);
}

class FormControlOption<T> {
  final T value;
  final String label;
  final String? description;

  FormControlOption(this.value, this.label, {this.description});
}

typedef FormControlUpdateCallback = void Function(AbstractControl control);

abstract class FormViewModel<T> {
  FormViewModel({
    formData,
    this.delegate,
    validationSet,
    this.autosave = false,
  }) :  _validationSet = validationSet,
        _formData = formData,
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    _setControlValidators(validationSet);
    _restoreControlsFromFormData();
    _formModeUpdated();

    if (autosave) {
      // Push to event queue to avoid listening to update events
      // triggered synchronously during initialization
      Future.delayed(const Duration(milliseconds: 0), enableAutosave);
    }
  }

  T? get formData => _formData;
  set formData(T? formData) => _setFormData(formData);
  T? _formData;

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _formModeUpdated();
  }
  FormMode _formMode;

  bool get isReadonly => formMode == FormMode.readonly;

  /// Enum that determines which [FormValidationConfig] should be selected
  /// from the [validationConfig] and applied to the [form].
  ///
  /// If null, the [AbstractControl]s contained in the [form] will be validated
  /// using their default configuration. Otherwise, the default configuration
  /// is discarded & replaced by the respective [FormValidationConfig].
  FormValidationSetEnum? get validationSet => _validationSet;
  FormValidationSetEnum? _validationSet;
  set validationSet(FormValidationSetEnum? validationSet) {
    _validationSet = validationSet;
    _setControlValidators(validationSet);
  }

  final IFormViewModelDelegate<FormViewModel<dynamic>>? delegate;

  final bool autosave;

  final List<StreamSubscription> _immediateFormChildrenSubscriptions = [];
  Debouncer? _immediateFormChildrenListenerDebouncer;

  /// Flag indicating whether the form is currently being autosaved
  ///
  /// Needed to prevent an infinite loop when updating the form & its controls
  /// when saving
  bool _isAutosaving = false;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> _defaultControlStates = {};

  _setFormData(T? formData) {
    _formData = formData;
    if (formData != null) {
      setControlsFrom(formData); // update [form] controls automatically
      form.updateValueAndValidity();
    }
  }

  _saveControlStates() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      _defaultControlStates[controlName] = control.enabled;
    }
  }

  _disableAllControls() {
    for (final control in form.controls.values) {
      control.markAsDisabled();
    }
    assert(form.allControlsDisabled());
  }

  _restoreControlStates() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      final isEnabledByDefault = _defaultControlStates[controlName] ?? true;
      if (isEnabledByDefault) {
        control.markAsEnabled();
      } else {
        control.markAsDisabled();
      }
    }
  }

  _formModeUpdated() {
    switch (formMode) {
      case FormMode.readonly:
        _saveControlStates();
        _disableAllControls();
        break;
      case FormMode.create:
      case FormMode.edit:
        _restoreControlStates();
        break;
    }
  }

  _restoreControlsFromFormData() {
    if (formData != null) {
      setControlsFrom(formData!);
    } else {
      initControls();
    }
    form.updateValueAndValidity();
  }

  void _setControlValidators(FormValidationSetEnum? validationSet) {
    if (validationSet == null) {
      return; // retain default form validators
    }
    final formValidationConfig = validationConfig[validationSet];
    if (formValidationConfig == null) {
      throw FormConfigException(
          "Failed to lookup FormValidationConfig for key: $validationSet");
    }

    // Build index control => config
    final Map<AbstractControl, FormControlValidation> controlConfigs = {};
    for (final controlValidationConfig in formValidationConfig) {
      final existingConfig = controlConfigs[controlValidationConfig.control];
      final mergedConfig = controlValidationConfig.merge(existingConfig);
      controlConfigs[controlValidationConfig.control] = mergedConfig;
    }

    // Apply control-specific config (if any) for each control in the form
    for (final control in form.controls.values) {
      if (!controlConfigs.containsKey(control)) {
        continue;
      }
      // Update control
      final controlValidationConfig = controlConfigs[control]!;
      control.setValidators(controlValidationConfig.validators);
      if (controlValidationConfig.asyncValidators != null) {
        control.setAsyncValidators(controlValidationConfig.asyncValidators!);
      }
      control.validationMessages = controlValidationConfig.validationMessages;
    }

    form.updateValueAndValidity();
  }

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  void read([T? formData]) {
    if (formData != null) {
      this.formData = formData;
    }
    formMode = FormMode.readonly;
  }

  Future save() {
    if (!form.valid) {
      throw FormInvalidException();
    }

    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;
    formData = buildFormData();
    delegate?.onSave(this, prevFormMode);

    // Put form into edit mode with saved data
    if (prevFormMode == FormMode.create) {
      formMode = FormMode.edit;
    }

    return Future.value(true);
  }

  Future<void> cancel() {
    if (formMode != FormMode.readonly) {
      _restoreControlsFromFormData();
    }
    delegate?.onCancel(this, formMode);

    return Future.value(null);
  }

  void enableAutosave({int debounce = Config.formAutosaveDebounce}) {
    if (_immediateFormChildrenSubscriptions.isNotEmpty) {
      return;
    }
    listenToImmediateFormChildren((control) {
      // Prevent infinite loop from the update that is emitted during save
      // which would retrigger the listener
      if (_isAutosaving) {
        return;
      }
      if (form.valid) {
        _isAutosaving = true;
        save().then((_) => _isAutosaving = false);
      }
    }, debounce: debounce);
  }

  void listenToImmediateFormChildren(FormControlUpdateCallback callback,
      {int debounce = 1500}) {
    // Initialize debounce helper if needed
    if (debounce != 0) {
      _immediateFormChildrenListenerDebouncer ??= Debouncer(milliseconds: debounce);
    }

    for (final control in form.controls.values) {
      void boundListener(event) {
        if (debounce == 0) {
          callback(control);
        } else {
          _immediateFormChildrenListenerDebouncer!(() => callback(control));
        }
      }

      if (control is FormGroup) {
        continue; // don't listen to nested descendants
      }  else if (control is FormArray) {
        final collectionChanges = control.collectionChanges.listen(boundListener);
        // don't subscribe to control.valueChanges
        _immediateFormChildrenSubscriptions.add(collectionChanges);
      } else if (control is FormControl) {
        final valueChanges = control.valueChanges.listen(boundListener);
        _immediateFormChildrenSubscriptions.add(valueChanges);
      }
    }
  }

  void dispose() {
    _immediateFormChildrenListenerDebouncer?.dispose();
    for (final subscription in _immediateFormChildrenSubscriptions) {
      subscription.cancel();
    }
  }

  // - Subclass responsibility

  FormGroup get form;
  Map<FormMode, String> get titles;

  /// The available set of validation configurations for the [form] managed
  /// by this view model.
  ///
  /// One of the [FormValidationConfig]s is chosen at runtime based on the
  /// current [validationSet] and applied to the [form].
  FormValidationConfigSet get validationConfig => {};

  /// Initialize the values of all [FormControl]s in the [form]
  void setControlsFrom(T data);
  T buildFormData();

  void initControls() {
    // subclass responsibility (optional)
  }
}
