import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, Key? key}) : super(key: key);

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final DashboardController controller;
  late final DashboardState state;
  late final Future<Preferences> preferences;
  final searchController = TextEditingController();
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    controller = ref.read(dashboardControllerProvider.notifier);
    state = ref.read(dashboardControllerProvider);
    runAsync(() => controller.setStudiesFilter(widget.filter));
    searchController.addListener(searchListener);
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      runAsync(() => controller.setStudiesFilter(widget.filter));
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(searchListener);
  }

  void searchListener() {
    setState(() {
      searchQuery = controller.search(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);
    final userRepo = ref.watch(userRepositoryProvider);

    return DashboardScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              PrimaryButton(
                icon: Icons.add,
                text: tr.action_button_new_study,
                onPressed: controller.onClickNewStudy,
              ),
              const SizedBox(width: 28.0),
              SelectableText(state.visibleListTitle, style: theme.textTheme.headlineMedium),
              const Spacer(),
              SizedBox(
                width: 400.0,
                child: SearchBar(
                  hintText: tr.search,
                  controller: searchController,
                  leading: const Icon(Icons.search),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return ThemeConfig.sidesheetBackgroundColor(theme).withOpacity(0.5);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0), // spacing between body elements
          FutureBuilder<StudyUUser>(
              future: userRepo.fetchUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AsyncValueWidget<List<Study>>(
                      value: state.visibleStudies(searchQuery, snapshot.data!.preferences.pinnedStudies),
                      data: (visibleStudies) => StudiesTable(
                            studies: visibleStudies,
                            pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                            dashboardProvider: ref.read(dashboardControllerProvider.notifier),
                            onSelect: controller.onSelectStudy,
                            getActions: controller.availableActions,
                            emptyWidget: (widget.filter == null || widget.filter == StudiesFilter.owned)
                                ? (searchQuery != null && searchQuery!.isNotEmpty)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 24.0),
                                        child: EmptyBody(
                                          icon: Icons.content_paste_search_rounded,
                                          title: tr.studies_not_found,
                                          description: tr.modify_query,
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 24.0),
                                        child: EmptyBody(
                                          icon: Icons.content_paste_search_rounded,
                                          title: tr.studies_empty,
                                          description: tr.studies_empty_description,
                                          // "...or create a new draft copy from an already published study!",
                                          /* button: PrimaryButton(text: "From template",); */
                                        ),
                                      )
                                : const SizedBox.shrink(),
                          ));
                }
                return const SizedBox.shrink();
              }),
        ],
      ),
    );
  }
}
