import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/localization.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(Nof1Localizations.of(context).translate("about")),
            SizedBox(height: 20),
            FlatButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "studySelection"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              child: Text(Nof1Localizations.of(context).translate("get_started")),
            ),
          ],
        ),
      ),
    );
  }
}
