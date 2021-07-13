import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

import '../icon_labels.dart';
import 'bar_chart.dart';

class Stats extends StatelessWidget {
  final Study study;
  final Function() reload;

  const Stats({@required this.study, this.reload, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        childrenPadding: EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Icon(MdiIcons.chartLine),
        title: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Statistics', style: TextStyle(fontSize: 20)),
              Spacer(),
              IconLabel(label: study.participantCount.toString(), iconData: MdiIcons.accountGroup, color: Colors.red),
              VerticalDivider(),
              IconLabel(label: study.endedCount.toString(), iconData: MdiIcons.flagCheckered, color: Colors.black),
              VerticalDivider(),
              IconLabel(label: study.activeSubjectCount.toString(), iconData: MdiIcons.run, color: Colors.green),
              VerticalDivider(),
              IconLabel(
                  label: study.totalMissedDays.toString(), iconData: MdiIcons.calendarRemove, color: Colors.orange),
            ],
          ),
        ),
        children: [
          IconLabel(
              label: '${study.participantCount.toString()} total participants',
              iconData: MdiIcons.accountGroup,
              color: Colors.red),
          SizedBox(height: 16),
          IconLabel(
              label: '${study.endedCount.toString()} studies have ended.',
              iconData: MdiIcons.flagCheckered,
              color: Colors.black),
          SizedBox(height: 16),
          IconLabel(
              label: '${study.activeSubjectCount.toString()} participants have completed a task in the last 3 days',
              iconData: MdiIcons.run,
              color: Colors.green),
          SizedBox(height: 16),
          IconLabel(
              label:
                  '${study.totalMissedDays} total days missed by participants (${(study.percentageMissedDays * 100).toStringAsFixed(2)}%)',
              iconData: MdiIcons.calendarRemove,
              color: Colors.orange),
          SizedBox(height: 36),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: BarChartView(_missedDaysHistogramData(study), color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

Map<int, num> _missedDaysHistogramData(Study study) {
  final missedDaysCount =
      study.missedDays.groupFoldBy<int, int>((element) => element, (total, e) => total != null ? total += 1 : 1);
  return List.generate(
      study.schedule.length + 1, (index) => missedDaysCount.containsKey(index) ? missedDaysCount[index] : 0).asMap();
}
