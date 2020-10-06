import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Wrapper() ,
    );
  }
}



class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context,AsyncSnapshot<FirebaseUser> user){

        if(user.connectionState==ConnectionState.waiting)return Center(child:CircularProgressIndicator());
        if(user.data==null) return LoginScreen();
        return HomeScreen(currentUser: user.data,);
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child:SingleChildScrollView(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: (){
                  GoogleSignIn googleAuth=new GoogleSignIn();
    googleAuth.signIn().then((result){
      result.authentication.then((googleKey){
        AuthCredential googleCredential = GoogleAuthProvider.getCredential
        (idToken:googleKey.idToken , accessToken: googleKey.accessToken);
        FirebaseAuth.instance.signInWithCredential(googleCredential).then((user){
          print(user.user.displayName);
        }).catchError((error){
          print(error.toString());
        });
      }).catchError((error){
        print(error.toString());
      });
    }).catchError((error){
      print(error.toString());
    });
                },
                child: Text('Google Login'),
              ),
              SizedBox(height:10),
              RaisedButton(
                child:Text('Facebook login'),
                onPressed: (){
                  FacebookLogin fb=new FacebookLogin();
    fb.logIn(['email','public_profile']).then((result){
      switch(result.status){
        case FacebookLoginStatus.loggedIn:
         final token = result.accessToken.token;
    AuthCredential fbCredential = FacebookAuthProvider.getCredential(accessToken: token);
    FirebaseAuth.instance.signInWithCredential(fbCredential).then((user) {
     print(user.user.displayName);
    });return;
        default:return;
      }
    }).catchError((error){
      print(error);
    });
                },
              )
            ],
          )
        )
      )
    );
  }
}

class HomeScreen extends StatelessWidget {

  final FirebaseUser currentUser;

  HomeScreen({this.currentUser});
  @override
  Widget build(BuildContext context) {
    print(currentUser.email);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          FirebaseAuth.instance.signOut();
        },
        child:Icon(Icons.logout)
      ),
    );
  }
}