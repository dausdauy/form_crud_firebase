import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WidgetUpdateUser extends StatefulWidget {
  const WidgetUpdateUser({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<WidgetUpdateUser> createState() => _WidgetUpdateUserState();
}

class _WidgetUpdateUserState extends State<WidgetUpdateUser> {
  final TextEditingController cNIK = TextEditingController();
  final TextEditingController cFirstName = TextEditingController();
  final TextEditingController cLastName = TextEditingController();
  final TextEditingController cAge = TextEditingController();
  final TextEditingController cLevel = TextEditingController();
  final dateNow = DateFormat.yMEd().add_jms().format(DateTime.now()).toString();
  String? lastUpdate;
  String dateCreated = '';
  String? userImage;
  String? currentFname;
  String? currentLname;
  String? currentAge;
  String? currentLevel;

  final users = FirebaseFirestore.instance.collection('users');

  Future<void> getUser(String id) async {
    return users.doc(id).get().then((value) {
      cNIK.text = value['nik'];
      cFirstName.text = value['first_name'];
      cLastName.text = value['last_name'];
      cAge.text = value['age'];
      cLevel.text = value['level'];
      userImage = value['image'];
      dateCreated = value['date_created'];
      value['date_updated'] != null ? lastUpdate = value['date_updated'] : null;

      currentFname = value['first_name'];
      currentLname = value['last_name'];
      currentAge = value['age'];
      currentLevel = value['level'];
      setState(() {});
    });
  }

  @override
  void initState() {
    getUser(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        child: Column(
          children: [
            AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'Update User!',
                  textStyle: const TextStyle(
                    fontSize: 30.0,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              lastUpdate != null
                  ? 'Last Updated: $lastUpdate'
                  : 'Nothing updated',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    textField('nik', cNIK, false),
                    textField('First Name', cFirstName, true),
                    textField('Last Name', cLastName, true),
                    textField('Age', cAge, true),
                    textField('Level', cLevel, true),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Image.network(
                            userImage ??
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Text(
                              userImage != null ? dateCreated : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
                onPressed: updateDataToFireBase, child: const Text('Update')),
          ],
        ),
      ),
    );
  }

  Widget textField(
          String title, TextEditingController controller, bool enable) =>
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          enabled: enable,
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Future<void> updateDataToFireBase() async {
    if ((cFirstName.text.isEmpty ||
        cLastName.text.isEmpty ||
        cAge.text.isEmpty ||
        cLevel.text.isEmpty)) {
      return EasyLoading.showToast('Field masih ada yang kosong');
    } else if (cFirstName.text == currentFname &&
        cLastName.text == currentLname &&
        cAge.text == currentAge &&
        cLevel.text == currentLevel) {
      return EasyLoading.showToast('Data Masih sama, tidak perlu ada update');
    } else {
      EasyLoading.show(
          status: 'Loading..', maskType: EasyLoadingMaskType.black);

      return Future.delayed(const Duration(seconds: 2), () {
        users.doc(widget.id).update({
          'first_name': cFirstName.text,
          'last_name': cLastName.text,
          'age': cAge.text,
          'level': cLevel.text,
          'date_updated': dateNow,
        }).then((value) {
          EasyLoading.dismiss();
          cAge.clear();
          cFirstName.clear();
          cLastName.clear();
          cLevel.clear();
          return EasyLoading.showSuccess('Data Berhasil Di Update')
              .whenComplete(() => Get.back());
        }).catchError((e) {
          EasyLoading.dismiss();
          return EasyLoading.showError(e);
        });
      });
    }
  }
}
