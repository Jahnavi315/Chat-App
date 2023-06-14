// ignore_for_file: avoid_print

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;//firebase obj to use for entire code

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredUsername = '';
  String _enteredPassword = '';
  File? _selectedImage;
  bool _isAuthenticating = false;

  void _submit() async{
    if(!_formKey.currentState!.validate() ||(!_isLogin && _selectedImage == null)){//triggers all validators
     return;
    }
    _formKey.currentState!.save();//triggers onSaved
    //for signing up
    //behind the scenes this method sends HTTP req to firebase
    try{
      setState(() {
        _isAuthenticating = true;
      });
      if(_isLogin){
        //log in users
        final userCredentials = await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail, 
        password: _enteredPassword
        );
        print('user credentials');
        print(userCredentials);
      }else{
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword
          );
          //user cant be null
          //ref gives obj(reference) that gives access to our firebase cloud storage,
          //child can create a new path in our storage bucket
        final storageRef = FirebaseStorage
              .instance.ref()
              .child('user_images')
              .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);//waits till the upload completes
        final imageUrl = await storageRef.getDownloadURL();//can get the URL as well 
        print('new user credentials');
        print(userCredentials);
        print(imageUrl); 
        await FirebaseFirestore
          .instance.collection('users')
          .doc(userCredentials.user!.uid)//wt name is given it uses that
          .set({
            'username' : _enteredUsername,
            'email' : _enteredEmail,
            'imageurl' : imageUrl,
          });
        //collections - folders contains documents - data entries
      }
      }on FirebaseAuthException catch(exception){
        print(exception);
        if(exception.code == 'email-already-in-use'){
          //do sthg similarly for others if reqd
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(exception.message ?? 'Authentication Failed')
          )
        );
        setState(() {
        _isAuthenticating = false;
      });
      }
      print(_enteredEmail);
      print(_enteredPassword);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center( 
        child: SingleChildScrollView( 
          child: Column(  
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              Container( 
                margin: const EdgeInsets.fromLTRB(20,30,20,20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card( 
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView( 
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column( 
                        mainAxisSize: MainAxisSize.min,
                        children: [ 
                          if(!_isLogin)
                          UserImagePicker(onPickImage: (image) {
                            _selectedImage = image ;
                          },
                          ),
                          TextFormField( 
                            decoration: const InputDecoration( 
                              contentPadding: EdgeInsets.only(top: 10,bottom: 20),
                              labelText: 'Email Address',
                              labelStyle: TextStyle(
                                fontSize: 22
                              )
                            ),
                            style: const TextStyle( 
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,//first letter wont be capital
                            validator: (value) {
                              if(value == null || value.trim().isEmpty || !value.contains('@')){
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          const SizedBox(height: 10),
                          if(!_isLogin)
                          TextFormField( 
                            decoration: const InputDecoration( 
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                fontSize: 22
                              )
                            ),
                            style: const TextStyle( 
                              fontSize: 20,
                            ),
                            enableSuggestions: false,
                            validator: (value) {
                              if(value == null || value.isEmpty || value.trim().length < 4){
                                return 'Please enter a valid username of atleast 4 characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredUsername = newValue!;
                            },
                          ),
                          TextFormField( 
                            decoration: const InputDecoration( 
                              contentPadding: EdgeInsets.only(top: 10,bottom: 20),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 22
                              )
                            ),
                            style: const TextStyle( 
                              fontSize: 20,
                            ),
                            //keyboardType: TextInputType.emailAddress,
                            obscureText: true,//hides text
                            validator: (value) {
                              if(value == null || value.trim().length<6 ){
                                return 'Password must be atleast 6 characters long';
                              }
                              if(value != value.trim()){
                                return 'Password contains white spaces!';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if(!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit, 
                            style: ElevatedButton.styleFrom( 
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer
                            ),
                            child: Text(_isLogin ?'Login' : 'Signup')
                          )
                          else 
                          const CircularProgressIndicator(),
                          if(!_isAuthenticating)
                          TextButton(
                            onPressed: (){
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            }, 
                            child: Text(_isLogin? 'Create an account' : 'Already have an account. Login')
                          )
                        ],
                      )
                    ),
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}