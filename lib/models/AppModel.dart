import 'package:scoped_model/scoped_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:papyrus_peripheral/data_models/Receipt.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class AppModel extends Model {
  FirebaseAuth mAuth;
  FirebaseUser user;
  FirebaseDatabase database;
  DatabaseReference retailerDataReference;
  DatabaseReference usersReference;
  Directory rootDir;
  DatabaseReference receiptsReference;
  File newDetectedReceiptFile;

  
  List<FileSystemEntity> receiptFiles;
  Receipt currentReceipt;

  Map<String, String> dirMap = {
    "PapyrusReceipts": "null",
  };

  AppModel() {
    init();
  }

  init() async {
    mAuth = FirebaseAuth.instance;
    database = FirebaseDatabase.instance;
    rootDir = await getExternalStorageDirectory();
    await checkOrGenerateDirectories();
    watchForNewReceipts();
    retailerDataReference = database.reference().child('private/retailerData/${user.uid}');
    usersReference = database.reference().child('private/accounts/users/');
  }

  watchForNewReceipts(){
    Directory(dirMap['PapyrusReceipts']).watch().listen((newFile){

      File rJSON = File(newFile.path);
      Map map = jsonDecode(rJSON.readAsStringSync());
      currentReceipt = Receipt.fromJson(map);

      scanQRCode(false);

// Do something print that new receipt

    });


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

    return true;
  }

  void saveReceiptToJsonAndToFile() {
    File file =
        new File('${dirMap['PapyrusReceipts']}/${currentReceipt.time_stamp}.json');
    file.writeAsString(jsonEncode(currentReceipt.toJson()));
  }

  void scanQRCode(bool fake) {
    String uid;

    if (fake)
      createFakeReceipt(uid);
    else
      setReceiptUID(uid);

    uploadReceiptToDatabase(uid, currentReceipt);
  }

  createFakeReceipt(String uid) {
    String time = DateTime.now().toLocal().millisecondsSinceEpoch.toString();
    currentReceipt = Receipt()
      ..dateTime = DateTime.now().toLocal().toIso8601String()
      ..time_stamp = time
      ..imagePath = "${dirMap['PapyrusReceipts']}/${time}.png"
      ..uid = uid;
  }

  setReceiptUID(String uid) {
    currentReceipt.uid = uid;

  }

  uploadReceiptToDatabase(String uid, Receipt receipt){
    String ruid = "r_uid" + receipt.time_stamp;
    receiptsReference.child(ruid).set(jsonEncode(receipt.toJson()));
    usersReference.child(  "${receipt.uid}/receipts").child(ruid).set(user.uid);


    // upload to retailer db



  }

  void listFileNamesOfReceiptsFoundInStorageAndGenerateReceipts() {
    print("here are the files");
    receiptFiles = Directory(dirMap['Receipts'])
        .listSync(recursive: true, followLinks: false);

    receiptFiles = receiptFiles.reversed.toList();
    notifyListeners();
  }

  Future<FirebaseUser> login(String email, String password) async {
    user = await mAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print("The user is ${user.toString()}");
    // init();
    return user;
  }
}
