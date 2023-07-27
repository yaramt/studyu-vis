import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as studybadge;
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/features/study/study_participation_badge.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studies,
    required this.onSelect,
    required this.getActions,
    required this.emptyWidget,
    required this.pinnedStudies,
    required this.dashboardController,
    Key? key,
  }) : super(key: key);

  final List<Study> studies;
  final OnSelectHandler<Study> onSelect;
  final ActionsProviderFor<Study> getActions;
  final Widget emptyWidget;
  final Iterable<String> pinnedStudies;
  final DashboardController dashboardController;

  @override
  Widget build(BuildContext context) {
    List<String> headers = [
      tr.studies_list_header_participants_enrolled,
      tr.studies_list_header_participants_active,
      tr.studies_list_header_participants_completed,
    ];
    final int maxLength = headers.fold(0, (max, element) => max > element.length ? max : element.length);
    final double statsCellWidth = maxLength * 11;

    return StandardTable<Study>(
      items: studies,
      columns: [
        StandardTableColumn(
          label: '',
          columnWidth: const FixedColumnWidth(60),
        ),
        StandardTableColumn(
          label: tr.studies_list_header_title,
          columnWidth: const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(2.4)),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_status,
          columnWidth: const MaxColumnWidth(FixedColumnWidth(90), IntrinsicColumnWidth()),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participation,
          columnWidth: const MaxColumnWidth(FixedColumnWidth(130), IntrinsicColumnWidth()),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_created_at,
          columnWidth: const FlexColumnWidth(1),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_enrolled,
          columnWidth: MaxColumnWidth(FixedColumnWidth(statsCellWidth), const IntrinsicColumnWidth()),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_active,
          columnWidth: MaxColumnWidth(FixedColumnWidth(statsCellWidth), const IntrinsicColumnWidth()),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_completed,
          columnWidth: MaxColumnWidth(FixedColumnWidth(statsCellWidth), const IntrinsicColumnWidth()),
          sortable: true,
        ),
      ],
      onSelectItem: onSelect,
      trailingActionsAt: (item, _) => getActions(item),
      buildCellsAt: _buildRow,
      sortColumnPredicates: _sortColumns,
      pinnedPredicates: pinnedPredicates,
      emptyWidget: emptyWidget,
    );
  }

  int Function(Study a, Study b) get pinnedPredicates {
    return (Study a, Study b) {
      if (pinnedStudies.contains(a.id)) {
        return -1;
      } else if (pinnedStudies.contains(b.id)) {
        return 1;
      }
      return 0;
    };
  }

  List<int Function(Study a, Study b)?> get _sortColumns {
    final predicates = [
      (Study a, Study b) => 0, // do not sort pin icon
      (Study a, Study b) => a.title!.compareTo(b.title!),
      (Study a, Study b) => a.status.index.compareTo(b.status.index),
      (Study a, Study b) => a.participation.index.compareTo(b.participation.index),
      (Study a, Study b) => a.createdAt!.compareTo(b.createdAt!),
      (Study a, Study b) => a.participantCount.compareTo(b.participantCount),
      (Study a, Study b) => a.activeSubjectCount.compareTo(b.activeSubjectCount),
      (Study a, Study b) => a.endedCount.compareTo(b.endedCount),
    ];
    return predicates;
  }

  List<Widget> _buildRow(BuildContext context, Study item, int rowIdx, Set<MaterialState> states) {
    final theme = Theme.of(context);

    TextStyle? mutedTextStyleIfZero(int value) {
      return (value > 0) ? null : ThemeConfig.bodyTextBackground(theme);
    }

    Icon icon(IconData iconData) {
      return Icon(
        iconData,
        color: Colors.grey,
        size: 25,
      );
    }

    Widget getRespectivePinIcon(Set<MaterialState> state) {
      final bool contains = pinnedStudies.contains(item.id);
      final bool hovers = state.contains(MaterialState.hovered);
      switch (hovers) {
        case true:
          return contains ? icon(MdiIcons.pinOff) : icon(MdiIcons.pin);
        case false:
          return contains ? icon(MdiIcons.pin) : const SizedBox.shrink();
        default:
          return const SizedBox.shrink();
      }
    }

    return [
      MouseEventsRegion(
        onTap: () => pinnedStudies.contains(item.id)
            ? dashboardController.pinOffStudy(item.id)
            : dashboardController.pinStudy(item.id),
        builder: (context, mouseEventState) {
          return SizedBox.expand(
            child: Container(
              child: getRespectivePinIcon(mouseEventState),
            ),
          );
        },
      ),
      item.studyTags.isEmpty
          ? Text(item.title ?? '[Missing study title]')
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title ?? '[Missing study title]'),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: List<Widget>.generate(item.studyTags.length, (index) {
                  // todo either use [StudyTagBadge] here or use [studybadge.Badge] at [StudyDesignInfoFormView]
                  // try to style [StudyTagBadge] the same as Badge here because of delete function.
                  // then replace this badge here with [StudyTagBadge]
                  return MouseEventsRegion(
                    //onTap: () => dashboardController.filterTag.add(item.studyTags.elementAt(index)),
                    onTap: () {
                      dashboardController.setSearchText(item.studyTags.elementAt(index).name);
                      dashboardController.filterStudies(item.studyTags.elementAt(index).name);
                    },
                    builder: (context, mouseEventState) {
                      return studybadge.Badge(
                        label: item.studyTags.elementAt(index).name,
                        type: studybadge.BadgeType.outlineFill,
                        icon: null,
                      );
                    },
                  );
                }),
              ),
            ]),
      StudyStatusBadge(
        status: item.status,
        showPrefixIcon: false,
        showTooltip: false,
      ),
      StudyParticipationBadge(
        participation: item.participation,
      ),
      Text(item.createdAt?.toTimeAgoString() ?? ''),
      Text(item.participantCount.toString(), style: mutedTextStyleIfZero(item.participantCount)),
      Text(item.activeSubjectCount.toString(), style: mutedTextStyleIfZero(item.activeSubjectCount)),
      Text(item.endedCount.toString(), style: mutedTextStyleIfZero(item.endedCount)),
    ];
  }
}
