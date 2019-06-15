import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AppModel extends Model{

  FirebaseAuth mAuth;
  FirebaseUser user;


  AppModel(){

    mAuth = FirebaseAuth.instance;


  }

   Future<FirebaseUser> login(String email, String password) async {
    user = await mAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print("The user is ${user.toString()}");
    // init();
    return user;
  }



}