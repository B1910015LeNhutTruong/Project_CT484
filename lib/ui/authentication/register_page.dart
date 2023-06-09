import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject_app/ui/authentication/login_page.dart';
import 'package:myproject_app/ui/widget/my_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../welcome_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool loading = false;
  late UserCredential userCredential;
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();

  String imageURL = "";

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  Future sendData() async {
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      await FirebaseFirestore.instance
          .collection('userData')
          .doc(userCredential.user?.uid)
          .set({
        'fullName': fullName.text,
        'email': email.text.trim(),
        'phoneNumber': phoneNumber.text.trim(),
        // 'password': password.text.trim(),
        'userid': userCredential.user?.uid,
        'image': imageURL,
      });
      //Thông báo đăng ký tài khoản thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Đăng ký tài khoản thành công",
          ),
        ),
      );
      setState(() {
        loading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Mật khẩu quá yếu",
            ),
          ),
        );
        setState(() {
          loading = false;
        });
        return;
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email đã được sử dụng",
            ),
          ),
        );
        setState(() {
          loading = false;
        });
        return;
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  void validation() {
    if (fullName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Họ và tên chưa được điền",
          ),
        ),
      );
      return;
    }

    if (email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email chưa được điền",
          ),
        ),
      );
      return;
    } else {
      const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(pattern);
      if (!regex.hasMatch(email.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email chưa hợp lệ",
            ),
          ),
        );
        return;
      }
    }

    if (phoneNumber.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Số điện thoại chưa được điền",
          ),
        ),
      );
      return;
    } else {
      const pattern = r"^(?:[+0]9)?[0-9]{10}$";
      final regex = RegExp(pattern);
      if (!regex.hasMatch(phoneNumber.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Số điện thoại chưa hợp lệ",
            ),
          ),
        );
        return;
      }
    }

    if (password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mật khẩu chưa được điền",
          ),
        ),
      );
      return;
    } else if (password.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mật khẩu phải có tối thiểu 6 ký tự",
          ),
        ),
      );
      return;
    } else {
      setState(() {
        loading = true;
      });
      sendData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        backgroundColor: const Color(0xff3a3e3e),
        leading: IconButton(
          onPressed: () => {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const WelcomePage()))
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Đăng ký",
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Column(
            children: [
              MyTextField(
                controller: fullName,
                hintTextInput: "Họ và tên",
                icon: Icons.people,
                secureText: false,
              ),
              MyTextField(
                controller: email,
                hintTextInput: "Email",
                icon: Icons.email,
                secureText: false,
              ),
              MyTextField(
                controller: phoneNumber,
                hintTextInput: "Số điện thoại",
                icon: Icons.phone_android,
                secureText: false,
              ),
              MyTextField(
                controller: password,
                hintTextInput: "Mật khẩu",
                icon: Icons.lock_outline,
                secureText: true,
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              final ImagePicker imagePicker = ImagePicker();
              XFile? file =
                  await imagePicker.pickImage(source: ImageSource.gallery);

              print('${file?.path}');

              if (file == null) {
                return;
              }

              String radomFileName =
                  DateTime.now().microsecondsSinceEpoch.toString();

              Reference referenceRoot = FirebaseStorage.instance.ref();
              Reference referenceDirImages = referenceRoot.child('images');

              Reference referenceImageToUpload =
                  referenceDirImages.child(radomFileName);
              try {
                await referenceImageToUpload.putFile(File(file.path));
                imageURL = await referenceImageToUpload.getDownloadURL();
              } catch (error) {
                print(error);
              }
            },
            icon: const Icon(Icons.image),
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3a3e3e),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (imageURL.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Vui lòng chọn ảnh đại diện",
                            ),
                          ),
                        );
                        return;
                      }
                      validation();
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Nếu đã có tài khoản?"),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "Đăng nhập ngay",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
