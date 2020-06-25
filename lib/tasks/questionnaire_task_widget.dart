import 'package:flutter/material.dart';

import '../database/models/observations/tasks/questionnaire_task.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';

class QuestionnaireTaskWidget extends StatelessWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: QuestionnaireWidget(task.questions.questions));
  }
}
