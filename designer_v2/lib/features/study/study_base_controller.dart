import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

part 'study_base_controller.g.dart';

@riverpod
class StudyBaseController<T extends StudyControllerBaseState> extends _$StudyBaseController {
  @override
  StudyControllerBaseState build(StudyID studyId) {
    subscribeStudy(studyId);
    return StudyControllerBaseState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
    );
  }

  StreamSubscription<WrappedModel<Study>>? _studySubscription;

  subscribeStudy(StudyID studyId) {
    if (_studySubscription != null) {
      _studySubscription!.cancel();
    }
    _studySubscription =
        state.studyRepository.watch(studyId).listen(onStudySubscriptionUpdate, onError: onStudySubscriptionError);
  }

  onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    state = state.copyWith(studyWithMetadata: wrappedModel) as T;
  }

  onStudySubscriptionError(Object error) {
    // TODO: improve error handling
    if (error is StudyNotFoundException) {
      /* TODO: figure out a way to resolve data dependencies for the current page
           during app initialization so that we don't need to render the loading state
           if the study doesn't exist
      */
      state.router.dispatch(RoutingIntents.error(error));
    }
  }
}
