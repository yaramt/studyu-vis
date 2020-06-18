import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/study_instance.dart';
import '../routes.dart';
import '../study_onboarding/app_state.dart';
import '../util/localization.dart';

class JourneyOverviewScreen extends StatefulWidget {
  @override
  _JourneyOverviewScreen createState() => _JourneyOverviewScreen();
}

class _JourneyOverviewScreen extends State<JourneyOverviewScreen> {
  StudyInstance study;

  Future<void> getConsentAndNavigateToDashboard(BuildContext context) async {
    final consentGiven = await Navigator.pushNamed(context, Routes.consent);
    if (consentGiven != null && consentGiven) {
      Navigator.pushNamed(context, Routes.dashboard);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(Nof1Localizations.of(context).translate('user_did_not_give_consent')),
        duration: Duration(seconds: 30),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;
  }

  List<Widget> buildJourney() {
    final interventions = <Widget>[];
    for (var i = 0; i < study.interventionOrder.length; i++) {
      final index = study.interventionOrder[i];
      if (index == null) {
        continue;
      }
      final milestone = Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [Text(study.interventionSet.interventions[index].name)]));
      interventions.add(milestone);
    }
    return interventions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('journey')),
        ),
        body: Builder(builder: (_context) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      study.title,
                      style: theme.textTheme.headline5,
                    ),
                    SizedBox(height: 40),
                    ...buildJourney(),
                    SizedBox(height: 40),
                    RaisedButton(
                      onPressed: () => getConsentAndNavigateToDashboard(_context),
                      child: Text(Nof1Localizations.of(context).translate('get_started')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
