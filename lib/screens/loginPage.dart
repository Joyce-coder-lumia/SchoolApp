import 'package:edutracker/widgets/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'localHome.dart';
import 'package:google_fonts/google_fonts.dart';
import'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/',
                width: 250.0,
                height: 250.0,
              ),
              SizedBox(height: height * 0.04,),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Entrer votre email",
                        ),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                  .hasMatch(value!)) {
                            return "Entrer un email correct";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: height * 0.05,),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Entrer votre mot de passe",
                        ),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'^[a-zA-Z]+$').hasMatch(value!)) {
                            return "Entrer un bon mot de passe";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: height * 0.05,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Connexion', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF336035),
                            child: IconButton(
                              color: Colors.white,
                              onPressed: () {
                                _signIn();
                              },
                              icon: Icon(Icons.arrow_forward),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),

    );
  }
  
  void _signIn() async{
    String email = _emailController.text;
    String password = _passwordController.text;
    
    User? user = await _auth.signInEmailAndPassword(email, password);

    if(user != null){
      print("user is successfully connected");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> LocalHome()),);


    }else{
      print("Some error");
    }
  }
}



