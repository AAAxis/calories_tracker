import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../firebase_options.dart';
import '../store/shared_pref.dart';
import '../services/image_cache_service.dart';

Future<void> initializeApp({
  required VoidCallback onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    // Initialize Firebase with proper error handling
    await _initializeFirebase();
    
    // Initialize RevenueCat
    await _initializeRevenueCat();
    
    // Initialize SharedPreferences
    await SharedPref.init();
    
    // Initialize ImageCacheService
    await ImageCacheService.initialize();

    onSuccess();
  } catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    rethrow; // Re-throw to be caught by main's try-catch
  }
}

Future<void> _initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      print('✅ Firebase already initialized');
      return;
    }
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    if (e.toString().contains('already been initialized') || 
        e.toString().contains('invalid reuse after initialization failure')) {
      print('⚠️ Firebase already initialized, continuing...');
      return;
    }
    print('❌ Error initializing Firebase: $e');
    rethrow;
  }
}

Future<void> _initializeRevenueCat() async {
  try {
    // Set log level for debugging
    await Purchases.setLogLevel(LogLevel.debug);
    
    // Configure RevenueCat with your API keys
    PurchasesConfiguration configuration;
    
    // Replace with your actual RevenueCat API keys
    const String appleApiKey = "appl_tcPOzrHZKuYPAreNJQMnNOuhVYa";
    const String googleApiKey = "goog_xrdRhQMmrFhWRVAsIHLBBnSiIfZ";
    
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey);
    } else {
      configuration = PurchasesConfiguration(googleApiKey);
    }
    
    await Purchases.configure(configuration);
    print('✅ RevenueCat initialized successfully');
  } catch (e) {
    print('❌ Error initializing RevenueCat: $e');
    // Don't throw error, just log it - app should still work without RevenueCat
  }
}
