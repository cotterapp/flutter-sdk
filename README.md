# cotter

A Flutter SDK for Cotter's Authentication Services. This package helps you add passwordless login to your app using the following methods:
- [x] Sign in with device
- [ ] Sign in with email
- [ ] Sign in with phone number

## Getting Started

As mentioned, there are 3 different ways to authenticate users. You can also combine the authentication methods, for example: Register the user after verifying their emails, then use Sign in with device for subsequent logins.

To use this SDK, you can [create a free account at Cotter](https://dev.cotter.app) to get your API keys.

## Sign in with device
Signing in with device works like Google Prompt. It allows users to sign in to your website or app automatically from a device that they trust, or in one-tap by approving the login request from your app.

### Signing Up
To register a new user, we need to create a new user in Cotter and register the current device as trusted.
```dart
Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
try {
  var user =
          await cotter.signUpWithDevice(identifier: emailAddress);
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

### Getting the logged-in user

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

### Getting OAuth Tokens

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