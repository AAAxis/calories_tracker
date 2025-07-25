import java.util.Properties
import java.io.FileInputStream

// Add this at the top, before any other code
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

buildscript {
    repositories {
        google()  // Ensure Google repository is included
        mavenCentral()
    }
    dependencies {
        // Use the correct syntax for Kotlin DSL
        classpath("com.google.gms:google-services:4.3.15")  // Firebase plugin for Gradle
    }
}

android {
    namespace = "com.theholylabs.kaliai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
    defaultConfig {
        multiDexEnabled = true
        applicationId = "com.theholylabs.kaliai"
        minSdkVersion(26)
        targetSdk = flutter.targetSdkVersion
        versionCode = 392 // 🔁 Increase this by 1 for each new build
        versionName = "3.5"  // 🆕 This is your human-readable version
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    // Enable core library desugaring and add the necessary dependencies
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

flutter {
    source = "../.."
}

// Apply the Firebase plugin
apply(plugin = "com.google.gms.google-services")

dependencies {
    // Firebase SDK (adjust as needed for the Firebase services you want to use)
    implementation(platform("com.google.firebase:firebase-bom:32.7.2"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // RevenueCat SDK
    implementation("com.revenuecat.purchases:purchases:7.9.0")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // Update desugaring dependency to version 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")  // Updated desugaring dependency
}