import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workos/core/services/global_method.dart';
import 'package:workos/views/login/view.dart';

import '../../core/constant.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNamedController = TextEditingController();
  final positionController = TextEditingController();
  final phoneNumberController = TextEditingController();
  bool obscureText = true;
  final signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? url;

  FocusNode fullNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode positionFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();

  @override
  void dispose() {
    animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNamedController.dispose();
    positionController.dispose();
    phoneNumberController.dispose();
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    positionFocusNode.dispose();
    phoneNumberFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              animationController.reset();
              animationController.forward();
            }
          });
    animationController.forward();
    super.initState();
  }

  void submitFormOnRegister() async {
    final isValid = signUpFormKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if(imageFile == null){
        GlobalMethods.showErrorDialog(error: 'Please pick up an image', context: context);
        return;
      }
      setState(() {
        isLoading = true;
      });
      try{
        await auth.createUserWithEmailAndPassword(
            email: emailController.text.toLowerCase().trim(),
            password: passwordController.text.trim());
        final User? user = auth.currentUser;
        final uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('user Image').child('${uid}jpg');
        await ref.putFile(imageFile!);
        url= await ref.getDownloadURL();
       await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id':uid,
          'name':fullNamedController.text,
          'email':emailController.text,
          'image':url,
          'phoneNumber':phoneNumberController.text,
          'positionInCompany': positionController.text,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }catch(error){
       GlobalMethods.showErrorDialog(error: error.toString(), context: context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Form unValid');
      setState(() {
        isLoading = false;
      });
    }
  }






  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl:
                "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
            placeholder: (context, url) => Image.asset(
              "assets/images/wallpaper.jpg",
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: FractionalOffset(animation.value, 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                const Text(
                  "SignUp",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: 'Already have an account?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(text: '   '),
                    TextSpan(
                      text: 'Login',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade300,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ]),
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Form(
                  key: signUpFormKey,
                  child: Column(children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field Can\'t be missing';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            focusNode: fullNameFocusNode,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(emailFocusNode),
                            controller: fullNamedController,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Full name",
                              hintStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.pink.shade700,
                                ),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: size.width * 0.24,
                                  height: size.width * 0.24,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: imageFile == null
                                        ? Image.network(
                                            'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                                            fit: BoxFit.fill,
                                          )
                                        : Image.file(
                                            imageFile!,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: showImageDialog,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      border: Border.all(
                                          width: 2, color: Colors.white),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        imageFile == null
                                            ? Icons.add_a_photo
                                            : Icons.edit_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter a valid Email address';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: emailFocusNode,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(phoneNumberFocusNode),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink.shade700,
                          ),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field Can\'t be missing';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: phoneNumberFocusNode,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(passwordFocusNode),
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Phone number",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink.shade700,
                          ),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      obscureText: obscureText,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Please Enter a valid Password';
                        }
                        return null;
                      },
                      focusNode: passwordFocusNode,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(positionFocusNode),
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          child: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: obscureText ? Colors.pink : Colors.white,
                          ),
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink.shade700,
                          ),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        showJobsDialog(size);
                      },
                      child: TextFormField(
                        enabled: false,
                        onEditingComplete: submitFormOnRegister,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field Can\'t be missing';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        focusNode: positionFocusNode,
                        controller: positionController,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Position in the company",
                          hintStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pink.shade700,
                            ),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 40,
                ),
                isLoading
                    ? Center(
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(color: Colors.pink[800],),
                        ),
                      )
                    : MaterialButton(
                        onPressed: submitFormOnRegister,
                        color: Colors.pink.shade700,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: BorderSide.none,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void pickImageWithCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    File? img = File(pickedFile!.path);
    img = await _cropImage(filePath: img);
    setState(() {
      imageFile = File(pickedFile.path);
    });
    Navigator.pop(context);
  }

  void pickImageWithGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    File? img = File(pickedFile!.path);
    img = await _cropImage(filePath: img);
    setState(() {
      imageFile = img;
    });
    Navigator.pop(context);
  }

  Future<File?> _cropImage({required File filePath}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: filePath.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  // void _cropImage(filePath) async {
  //  CroppedFile cropImage = await ImageCropper().cropImage(
  //     sourcePath: filePath,
  //     maxHeight: 1080,
  //     maxWidth: 1080,
  //   );
  //   if(cropImage !=null){
  //     setState((){
  //
  //       imageFile = cropImage;
  //     });
  //
  //   }
  //
  // }

  void showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: pickImageWithCamera,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: pickImageWithGallery,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showJobsDialog(size) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Jobs',
              style: TextStyle(
                color: Colors.pink[300],
                fontSize: 20,
              ),
            ),
            content: SizedBox(
              width: size.width * 0.1,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.jobsList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          positionController.text = Constants.jobsList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red[200],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Constants.jobsList[index],
                              style: TextStyle(
                                color: Constants.darkBlue,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel filter'),
              ),
            ],
          );
        });
  }
}
