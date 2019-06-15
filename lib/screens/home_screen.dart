import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:papyrus_peripheral/models/AppModel.dart';
import 'package:papyrus_peripheral/screens/SplashScreen.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:papyrus_peripheral/helpers/ReceiptCard.dart';
import 'package:papyrus_peripheral/data_models/Receipt.dart';
import 'dart:io';

double sizeMulW;
double sizeMulH;

LinearGradient greeny = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    const Color(0xFF6DC739),
    const Color(0xFF1BA977),
  ],
  tileMode: TileMode.repeated,
);
LinearGradient BtnTeal = LinearGradient(
  begin: Alignment.centerRight,
  end: Alignment.centerLeft,
  colors: [
    const Color(0xFF40A1A8),
    const Color(0xFF52C5A4),
    const Color(0xFF63DCA0),
  ],
  tileMode: TileMode.repeated,
);

class PapyrusPeripheral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: const Color(0xFF61C350),
    ));
    return ScopedModel<AppModel>(
        model: AppModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Papyrus - Expense Management',
          theme: ThemeData(
            fontFamily: 'Montserrat',
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen(),
        ));
  }
}

class Home_Screen extends StatefulWidget {
  @override
  _Home_ScreenState createState() => new _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    return ScopedModelDescendant<AppModel>(builder: (context, child, appModel) {
      return Scaffold(
        primary: true,
        body: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.blue,

                  boxShadow: [
                    new BoxShadow(
                      blurRadius: 2 * sizeMulW,
                      color: Colors.black12,
                      offset: new Offset(0, 3 * sizeMulW),
                    ),
                  ],
                  // borderRadius: BorderRadius.vertical(bottom:Radius.circular(30 * sizeMulW))
                ),
                child: Stack(
                  children: <Widget>[
                    SafeArea(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60 * sizeMulH,
                        decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(sizeMulW * 18),
                                bottomRight: Radius.circular(sizeMulW * 18))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: sizeMulW * 15,
                            ),
                            Material(
                                color: Colors.white.withAlpha(0),
                                child: InkWell(
                                    onTap: () {},
                                    // radius: sizeMulW*3000,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizeMulH * 3000)),
                                    highlightColor: Colors.red,
                                    splashColor: Colors.amber,
                                    child: Container(
                                      width: 50 * sizeMulW,
                                      height: 40 * sizeMulH,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3000))),
                                      child: Icon(
                                        FontAwesomeIcons.wifi,
                                        size: 35 * sizeMulH,
                                        color: Colors.white,
                                      ),
                                    ))),
                            SizedBox(
                              width: sizeMulW * 15,
                            ),
                            Material(
                                color: Colors.white.withAlpha(0),
                                child: InkWell(
                                    onTap: () {},
                                    // radius: sizeMulW*3000,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizeMulH * 3000)),
                                    highlightColor: Colors.red,
                                    splashColor: Colors.amber,
                                    child: Container(
                                      width: 50 * sizeMulW,
                                      height: 40 * sizeMulH,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3000))),
                                      child: Icon(
                                        FontAwesomeIcons.plug,
                                        size: 35 * sizeMulH,
                                        color: Colors.white,
                                      ),
                                    ))),
                          ],
                        ),
                      ),
                    ),
                    Center(
                        child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RefreshProgressIndicator(strokeWidth: 3),
                          JumpingDotsProgressIndicator(
                            fontSize: 30,
                          ),
                          // Container(

                          //   child: JumpingDotsProgressIndicator(
                          //     numberOfDots: 3,
                          //     fontSize: 200 * sizeMulW,
                          //     color: Colors.red,
                          //   ),
                          // ),
                          GlowingProgressIndicator(
                            child: Text(
                              "Waiting for Receipt",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizeMulW * 25,
                                  fontWeight: FontWeight.w900),
                            ),
                          )
                        ],
                      ),
                    ))
                    // Contain
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,

                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: sizeMulH * 80,
                      ),
                      Text(
                        "Last Receipts",
                        style: TextStyle(fontSize: sizeMulH * 25),
                      ),

                     ListView.builder(
                      // reverse: true,
                      itemCount: appModel.receiptFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        // var receipt = appModel.receipts[index];
                        // DateFormat("MMM dd, yyyy")
                        //         .format(DateTime.parse(receipt.dateTime))

                        File rJSON = File(appModel.receiptFiles[index].path);
                        Map map = jsonDecode(rJSON.readAsStringSync());
                        var receipt = Receipt.fromJson(map);

                        var dateCurr = DateFormat("MMM dd, yyyy")
                            .format(DateTime.parse(receipt.dateTime));
                        var datePrev = dateCurr;

                        if (index >= 1) {
                          File rJSON1 =
                              File(appModel.receiptFiles[index - 1].path);
                          Map map1 = jsonDecode(rJSON1.readAsStringSync());
                          var receipt1 = Receipt.fromJson(map1);
                          datePrev = DateFormat("MMM dd, yyyy")
                              .format(DateTime.parse(receipt1.dateTime));
                        }

                        return Container(
                          margin: (index == 0)
                              ? EdgeInsets.only(
                                  bottom: sizeMulW * 9, top: sizeMulW * 130)
                              : (index == appModel.receiptFiles.length - 1)
                                  ? EdgeInsets.only(
                                      top: sizeMulW * 9, bottom: sizeMulW * 50)
                                  : EdgeInsets.symmetric(vertical: sizeMulW * 9),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                (dateCurr != datePrev || index == 0)
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            bottom: sizeMulW * 18),
                                        child: Text(
                                          "    " + dateCurr.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ))
                                    : SizedBox(width: 1),
                                ReceiptCard(context, receipt, index),
                              ]),
                        );
                        // return Text("hello${appModel.receipts[index].items[0].name}",style: TextStyle(fontSize: 50,));
                      },
                    )
                    ],
                  ),
                  // color: Colors.red,
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      new BoxShadow(
                        blurRadius: 10 * sizeMulW,
                        color: Colors.black12,
                        offset: new Offset(0, 6 * sizeMulW),
                      ),
                    ],
                    borderRadius:
                        BorderRadius.all(Radius.circular(sizeMulW * 16)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(sizeMulW * 16)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 110 * sizeMulH,
                      decoration: BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            blurRadius: 2 * sizeMulW,
                            color: Colors.black12,
                            offset: new Offset(5, 5 * sizeMulW),
                          ),
                        ],
                        borderRadius:
                            BorderRadius.all(Radius.circular(sizeMulW * 16)),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,

                        // padding: EdgeInsets.symmetric(horizontal: sizeMulW*10),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {},
                                    highlightColor: Colors.lightGreen,
                                    // splashColor: Colors.green,
                                    child: Padding(
                                      padding: EdgeInsets.all(sizeMulW * 6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.qrcode,
                                            size: sizeMulW * 50,
                                          ),
                                          Text(
                                            "SCAN PROMO",
                                            style: TextStyle(
                                                // fo
                                                fontWeight: FontWeight.w900,
                                                color: Colors.grey[700],
                                                fontSize: sizeMulH * 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: sizeMulH * 2,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {},
                                    highlightColor: Colors.lightGreen,
                                    child: Padding(
                                      padding: EdgeInsets.all(sizeMulW * 6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.file,
                                            size: sizeMulW * 50,
                                          ),
                                          Text(
                                            "TEST RECEIPT",
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: TextStyle(
                                                // fo
                                                fontWeight: FontWeight.w900,
                                                color: Colors.grey[700],
                                                fontSize: sizeMulH * 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: sizeMulH * 2,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {},
                                    highlightColor: Colors.lightGreen,
                                    child: Padding(
                                      padding: EdgeInsets.all(sizeMulW * 6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.redoAlt,
                                            size: sizeMulW * 50,
                                          ),
                                          Text(
                                            "RESEND LAST",
                                            style: TextStyle(
                                                // fo
                                                fontWeight: FontWeight.w900,
                                                color: Colors.grey[700],
                                                fontSize: sizeMulH * 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

// class PapyrusPeripheral extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new Container();
//   }
// }
// class Home_Screen extends StatefulWidget {
//   @override
//   _Home_ScreenState createState() => new _Home_ScreenState();
// }

// class _Home_ScreenState extends State<Home_Screen> {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(

//       body: Container(

//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[

//           ],

//         ),
//       )
//       ,
//     );
//   }
// }
