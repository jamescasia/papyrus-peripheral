import 'package:scoped_model/scoped_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:papyrus_peripheral/data_models/Receipt.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:watcher/watcher.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'dart:math';

enum LoadingStatus {
  WAITING_FOR_RECEIPT,
  UPLOADING_RECEIPT,
  SUCCESS_UPLOAD,
  FAILED_UPLOAD
}

class AppModel extends Model {
  FirebaseAuth mAuth;
  FirebaseUser user;
  FirebaseDatabase database;
  DatabaseReference retailerDataReference;
  DatabaseReference usersReference;
  LoadingStatus loadingStatus = LoadingStatus.WAITING_FOR_RECEIPT;

  DatabaseReference userPromoReference;
  Directory rootDir;
  DatabaseReference receiptsReference;
  File newDetectedReceiptFile;
  var connectivitySubscription;
  String connectivityStatus;
  List<Permission> perms = [
    Permission.AccessCoarseLocation,
    Permission.AccessFineLocation,
    Permission.Camera,
    Permission.ReadExternalStorage,
    Permission.WriteExternalStorage
  ];
  bool receiptsLoaded = false;
  Map<Permission, PermissionStatus> perm_results =
      new Map<Permission, PermissionStatus>();
  List<FileSystemEntity> receiptFiles = [];
  Receipt currentReceipt;
  bool successUpload = false;

  Map<String, String> dirMap = {
    "Papyrus Invoices": "null",
  };

  AppModel() {
    // init();
    mAuth = FirebaseAuth.instance;
    database = FirebaseDatabase.instance;
    launch();
    // init();
  }
  launch() async {
    for (Permission p in perms) {
      // perm_results.addEntries(p:null);
      perm_results[p] = await SimplePermissions.requestPermission(p);
    }
    print("The permission results" + perm_results.toString());
  }

  Future<FirebaseUser> login(String email, String password) async {
    user = await mAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print("The user is ${user.toString()}");
    await init();
    return user;
  }

  init() async {
    retailerDataReference =
        database.reference().child('private/retailerData/${user.uid}');
    usersReference = database.reference().child('private/accounts/users/');
    receiptsReference = database.reference().child('private/receipts');
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) connectivityStatus = ("mobile");
      if (result == ConnectivityResult.wifi) connectivityStatus = ("wifi");
      if (result == ConnectivityResult.none) connectivityStatus = ("none");

      notifyListeners();
      // Got a new connectivity status!
    });
    if (Platform.isAndroid) {
      print("ANDDDROOIDDDESSUU");
      rootDir = await getExternalStorageDirectory();
      print("got external nibbas" + rootDir.path);
    }
    await checkOrGenerateDirectories();
    listFileNamesOfReceiptsFoundInStorageAndGenerateReceipts();
    watchForNewReceipts();
  }

  watchForNewReceipts() {
    print("receipts dir" + dirMap['Papyrus Invoices']);
    DirectoryWatcher(dirMap['Papyrus Invoices']).events.listen((event) {
      if (loadingStatus != LoadingStatus.FAILED_UPLOAD) {
        print("OOH FILE EVENT!!" + event.toString());
      }
    });
//     Directory(dirMap['Papyrus Invoices']).watch().listen((newFile) {
//       File rJSON = File(newFile.path);
//       Map map = jsonDecode(rJSON.readAsStringSync());
//       currentReceipt = Receipt.fromJson(map);

//       scanQRCode(false);

// // Do something print that new receipt
//     });
  }

  checkOrGenerateDirectories() async {
    for (String i in dirMap.keys) {
      String path = await Directory("${rootDir.path}/${i}/")
          .create(recursive: true)
          .then((dir) {
        return dir.path;
      });
      dirMap[i] = path;
    }
  }

  void saveReceiptToJsonAndToFile() {
    File file = new File(
        '${dirMap['Papyrus Invoices']}/${currentReceipt.time_stamp}.json');
    file.writeAsString(jsonEncode(currentReceipt.toJson()));
    receiptFiles.insert(0, file);

    notifyListeners();
  }

  void scanQRCode(bool fake) async {
    String uid = await QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(true) // default false
        .setTorchEnabled(true) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();
    print("scanned uid: " + uid);

    if (fake)
      createFakeReceipt(uid);
    else
      setReceiptUID(uid);
    saveReceiptToJsonAndToFile();

    loadingStatus = LoadingStatus.UPLOADING_RECEIPT;
    uploadReceiptToDatabase();
  }

  createFakeReceipt(String uid) {
    List<ReceiptItem> recptItems = [
      new ReceiptItem("Im Nayeon", 2, 1500.0),
      new ReceiptItem("Yoo Jeongyeon", 2, 1500.0),
      new ReceiptItem("Hirai Momo", 2, 1500.0),
      new ReceiptItem("Minatozaki Sana", 2, 1500.0),
      new ReceiptItem("Park Jihyo", 2, 1500.0),
      new ReceiptItem("Myoui Mina", 2, 1500.0),
      new ReceiptItem("Kim Dahyun", 2, 1500.0),
      new ReceiptItem("Son Chaeyoung", 2, 1500.0),
      new ReceiptItem("Chou Tzuyu", 2, 1500.0)
    ];

    List<ReceiptItem> fake_items = [
      new ReceiptItem("Gatorade 500 ml", 2, 35.50),
      new ReceiptItem("Fresh Milk 1L", 1, 90.00),
      new ReceiptItem("Assam Milk Tea 500 ml", 2, 43.50),
      new ReceiptItem("Nature's Spring 1L", 2, 29.50),
      new ReceiptItem("B'lue 500 ml", 1, 28.50),
      new ReceiptItem("Cheetos 120g", 2, 89.00),
      new ReceiptItem("Pic-A 80g", 2, 56.00),
      new ReceiptItem("Vitamilk 500 ml", 1, 32.00),
      new ReceiptItem("Nissin Cup Noodles 100g", 2, 33.50),
      new ReceiptItem("Yakisoba 100g", 1, 30.50),
      new ReceiptItem("Nissin Jjampong 100g", 1, 31.50),
      new ReceiptItem("Colgate toothpaste 300g", 1, 80.50),
      new ReceiptItem("Doritos 120g", 1, 120.00),
      new ReceiptItem("Lucky Me Pancit Canton", 1, 12.50),
      new ReceiptItem("Cheezy 100g", 1, 45.50),
      new ReceiptItem("Sparkling Water 350ml", 1, 25.50),
      new ReceiptItem("Flavoured Water 350 ml", 1, 20.50),
    ];
    String time = DateTime.now().toLocal().millisecondsSinceEpoch.toString();
    fake_items.shuffle();
    currentReceipt = Receipt()
      ..merchant = "Seven Eleven"
      ..dateTime = DateTime.now().toLocal().toIso8601String()
      ..time_stamp = time
      ..items = fake_items.sublist(4, 11)
      ..recpt_id = time
      ..uid = uid;
  }

  setReceiptUID(String uid) {
    currentReceipt.uid = uid;
  }

  scanPromo() async {
    String read = await QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(true) // default false
        .setTorchEnabled(true) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();

    String uid = read.split(":")[0];
    String promoCode = read.split(":")[1];

    usersReference.child("$uid/promos/$promoCode/status").set("collected");
  }

  uploadReceiptToDatabase() async {
    String ruid = "r_uid" + currentReceipt.time_stamp;
    try {
      receiptsReference.child(ruid).set(jsonEncode(currentReceipt.toJson()));
      usersReference
          .child("${currentReceipt.uid}/receipts")
          .child(ruid)
          .set(user.uid);
      await retailerDataReference
          .child("/receiptIds")
          .child(ruid)
          .set(currentReceipt.uid);

      loadingStatus = LoadingStatus.SUCCESS_UPLOAD;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 300));
      loadingStatus = LoadingStatus.WAITING_FOR_RECEIPT;
      notifyListeners();
    } catch (e) {
      successUpload = false;
      loadingStatus = LoadingStatus.FAILED_UPLOAD;
      notifyListeners();
    }

    // upload to retailer db
  }

  void listFileNamesOfReceiptsFoundInStorageAndGenerateReceipts() {
    print("here are the files");
    receiptFiles = Directory(dirMap['Papyrus Invoices'])
        .listSync(recursive: true, followLinks: false);

    receiptFiles = receiptFiles.reversed.toList();
    receiptsLoaded = true;

    File rJSON = File(receiptFiles[0].path);
    Map map = jsonDecode(rJSON.readAsStringSync());
    var receipt = Receipt.fromJson(map);
    print("HUY ININAATAY" + receipt.uid);
    print(receiptFiles.length.toString() + "The length of the dayum");
    notifyListeners();
  }
}
