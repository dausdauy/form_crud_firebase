import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:beranda/widgets/widget_add_user.dart';
import 'package:beranda/widgets/widget_update_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../utils/controller.dart';

class PageUserDetails extends StatefulWidget {
  const PageUserDetails({Key? key}) : super(key: key);

  @override
  State<PageUserDetails> createState() => _PageUserDetailsState();
}

class _PageUserDetailsState extends State<PageUserDetails> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
    super.initState();
  }

  final c = Get.put(C());

  bool isLoading = true;

  Widget buildWhenLoading(String msg) => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(msg, style: Theme.of(context).textTheme.headline5),
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                WavyAnimatedText(
                  '...',
                  textStyle: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ],
        ),
      );
  final _usersStream = FirebaseFirestore.instance.collection('users');

  Widget get _fabAddUser => FloatingActionButton(
        onPressed: () => showCupertinoModalBottomSheet(
          barrierColor: Colors.black.withOpacity(0.3),
          context: context,
          builder: (BuildContext context) => const WidgetAddUser(),
        ),
        child: const Icon(Icons.add),
      );

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? buildWhenLoading('Getting Data')
        : Scaffold(
            floatingActionButton: _fabAddUser,
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Pendaftaran'),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _usersStream.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> ss) {
                if (ss.hasError) {
                  return const Center(child: Text('Ada kesalahan'));
                } else if (ss.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (ss.data!.docs.isEmpty) {
                  return Center(
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'No Data.',
                          textStyle: Theme.of(context).textTheme.headline4,
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GetX(
                    init: C(),
                    builder: (getx) {
                      if (c.isConnected.value == 'konek') {
                        return RefreshIndicator(
                          onRefresh: () => refreshData(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: ss.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              var data = ss.data!.docs[index];
                              return Card(
                                color: Colors.primaries[index].shade100,
                                child: ListTile(
                                  onTap: () => showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WidgetUpdateUser(id: data.id);
                                    },
                                  ),
                                  title: Text(data['first_name'] +
                                      ' ' +
                                      data['last_name']),
                                  subtitle: Text(
                                    'Age: ' +
                                        data['age'] +
                                        '\nLevel: ' +
                                        data['level'],
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            showCupertinoModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WidgetUpdateUser(
                                                id: data.id);
                                          },
                                        ),
                                        child: const Icon(
                                            Icons.edit_note_outlined),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () => dialogHapusData(
                                            data.id, data['nik']),
                                        child: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return offline();
                      }
                    },
                  );
                }
              },
            ));
  }

  Column offline() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You Are Offline',
                style: Theme.of(context).textTheme.headline5),
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                WavyAnimatedText(
                  '...',
                  textStyle: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () => Get.off(
            () => const PageUserDetails(),
            duration: const Duration(seconds: 2),
          ),
          child: const Text('Reconnect'),
          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
        )
      ],
    );
  }

  Future<void> dialogHapusData(String data, String imgName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yakin ingin hapus data ini'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
            ),
            OutlinedButton(
              onPressed: () async => await confirmHapusData(data, imgName),
              child: const Text('Hapus'),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(
                  color: Colors.red,
                ),
                primary: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmHapusData(String data, String imgName) {
    debugPrint('nama foto : $imgName');
    EasyLoading.show(status: 'Loading..', maskType: EasyLoadingMaskType.black);
    return Future.delayed(const Duration(seconds: 2), () async {
      final fbStorage = FirebaseStorage.instance.ref().child('images/$imgName');
      await fbStorage.delete();
      await _usersStream.doc(data).delete();
    }).whenComplete(() {
      Navigator.pop(context);
      EasyLoading.dismiss();
      return EasyLoading.showSuccess('Data Berhasil Di Hapus!');
    });
  }

  Future<void> refreshData() async {
    _usersStream.snapshots();
  }
}
