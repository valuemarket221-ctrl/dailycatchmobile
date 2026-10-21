plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

import java.util.Properties
import java.io.FileInputStream
import java.util.Base64

val isDemoBuild = (project.findProperty("dart-defines") as? String)
    ?.split(",")?.any {
        String(Base64.getDecoder().decode(it)) == "DEMO_MODE=true"
    } ?: false
val hasFirebaseConfig = file("google-services.json").exists()
if (!isDemoBuild && hasFirebaseConfig) apply(plugin = "com.google.gms.google-services")

gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release") } && !hasFirebaseConfig) {
        throw GradleException("Release builds require android/app/google-services.json")
    }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val hasReleaseKeystore =
    keystoreProperties["keyAlias"] != null &&
    keystoreProperties["keyPassword"] != null &&
    keystoreProperties["storeFile"] != null &&
    keystoreProperties["storePassword"] != null

android {
    namespace = "com.dailycatch.app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.dailycatch.app"
        if (isDemoBuild) applicationIdSuffix = ".demo"
        manifestPlaceholders["appLabel"] = if (isDemoBuild) "DailyCatch Demo" else "DailyCatch"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}
