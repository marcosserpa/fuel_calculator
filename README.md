# fuel_calculator

A Fuel Calculator to be used in Brazil.

## Instructions to publish in Google Play Store

Publishing your Flutter app to the Google Play Store involves several steps. Here's a step-by-step guide to help you through the process:

Step 1: Prepare Your App for Release
  1. Update the App Version:
    º Open pubspec.yaml and update the version field:

```ruby
version: 1.0.0+1
```

  2. Update the App Name and Icon:
    º Open AndroidManifest.xml and update the android:label attribute to your app name.
    º Replace the default Flutter icon with your own app icon. Follow the instructions in the Flutter documentation to do this.
  3. Configure App Signing:
    º Generate a signing key:

```bash
keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

    º Store the key in a safe place.
    º Create a file named key.properties in the android directory with the following content:

```yaml
storePassword=<your-key-password>
keyPassword=<your-key-password>
keyAlias=my-key-alias
storeFile=<path-to-your-keystore-file>
```

    º Update build.gradle to use the key:

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

Step 2: Build the Release APK
  1. Build the APK:
    º Run the following command to build the release APK:

```bash
flutter build apk --release
```

  2. Locate the APK:
    º The APK will be located at build/app/outputs/flutter-apk/app-release.apk.

Step 3: Create a Google Play Developer Account
  1. Sign Up:
    º Go to the Google Play Console and sign up for a developer account.
    º Pay the one-time registration fee.

Step 4: Prepare Store Listing
  1. Create a New App:
    º In the Google Play Console, click on Create App.
    º Enter the app details such as name, language, and default language.
  2. Complete the Store Listing:
    º Fill in the required fields such as app description, screenshots, and app icon.
    º Provide a privacy policy URL if required.

Step 5: Upload the APK
  1. Upload the APK:
    º Go to the Release section in the Google Play Console.
    º Click on Create New Release.
    º Upload the app-release.apk file.

Step 6: Review and Publish
  1. Review:
    º Review all the details and make sure everything is correct.
  2. Submit for Review:
    º Click on Submit for Review.
    º Google will review your app, which may take a few days.

Step 7: Monitor the App
  1. Monitor:
    º Once your app is published, monitor its performance and user feedback through the Google Play Console.

This should guide you through the process of publishing your Flutter app to the Google Play Store. If you have any questions or need further assistance, feel free to ask!