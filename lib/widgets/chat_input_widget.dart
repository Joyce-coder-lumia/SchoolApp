import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:edutracker/widgets/app_config.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';








class ChatInputWidget extends StatefulWidget {

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool isEmojiPickerVisible = false;


  void _sendMessage() async {
    final text = _controller.text;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && text.isNotEmpty) {
      String uid = user.uid;
      await FirebaseFirestore.instance.collection('messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': uid,
        'recipientId': AppConfig.adminUID,
        'type': text,
      });

      _controller.clear();
      Fluttertoast.showToast(
        msg: "Message envoyé avec succès.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Affiche un SnackBar si le texte est vide ou si aucun utilisateur n'est connecté
      Fluttertoast.showToast(
        msg: user == null
            ? "Aucun utilisateur n'est connecté."
            : "Le message ne peut pas être vide.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        //backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result;
    result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      print("Fichier sélectionné: ${platformFile.name}");


      String userUid = FirebaseAuth.instance.currentUser!.uid;
      // Créez un timestamp unique pour le moment du téléchargement
      int timestamp = DateTime
          .now()
          .millisecondsSinceEpoch;

      print("Fichier sélectionné: ${platformFile.name}");

      // Créez une référence au chemin où le fichier sera stocké dans Firebase Storage
      // Vous pouvez inclure l'UID de l'utilisateur et un timestamp pour créer un chemin unique
      String filePath = 'uploads/$userUid/${timestamp}_${platformFile.name}';
      File file = File(platformFile.path!);

      try {
        // Téléchargez le fichier vers Firebase Storage
        await FirebaseStorage.instance.ref(filePath).putFile(file);

        // (Optionnel) Obtenez l'URL du fichier téléchargé
        String downloadURL = await FirebaseStorage.instance.ref(filePath)
            .getDownloadURL();
        String senderId = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('messages').add({
          'senderId': senderId,
          'recipientId': AppConfig.adminUID,
          'text': '[Fichier]',
          'fileUrl': downloadURL,
          // URL du fichier téléchargé
          'fileName': platformFile.name,
          // Nom du fichier pour référence
          'timestamp': FieldValue.serverTimestamp(),
          // Horodatage du message
          'type': 'file',
          // Indiquez que le message est un fichier
          // Vous pouvez ajouter d'autres champs pertinents ici, comme un champ indiquant si le message est destiné à un admin ou à un parent
        });


        print("URL du fichier téléchargé: $downloadURL");

        Fluttertoast.showToast(
          msg: "Fichier envoyé avec succès.",
          toastLength: Toast.LENGTH_SHORT,
        );

        // Ici, vous pouvez stocker l'URL du fichier dans Firestore si nécessaire
        // ...
      } catch (e) {
        print("Erreur lors du téléchargement du fichier: $e");
      }
    } else {
      print("Aucun fichier sélectionné.");
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFF96C896),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          // Icône d'attachement de fichier
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.black, size: 20.0),
            onPressed: _pickFile,
            alignment: Alignment.center,

          ),

          IconButton(
            icon: Icon(Icons.insert_emoticon, color: Colors.black, size: 20.0),
            onPressed: _toggleEmojiPicker,
          ),

          // Champ de texte étendu
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Message...",
                border: InputBorder
                    .none, // Supprime la bordure du champ de saisie
              ),
            ),
          ),
          // Icône d'envoi dans un cercle de couleur verte
          CircleAvatar(
            backgroundColor: Color(0xFF336035), // Couleur de fond du cercle
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 17.0),
              // Icône d'envoi de couleur blanche
              onPressed: _sendMessage,
              alignment: Alignment.center,
            ),
          ),
          isEmojiPickerVisible ? _buildEmojiPicker() : SizedBox.shrink(),

        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (Category? category, Emoji emoji) {
        setState(() {
          _controller.text = _controller.text + emoji.emoji;
        });
      },
      config: Config(
        height: 256,
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 * (kIsWeb ? 1.20 : 1.0),
          backgroundColor: const Color(0xFFF2F2F2),
        ),
        checkPlatformCompatibility: true,

      ),
    );
  }
}

