# cotter

A Flutter SDK for Cotter's Authentication Services. This package helps you add passwordless login to your app using the following methods:
- [x] Sign in with device
- [x] Sign in with email using OTP
- [x] Sign in with phone number using OTP
- [ ] Sign in with email using magic link
- [ ] Sign in with phone number magic link

## Getting Started

As mentioned, there are 3 different ways to authenticate users. You can also combine the authentication methods, for example: Register the user after verifying their emails, then use Sign in with device for subsequent logins.

To use this SDK, you can [create a free account at Cotter](https://dev.cotter.app) to get your API keys.

# Sign in with device
Signing in with device works like Google Prompt. It allows users to sign in to your website or app automatically from a device that they trust, or in one-tap by approving the login request from your app.

### Signing Up
To register a new user, we need to create a new user in Cotter and register the current device as trusted.
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.signUpWithDevice(identifier: emailAddress);

  // You can also verify the user's email here, check 
  // "Sign in with Email > Verify Email for a logged-in user" below
  user = await user.verifyEmailWithOTP(redirectURL: "myexample://auth_callback");
} catch(e) {
  print(e);
}
```

### Signing In
To authenticate your user, the SDK will check and verify if the current device is trusted. If it is trusted, users can sign in automatically. 

```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var event = await cotter.signInWithDevice(
    identifier: emailAddress,
    context: context,
  );
} catch(e) {
  print(e);
}
if (event.approved) {
  _goToDashboard();
}
```

**Signing in from a Trusted Device**

If the user signed-in from a trusted device, the event will automatically be approved and the user can proceed to the dashboard.

**Signing in from a Non-Trusted Device**

Otherwise, the SDK will show a prompt that asks the user to approve the login from the device that they trust. Inside your app in the trusted device, the SDK will show a prompt asking if the user want to approve the login.

```dart
// Show prompt to approve the login from the trusted device
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.getUser();
  var event = await user.checkNewSignInRequest(context: context);
} catch(e) {
  print(e);
}
```

# Sign in with Email / Phone Number

You can authenticate users by sending a verification code to their email/phone and checking if they can enter the code correctly. Ideally, you would combine this method with the **sign up with device** method above. For example, there are several flows that you can use:
1. Sign up and authenticate solely by sending a verification code to the user's email.
2. Verify the user's email, then register user's device as trusted. Subsequent logins using sign in with device.
3. Sign up with user's device, then verify user's email after registration. Subsequent logins using sign in with device.

## Setup

The email and phone number verification uses OAuth PKCE flow, which requires the app to open a secure in-app browser to authenticate and redirect back to the app with an authorization code. 

**To do this, you need to set up deep-linking**.

### Deep-linking in iOS

Example URL: `myexample://auth_callback`. Add the following to your `ios/Runner/Info.plist`.
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>myexample</string> <!-- 👈 Change this to your own URL Scheme -->
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myexample</string> <!-- 👈 Change this to your own URL Scheme -->
    </array>
  </dict>
</array>
```

### Deep-linking in Android

Example URL: `myexample://auth_callback`. Add the following to your `android/app/src/main/AndroidManifest.xml`.
```xml
<manifest ...>
    <application ...>

    <!-- Add the lines from here -->
    <activity android:name=".CallbackActivity" >
      <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- This is for myexample://auth_callback -->
        <!-- 👇 Change this to your own URL scheme -->
        <data android:scheme="myexample" android:host="auth_callback"/>
      </intent-filter>
    </activity>
    <!-- Until here -->

  </application>
</manifest>
```

### Testing deep-linking

Enter `myexample://auth_callback` in the simulator's browser and see if it redirects to your app.

## Sign in with Email

Make sure you have set up the deep-linking above.

### Signing Up

This method will:
- Verify the user's email
- Then create a new user in Cotter if successful

```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.signUpWithEmailOTP(
    redirectURL: "myexample://auth_callback",
    email: inputController.text, // Optional, if you leave this blank, user can enter email in the in-app browser
  );

  // If you want to follow flow 2 above, you can register the user's device as trusted here
  user = await user.registerDevice();
} catch(e) {
  print(e);
}
```

### Signing in
To authenticate by verifying user's email:
> This method will create a new user if one doesn't exist.
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.signInWithEmailOTP(
        redirectURL: "myexample://auth_callback",
        email: inputController.text, // Optional, if you leave this blank, user can enter email in the in-app browser
      );
} catch(e) {
  print(e);
}
```

### Verify Email for a logged-in user
To verify the email of a user that is currently logged-in:
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.getUser();
  user = await user.verifyEmailWithOTP(redirectURL: "myexample://auth_callback");
} catch (e) {
  print(e);
}
```

## Sign in with Phone

Make sure you have set up the deep-linking above.

### Signing Up

This method will:
- Verify the user's phone number
- Then create a new user in Cotter if successful

**Option 1:** You want to use Cotter's input form inside the in-app browser. This helps with validating the input.
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.signUpWithPhoneOTP(
    redirectURL: "myexample://auth_callback",
    channels: [PhoneChannel.SMS, PhoneChannel.WHATSAPP], // optional, default is SMS
  );
} catch (e) {
  print(e);
}
```

**Option 2:** You want to use your own input form and buttons. You can present 2 buttons to allow sending the OTP via WhatsApp or SMS.
- Using SMS:
```dart
try {
  var user = await cotter.signUpWithPhoneOTPViaSMS(
              redirectURL: "myexample://auth_callback",
              phone: inputController.text,
            );
} catch (e) {
  print(e);
}
```

- Using WhatsApp:
```dart
try {
  var user = await cotter.signUpWithPhoneOTPViaWhatsApp(
              redirectURL: "myexample://auth_callback",
              phone: inputController.text,
            );
} catch (e) {
  print(e);
}
```

### Signing In

To authenticate by verifying user's phone number:

**Option 1:** You want to use Cotter's input form inside the in-app browser. This helps with validating the input.
> This method will create a new user if one doesn't exist.
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.signInWithPhoneOTP(
    redirectURL: "myexample://auth_callback",
    channels: [PhoneChannel.SMS, PhoneChannel.WHATSAPP], // optional, default is SMS
  );
} catch (e) {
  print(e);
}
```

**Option 2:** You want to use your own input form and buttons. You can present 2 buttons to allow sending the OTP via WhatsApp or SMS.
- Using SMS:
```dart
try {
  var user = await cotter.signInWithPhoneOTPViaSMS(
              redirectURL: "myexample://auth_callback",
              phone: inputController.text,
            );
} catch (e) {
  print(e);
}
```

- Using WhatsApp:
```dart
try {
  var user = await cotter.signInWithPhoneOTPViaWhatsApp(
              redirectURL: "myexample://auth_callback",
              phone: inputController.text,
            );
} catch (e) {
  print(e);
}
```

### Verify Phone for a logged-in user

To verify the phone number of a user that is currently logged-in:

- Using SMS:
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.getUser();
  user = await user.verifyPhoneWithOTPViaSMS(redirectURL: "myexample://auth_callback");
} catch (e) {
  print(e);
}
```

- Using WhatsApp:
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.getUser();
  user = await user.verifyPhoneWithOTPViaWhatsApp(redirectURL: "myexample://auth_callback");
} catch (e) {
  print(e);
}
```

# Getting the logged-in user

The SDK automatically stores OAuth tokens (access token, id token, and refresh token) in the device's secure storage, along with the user information.

To get the logged-in user information:
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user = await cotter.getUser();
} catch(e) {
  print(e);
}
```

# Getting OAuth Tokens

The SDK can fetch stored tokens for you and refresh them as needed if they're expired.

```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var accessToken = await cotter.getAccessToken();
  var idToken = await cotter.getIDToken();
  var refreshToken = await cotter.getRefreshToken();
} catch (e) {
  print(e);
}
```
