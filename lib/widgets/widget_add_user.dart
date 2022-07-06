import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class WidgetAddUser extends StatefulWidget {
  const WidgetAddUser({Key? key}) : super(key: key);

  @override
  State<WidgetAddUser> createState() => _WidgetAddUserState();
}

class _WidgetAddUserState extends State<WidgetAddUser> {
  TextEditingController cNIK = TextEditingController();
  TextEditingController cFirstName = TextEditingController();
  TextEditingController cLastName = TextEditingController();
  TextEditingController cAge = TextEditingController();
  TextEditingController cLevel = TextEditingController();
  final pick = ImagePicker();
  File? image;
  final dateNow = DateFormat.yMEd().add_jms().format(DateTime.now()).toString();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'Add New User!',
                textStyle: const TextStyle(
                  fontSize: 30.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  textField('NIK', cNIK),
                  textField('First Name', cFirstName),
                  textField('Last Name', cLastName),
                  textField('Age', cAge),
                  textField('Level', cLevel),
                  if (image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: image != null ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      if (image != null) {
                        image = null;
                      } else {
                        ambilGambar(context);
                      }
                      setState(() {});
                    },
                    label: Text(image != null ? 'Hapus Foto' : 'Ambil gambar'),
                    icon: Icon(image != null
                        ? Icons.delete_outline
                        : Icons.upload_file_outlined),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
              onPressed: sendDataToFireBase, child: const Text('Simpan')),
        ],
      ),
    );
  }

  Future ambilGambar(BuildContext c) async {
    final pickImage = await pick.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (pickImage != null) {
      image = File(pickImage.path);
      setState(() {});
    } else {
      return;
    }
  }

  Widget textField(String title, TextEditingController controller) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          textInputAction: TextInputAction.next,
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Future<void> sendDataToFireBase() async {
    if (cNIK.text.isEmpty ||
        cFirstName.text.isEmpty ||
        cLastName.text.isEmpty ||
        cAge.text.isEmpty ||
        cLevel.text.isEmpty ||
        image == null) {
      return EasyLoading.showToast('Field masih ada yang kosong');
    } else {
      EasyLoading.show(status: 'Loading..', maskType: EasyLoadingMaskType.black);
      await 2.delay();
      String filename =basename(join(dirname(image!.path), cNIK.text.toString()));
      final fbStorage =FirebaseStorage.instance.ref().child('images/$filename');
      final task = await fbStorage.putFile(image!);
      final imgUrl = await task.ref.getDownloadURL();

      return users.add({
        'nik': cNIK.text,
        'first_name': cFirstName.text,
        'last_name': cLastName.text,
        'age': cAge.text,
        'level': cLevel.text,
        'date_created': dateNow,
        'date_updated': null,
        'image': imgUrl,
      }).then((value) {
        clearField();
        EasyLoading.dismiss();
        return EasyLoading.showSuccess('Data Berhasil Dikirim').whenComplete(() => Get.back());
      }).catchError((e) {
        clearField();
        EasyLoading.dismiss();
        return EasyLoading.showError(e);
      }).whenComplete(() => clearField);
    }
  }

  void clearField() {
    cAge.clear();
    cFirstName.clear();
    cLastName.clear();
    cLevel.clear();
  }
}
