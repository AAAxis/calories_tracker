import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

// RevenueCat Configuration
class RevenueCatConfig {
  // Entitlement ID from the RevenueCat dashboard that is activated upon successful in-app purchase
  static const String entitlementID = 'Premium';

  // Your configured offering IDs from RevenueCat dashboard
  static const String defaultOfferingId = 'Sale';
  static const String discountOfferingId = 'Offer';
  static const String proOfferingId = 'Pro';

  // Subscription terms and conditions
  static const footerText =
      """Don't forget to add your subscription terms and conditions.

Read more about this here: https://www.revenuecat.com/blog/schedule-2-section-3-8-b""";

  // Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
  static const String appleApiKey = 'appl_tcPOzrHZKuYPAreNJQMnNOuhVYa';

  // Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
  static const String googleApiKey = 'goog_xrdRhQMmrFhWRVAsIHLBBnSiIfZ';

  // Amazon API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
  static const String amazonApiKey = '';
}

// App Data Singleton for managing subscription state
class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();

class PaywallService {
  // Convenience getters for configuration
  static String get entitlementID => RevenueCatConfig.entitlementID;
  static String get defaultOfferingId => RevenueCatConfig.defaultOfferingId;
  static String get discountOfferingId => RevenueCatConfig.discountOfferingId;
  static String get proOfferingId => RevenueCatConfig.proOfferingId;
  static String get appleApiKey => RevenueCatConfig.appleApiKey;
  static String get googleApiKey => RevenueCatConfig.googleApiKey;
  static String get amazonApiKey => RevenueCatConfig.amazonApiKey;
  static String get footerText => RevenueCatConfig.footerText;

  // Show RevenueCat remote paywall
  // Note: There's a known issue where the paywall doesn't automatically close on successful restore
  // on iOS (see: https://github.com/RevenueCat/purchases-flutter/issues/1161)
  // The paywall should return PaywallResult.restored when restore is successful, even if it doesn't auto-close
  // Set forceCloseOnRestore=true to use PaywallView with custom restore handling that always closes
  static Future<bool> showPaywall(BuildContext context, {String? offeringId, bool forceCloseOnRestore = false}) async {
    // Use custom PaywallView if user wants guaranteed close on restore
    if (forceCloseOnRestore) {
      return showPaywallWithCustomRestore(context, offeringId: offeringId);
    }
    try {
      // Check if we're on a supported platform
      if (!Platform.isIOS && !Platform.isAndroid) {
        print('Paywall not supported on this platform');
        return false;
      }

      print('🔍 Showing RevenueCat remote paywall...');
      print('🎯 Using offering ID: ${offeringId ?? 'default'}');

      // Get the offering object if offeringId is provided
      Offering? offering;
      if (offeringId != null) {
        try {
          final offerings = await Purchases.getOfferings();

          // Debug: Print all available offerings
          print('🔍 Available offerings:');
          for (var entry in offerings.all.entries) {
            print('  - ${entry.key}: ${entry.value.identifier}');
          }
          print('🔍 Current offering: ${offerings.current?.identifier ?? 'none'}');

          offering = offerings.all[offeringId];
          if (offering == null) {
            print('⚠️ Offering "$offeringId" not found, using default offering');
            print('💡 Available offering IDs: ${offerings.all.keys.toList()}');
          } else {
            print('✅ Found offering: ${offering.identifier}');
          }
        } catch (e) {
          print('❌ Error fetching offering: $e');
        }
      }

      // Use RevenueCatUI.presentPaywallIfNeeded method for remote paywall
      final paywallResult = offering != null
        ? await RevenueCatUI.presentPaywallIfNeeded(entitlementID, offering: offering)
        : await RevenueCatUI.presentPaywallIfNeeded(entitlementID);

      print('📊 Paywall result: $paywallResult');

      if (paywallResult == PaywallResult.purchased) {
        print('✅ User made a purchase!');
        appData.entitlementIsActive = true;
        return true;
      } else if (paywallResult == PaywallResult.cancelled) {
        print('❌ User cancelled the paywall');
        return false;
      } else if (paywallResult == PaywallResult.notPresented) {
        print('ℹ️ Paywall not presented - user already has entitlement');
        appData.entitlementIsActive = true;
        return true;
      } else if (paywallResult == PaywallResult.error) {
        print('❌ Error presenting paywall');
        return false;
      } else if (paywallResult == PaywallResult.restored) {
        print('✅ User restored purchases!');
        appData.entitlementIsActive = true;
        // Check subscription status after restore to ensure it's properly updated
        await hasActiveSubscription();
        return true;
      }

      return false;
    } on PlatformException catch (e) {
      print('❌ Platform error showing paywall: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Unexpected error showing paywall: $e');
      return false;
    }
  }

  // Show RevenueCat remote paywall with referral code consideration
  static Future<bool> showPaywallWithReferral(BuildContext context, {String? referralCode}) async {
    try {
      print('🔍 Showing paywall with referral consideration...');
      print('🎯 Referral code: ${referralCode ?? 'none'}');

      // If referral code is provided, set the custom attribute first
      if (referralCode != null) {
        await Purchases.setAttributes({
          'referral_code_used': referralCode,
        });
        print('✅ Set RevenueCat custom attribute: referral_code_used = $referralCode');
      }

      // Let RevenueCat determine which offering to show based on the custom attributes
      // RevenueCat will use your dashboard rules to decide which offering to present
      print('🎯 Letting RevenueCat determine offering based on custom attributes');

      // Show the paywall without specifying an offering - let RevenueCat decide
      return await showPaywall(context);

    } catch (e) {
      print('❌ Error showing paywall with referral: $e');
      // Fallback to regular paywall
      return await showPaywall(context);
    }
  }

  // Present promo code redemption sheet (iOS only)
  static Future<bool> presentPromoCodeRedemption(BuildContext context) async {
    try {
      if (!Platform.isIOS) {
        print('⚠️ Promo code redemption is only supported on iOS');
        _showAndroidPromoCodeDialog(context);
        return false;
      }

      print('🎟️ Presenting promo code redemption sheet...');

      // Present the iOS promo code redemption sheet
      await Purchases.presentCodeRedemptionSheet();

      // Since presentCodeRedemptionSheet has no callback, we need to listen for customer info updates
      // The calling code should listen to customer info updates to detect successful redemption
      return true;

    } on PlatformException catch (e) {
      print('❌ Error presenting promo code redemption: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Unexpected error presenting promo code redemption: $e');
      return false;
    }
  }

  // Show Android-specific promo code dialog (since Android doesn't support discount codes)
  static void _showAndroidPromoCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Promo Codes'),
          content: const Text(
            'Discount promo codes are not supported on Android. '
            'However, you can check our special offers in the subscription options!'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showPaywall(context); // Show paywall with potential offers
              },
              child: const Text('View Offers'),
            ),
          ],
        );
      },
    );
  }

  // Create a promo code URL for iOS (for sharing via email, social media, etc.)
  static String createPromoCodeURL(String promoCode) {
    if (Platform.isIOS) {
      // iOS promo code URL format
      return 'https://apps.apple.com/redeem?ctx=offercodes&id=YOUR_APP_ID&code=$promoCode';
    } else {
      // Android doesn't support promo codes, but you can create a custom URL
      return 'https://your-app-website.com/promo/$promoCode';
    }
  }

  // Check if user has active subscription
  static Future<bool> hasActiveSubscription() async {
    try {
      print('🔍 Checking subscription status...');
      
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementID];
      
      final isActive = entitlement?.isActive ?? false;
      appData.entitlementIsActive = isActive;
      
      print('📊 Subscription status: ${isActive ? 'Active' : 'Inactive'}');
      print('📊 Entitlement: ${entitlement?.identifier ?? 'None'}');
      print('📊 Expires: ${entitlement?.expirationDate ?? 'Never'}');
      
      return isActive;
    } catch (e) {
      print('❌ Error checking subscription status: $e');
      return false;
    }
  }

  // Check if user has active subscription for specific entitlement
  static Future<bool> hasActiveSubscriptionForEntitlement(String entitlementId) async {
    try {
      print('🔍 Checking subscription status for entitlement: $entitlementId');
      
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      
      final isActive = entitlement?.isActive ?? false;
      
      print('📊 Subscription status for $entitlementId: ${isActive ? 'Active' : 'Inactive'}');
      
      return isActive;
    } catch (e) {
      print('❌ Error checking subscription status for $entitlementId: $e');
      return false;
    }
  }

  // Initialize RevenueCat
  static Future<void> initialize() async {
    try {
      print('🚀 Initializing RevenueCat...');
      
      // Configure RevenueCat with your API keys
      if (Platform.isIOS) {
        await Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(PurchasesConfiguration(appleApiKey));
        print('✅ RevenueCat initialized for iOS');
      } else if (Platform.isAndroid) {
        await Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(PurchasesConfiguration(googleApiKey));
        print('✅ RevenueCat initialized for Android');
      }
      
      // Check initial subscription status
      await hasActiveSubscription();
      
    } catch (e) {
      print('❌ Error initializing RevenueCat: $e');
    }
  }

  // Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      print('🔄 Restoring purchases...');
      
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementID];
      
      final isActive = entitlement?.isActive ?? false;
      appData.entitlementIsActive = isActive;
      
      print('📊 Restore result: ${isActive ? 'Success' : 'No active subscriptions found'}');
      
      return isActive;
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      return false;
    }
  }

  // Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      print('❌ Error getting customer info: $e');
      return null;
    }
  }

  // Set user ID for RevenueCat
  static Future<void> setUserID(String userID) async {
    try {
      await Purchases.logIn(userID);
      appData.appUserID = userID;
      print('✅ User ID set: $userID');
    } catch (e) {
      print('❌ Error setting user ID: $e');
    }
  }

  // Get current user ID
  static String getCurrentUserID() {
    return appData.appUserID;
  }

  // Show custom paywall with guaranteed close on restore
  static Future<bool> showPaywallWithCustomRestore(BuildContext context, {String? offeringId}) async {
    try {
      print('🔍 Showing custom paywall with restore handling...');
      
      // Get the offering
      Offering? offering;
      if (offeringId != null) {
        final offerings = await Purchases.getOfferings();
        offering = offerings.all[offeringId];
      }
      
      // Show custom paywall dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PaywallDialog(
            offering: offering,
            onRestore: () async {
              final restored = await restorePurchases();
              if (restored) {
                Navigator.of(context).pop(true);
              }
            },
          );
        },
      );
      
      return result ?? false;
    } catch (e) {
      print('❌ Error showing custom paywall: $e');
      return false;
    }
  }

  // Get current customer's custom attributes
  static Future<Map<String, String>> getCustomerAttributes() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // Note: RevenueCat doesn't directly expose custom attributes in Flutter SDK
      // This is a placeholder - you might need to track attributes separately
      // or use the RevenueCat REST API to fetch them
      return {};
    } catch (e) {
      print('❌ Error getting customer attributes: $e');
      return {};
    }
  }

  // Check if customer has specific referral code attribute
  static Future<bool> hasReferralCode(String code) async {
    try {
      // Since RevenueCat Flutter SDK doesn't expose custom attributes directly,
      // you might need to store this information locally or use REST API
      // For now, we'll assume the attribute was set if the code was used in this session
      return true; // Placeholder implementation
    } catch (e) {
      print('❌ Error checking referral code: $e');
      return false;
    }
  }

  // Debug method to check what offering RevenueCat would show
  static Future<void> debugCurrentOffering() async {
    try {
      print('🔍 Debug: Checking current offering from RevenueCat...');
      
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      
      print('🔍 Current offering: ${currentOffering?.identifier ?? 'none'}');
      print('🔍 Available offerings:');
      for (var entry in offerings.all.entries) {
        print('  - ${entry.key}: ${entry.value.identifier}');
        print('    Packages: ${entry.value.availablePackages.map((p) => p.identifier).join(', ')}');
      }
      
      // Also check customer info
      final customerInfo = await Purchases.getCustomerInfo();
      print('🔍 Customer ID: ${customerInfo.originalAppUserId}');
      print('🔍 Active entitlements: ${customerInfo.entitlements.active.keys.join(', ')}');
      
    } catch (e) {
      print('❌ Error checking current offering: $e');
    }
  }
}

// Custom Paywall Dialog Widget
class PaywallDialog extends StatefulWidget {
  final Offering? offering;
  final VoidCallback onRestore;

  const PaywallDialog({
    Key? key,
    this.offering,
    required this.onRestore,
  }) : super(key: key);

  @override
  State<PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends State<PaywallDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upgrade to Premium'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Get unlimited meal tracking and analysis!'),
          const SizedBox(height: 20),
          if (widget.offering != null) ...[
            ...widget.offering!.availablePackages.map((package) {
              return ListTile(
                title: Text(package.storeProduct.title),
                subtitle: Text(package.storeProduct.description),
                trailing: Text(package.storeProduct.priceString),
                onTap: () => _purchasePackage(package),
              );
            }).toList(),
          ] else ...[
            const Text('Loading packages...'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : widget.onRestore,
          child: const Text('Restore Purchases'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isLoading = true);
    
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final entitlement = customerInfo.entitlements.all[PaywallService.entitlementID];
      
      if (entitlement?.isActive ?? false) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Error purchasing package: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}