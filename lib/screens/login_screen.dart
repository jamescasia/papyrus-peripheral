import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'home_screen.dart';
import 'package:papyrus_peripheral/models/AppModel.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => new _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  
  StreamSubscription sub;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>( 
      builder: (context, child, appModel) {
        return WillPopScope(
          onWillPop:  () {
          if (isLoading) {
            sub.cancel();
            setState(() {
              isLoading = false;
            });
          } 
            // _showDialog(context);
        },
                  child: new Container(
            color: Colors.red,

            child: Column(
              
              children: <Widget>[
                Container(width: sizeMulW*100,
                height: sizeMulW*50,
                child: RaisedButton(
                  onPressed: (){
 try {
                                sub = appModel
                                    .login("user@user.com", "useruser")
                                    .asStream()
                                    .listen((data) {
                                  if (data.email != null) {
                                    Navigator.pushReplacement(context,
                                        CupertinoPageRoute(builder: (context) {
                                      isLoading = false;
                                      return Home_Screen();
                                    }));
                                  }
                                });
                              } catch (a) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text("Failed to login ${a.toString()}"),
                                ));
                              }
                    
                  },
                ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}