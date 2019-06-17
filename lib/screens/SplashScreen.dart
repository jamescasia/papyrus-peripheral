import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'package:papyrus_peripheral/helpers/ClipShadowPath.dart';
import 'package:papyrus_peripheral/helpers/CustomShapeClipper.dart';
import 'package:papyrus_peripheral/helpers/LongButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:papyrus_peripheral/models/AppModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'HomeScreen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    sizeMulW = MediaQuery.of(context).size.width / 411.5;
    sizeMulH = MediaQuery.of(context).size.height / 683;
    homeButtonDist = -0.00023 *
            (MediaQuery.of(context).size.width *
                MediaQuery.of(context).size.width) +
        0.9466 * (MediaQuery.of(context).size.width) -
        56.372;
    // Future.delayed(Duration(milliseconds: 1300), () {
    //   Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(
    //           builder: (context) =>

    return ScopedModelDescendant<AppModel>(
        rebuildOnChange: false,
        builder: (context, child, appModel) {
          return LogInScreen(); 
        });

    // ));
    // });
  }
}

class SplashFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.green,
        child: Center(
            child: Image.asset(
          'assets/icons/3x/papygreen.png',
          color: Colors.white,
          height: sizeMulW * 100,
          width: sizeMulW * 100,
        )),
      ),
    );
  }
}
