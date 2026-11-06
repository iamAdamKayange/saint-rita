import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
require(keystorePropertiesFile.isFile) {
    "Release signing config is missing: android/key.properties"
}
keystorePropertiesFile.inputStream().use(keystoreProperties::load)

val releaseKeyAlias = requireNotNull(keystoreProperties.getProperty("keyAlias")) {
    "keyAlias is missing from android/key.properties"
}
val releaseKeyPassword = requireNotNull(keystoreProperties.getProperty("keyPassword")) {
    "keyPassword is missing from android/key.properties"
}
val releaseStorePassword = requireNotNull(keystoreProperties.getProperty("storePassword")) {
    "storePassword is missing from android/key.properties"
}
val releaseStoreFile = file(requireNotNull(keystoreProperties.getProperty("storeFile")) {
    "storeFile is missing from android/key.properties"
})
require(releaseStoreFile.isFile) {
    "Release keystore was not found at: ${releaseStoreFile.absolutePath}"
}

android {
    namespace = "com.adamkayange.novenasaintrita"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.adamkayange.novenasaintrita"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
            storeFile = releaseStoreFile
            storePassword = releaseStorePassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}