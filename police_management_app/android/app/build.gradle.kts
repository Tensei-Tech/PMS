plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.tenseitech.khakhidiary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required for flutter_local_notifications (Java 8+ APIs)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.tenseitech.khakhidiary"
        // Domain 6: Explicit minSdk 23 required for flutter_secure_storage AES-256 encryption.
        // Do NOT lower this — it will disable hardware-backed keystore encryption.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // TODO (Production): Replace with a real keystore before Play Store release.
        // Generate with: keytool -genkey -v -keystore khakhidiary.jks -keyalg RSA -keysize 4096 -validity 10000 -alias khakhidiary
        // Then set KHAKHI_STORE_FILE, KHAKHI_STORE_PASSWORD, KHAKHI_KEY_ALIAS, KHAKHI_KEY_PASSWORD
        // as environment variables or in ~/.gradle/gradle.properties (never commit secrets to git).
        getByName("debug") {
            // Debug key is fine for development only.
        }
        // Uncomment when you have a real keystore:
        // create("release") {
        //     storeFile = file(System.getenv("KHAKHI_STORE_FILE") ?: "khakhidiary.jks")
        //     storePassword = System.getenv("KHAKHI_STORE_PASSWORD")
        //     keyAlias = System.getenv("KHAKHI_KEY_ALIAS")
        //     keyPassword = System.getenv("KHAKHI_KEY_PASSWORD")
        // }
    }

    buildTypes {
        release {
            // Domain 6: R8 shrinking + full obfuscation in release builds.
            // Makes reverse engineering extremely difficult.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // TODO: Switch to release signing config when keystore is set up:
            // signingConfig = signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for flutter_local_notifications core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
