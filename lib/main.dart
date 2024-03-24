import 'package:edutracker/screens/chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:edutracker/screens/splashScreen.dart';
import'package:edutracker/screens/chat.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDsq8KHrribDPrQzQB5KJW2lpZY9iCDHTI",
        appId: "1:421814093807:web:ca7b8828a98be27c97d81a",
        messagingSenderId: "421814093807",
        projectId: "edutracker-83c7d"),
    );
  }else{
    await Firebase.initializeApp();
  }


  runApp(MaterialApp(
    //home: SplashScreen(),
    home: ChatScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

