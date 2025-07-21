import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class EditUserScreen extends StatefulWidget {
  final UserManager userManager;
  final AppManager appManager;

  const EditUserScreen({
    super.key,
    required this.userManager,
    required this.appManager,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;
  final TextEditingController textEditing1Controller = TextEditingController();
  final TextEditingController textEditing2Controller = TextEditingController();
  final TextEditingController textEditing3Controller = TextEditingController();
  final TextEditingController textEditing4Controller = TextEditingController();
  late User user;

  Future<void> _openImagePicker(User user) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      UserManager.userNotifier.value = user.copyWith(avatar: pickedImage.path);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (UserManager.userNotifier.value != null) {
      user = UserManager.userNotifier.value!;
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditing1Controller.dispose();
    textEditing2Controller.dispose();
    textEditing3Controller.dispose();
    textEditing4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder(
            valueListenable: UserManager.userNotifier,
            builder: (_, valueUser, __) {
              if (valueUser == null) {
                return Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.only(
                          top: 10.0, bottom: 10.0, right: 10, left: 10)),
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(
                                color: Colors.white70,
                                width: 2,
                              ))),
                    ),
                    onPressed: () => {},
                    child: const Text(
                      "Đăng nhập để chỉnh sửa!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: valueUser.avatar.isNotEmpty
                                ? FadeInImage(
                                    image: CachedNetworkImageProvider(
                                      valueUser.avatar,
                                    ),
                                    placeholder: MemoryImage(kTransparentImage),
                                  ).image
                                : FadeInImage(
                                    image: Image.file(File(valueUser.avatar))
                                        .image,
                                    fadeInDuration: const Duration(seconds: 1),
                                    placeholder: MemoryImage(kTransparentImage),
                                    fit: BoxFit.cover,
                                  ).image,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              _openImagePicker(valueUser);
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  _buildTextFieldName(
                    'Name',
                    valueUser.name ?? 'Enter your name',
                    false,
                    onChanged: (value) {
                      UserManager.userNotifier.value = valueUser.copyWith(
                        name: value,
                      );
                    },
                  ),
                  _buildTextFieldUsername(
                    'Username',
                    valueUser.username ?? 'Enter you username',
                    false,
                    onChanged: (value) {
                      UserManager.userNotifier.value = valueUser.copyWith(
                        username: value,
                      );
                    },
                  ),
                  _buildTextFieldPhone(
                    'Phone Number',
                    valueUser.phoneNumber ?? 'Enter your phone number',
                    false,
                    onChanged: (value) {
                      UserManager.userNotifier.value = valueUser.copyWith(
                        phoneNumber: value,
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(valueUser);
                    },
                    child: _buildTextFieldBirthday(
                      valueUser.birthday ?? 'Birthday',
                      valueUser.birthday ?? 'Enter your birthday',
                      true,
                      onChanged: (value) {
                        UserManager.userNotifier.value = valueUser.copyWith(
                          birthday: value,
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text(
                            'Male',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: valueUser.gender != null
                              ? valueUser.gender?.contains('Male')
                              : false,
                          onChanged: (bool? value) {
                            UserManager.userNotifier.value = valueUser.copyWith(
                              gender: 'Male',
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Female'),
                          value: valueUser.gender != null
                              ? valueUser.gender?.contains('Female')
                              : false,
                          onChanged: (bool? value) {
                            UserManager.userNotifier.value = valueUser.copyWith(
                              gender: 'Male',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        _userManager.updateUser(valueUser).then((value) {
                          UserManager.userNotifier.value = value;

                          _appManager.notifierBottom(
                            context,
                            'Update User Successful!',
                          );
                        }).catchError((error) {
                          UserManager.userNotifier.value = user;

                          textEditing1Controller.text = user.name ?? 'Unknown';
                          textEditing2Controller.text =
                              user.username ?? 'Unknown';
                          textEditing3Controller.text = user.phoneNumber ?? '';
                          textEditing4Controller.text = user.birthday ?? '';
                          _appManager.notifierBottom(
                            context,
                            'Error: $error',
                          );
                        });
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldName(String label, String hint, bool checkTextDate,
      {required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textEditing1Controller,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildTextFieldUsername(String label, String hint, bool checkTextDate,
      {required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textEditing2Controller,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildTextFieldPhone(String label, String hint, bool checkTextDate,
      {required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textEditing3Controller,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildTextFieldBirthday(String label, String hint, bool checkTextDate,
      {required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textEditing4Controller,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> _selectDate(User user) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return ValueListenableBuilder(
          valueListenable: _appManager.themeModeNotifier,
          builder: (_, valueTheme, __) {
            return Theme(
              data: valueTheme
                  ? ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.red, // Màu của header
                        onPrimary: Colors.white, // Màu của text trong header
                        surface: Colors.pink[50]!, // Màu nền của picker
                        onSurface:
                            Colors.black, // Màu của text và icon trong picker
                      ),
                      dialogBackgroundColor: Colors.white, // Màu nền của dialog
                    )
                  : ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: Colors.deepPurple, // Màu của header
                        onPrimary: Colors.white, // Màu của text trong header
                        surface: Colors.grey[800]!, // Màu nền của picker
                        onSurface:
                            Colors.white, // Màu của text và icon trong picker
                      ),
                      dialogBackgroundColor:
                          Colors.grey[900], // Màu nền của dialog
                    ),
              child: child!,
            );
          },
        );
      },
    );
    if (pickedDate != null) {
      final formattedTime = DateFormat('dd/MM/yyyy').format(pickedDate);
      textEditing4Controller.text = formattedTime;
      UserManager.userNotifier.value = user.copyWith(birthday: formattedTime);
    }
  }
}
