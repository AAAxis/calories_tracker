import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calories_tracker/core/services/auth_service.dart';

class ImagePickerController extends ChangeNotifier {
  File? _image;
  bool _isUploading = false;
  
  File? get image => _image;
  bool get isUploading => _isUploading;
  
  // Pick and upload image to Firebase Storage
  Future<void> getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
      
      // Auto-upload to Firebase Storage
      await uploadProfileImage();
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }
  
  // Upload image to Firebase Storage and update user profile
  Future<void> uploadProfileImage() async {
    if (_image == null) return;
    
    final user = AuthService.currentUser;
    if (user == null) return;
    
    try {
      _isUploading = true;
      notifyListeners();
      
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      
      // Upload the image
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      // Update user profile with the new photo URL
      await user.updatePhotoURL(downloadURL);
      
      // Also save to Firestore for additional user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'photoURL': downloadURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (kDebugMode) {
        print('Profile image uploaded successfully: $downloadURL');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
  
  void clearImage() {
    _image = null;
    notifyListeners();
  }
}
