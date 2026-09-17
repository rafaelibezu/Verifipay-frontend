import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()

val localPropertiesFile =
    rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

val verifipayDeviceToken =
    localProperties.getProperty(
        "VERIFIPAY_DEVICE_TOKEN",
        ""
    )

val verifipayApiUrl =
    localProperties.getProperty(
        "VERIFIPAY_API_URL",
        "http://127.0.0.1:8080"
    )

android {
    namespace = "com.example.verifipay_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.verifipay_frontend"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        buildConfigField(
            "String",
            "VERIFIPAY_DEVICE_TOKEN",
            "\"$verifipayDeviceToken\""
        )

        buildConfigField(
            "String",
            "VERIFIPAY_API_URL",
            "\"$verifipayApiUrl\""
        )
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.work:work-runtime:2.10.1")
}