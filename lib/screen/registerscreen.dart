import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/profile.dart';
import 'package:flutter_application_1/screen/homescreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formkey = GlobalKey<FormState>();
  Profile myProfile = Profile();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("สร้างบัญชี"),
              ),
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      key: formkey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("อีเมล", style: TextStyle(fontSize: 20)),
                            TextFormField(
                              onSaved: (String email) {
                                myProfile.email = email;
                              },
                              validator: MultiValidator([
                                RequiredValidator(
                                    errorText: "กรุณาป้อนอีเมลด้วยครับ ^^"),
                                EmailValidator(
                                    errorText: "รูปแบบอีเมลไม่ถูกต้องครับ ^^")
                              ]),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            Text("รหัสผ่าน", style: TextStyle(fontSize: 20)),
                            TextFormField(
                              onSaved: (String password) {
                                myProfile.password = password;
                              },
                              validator: RequiredValidator(
                                  errorText: "กรุณาป้อนรหัสผ่านด้วยครับ ^^"),
                              obscureText: true,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  child: Text("ลงทะเบียน",
                                      style: TextStyle(fontSize: 20)),
                                  onPressed: () async {
                                    if (formkey.currentState.validate()) {
                                      formkey.currentState.save();

                                      try {
                                        await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                                email: myProfile.email,
                                                password: myProfile.password)
                                            .then((value) {
                                          Fluttertoast.showToast(
                                              msg: "สร้างบัญชีผู้ใช้เรียบร้อย",
                                              gravity: ToastGravity.TOP);
                                          formkey.currentState.reset();
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return HomeScreen();
                                          }));
                                        });
                                      } on FirebaseAuthException catch (e) {
                                        print(e.code);
                                        String message;
                                        if (e.code == "email-already-in-use") {
                                          message =
                                              "อีเมลนี้มีผู้ใช้งานแล้วครับ";
                                        } else if (e.code == "weak-password") {
                                          message =
                                              "รหัสผ่านต้องมีตัวอักษรมากกว่า 6 ตัวครับ";
                                        } else {
                                          message = e.message;
                                        }
                                        Fluttertoast.showToast(
                                            msg: message,
                                            gravity: ToastGravity.CENTER);
                                      }
                                    }
                                  }),
                            )
                          ],
                        ),
                      )),
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
