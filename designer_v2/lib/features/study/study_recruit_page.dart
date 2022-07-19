import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class StudyRecruitScreen extends ConsumerWidget {
  const StudyRecruitScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Recruit participants: $studyId"),
            TextButton(
                onPressed: () => ref.read(routerProvider).dispatch(
                    RoutingIntents.studyEdit(studyId)),
                child: Text("Go to editor")
            ),
          ],
        )
    );
  }
}
