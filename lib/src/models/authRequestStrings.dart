class AuthRequestStrings {
  final String title;
  final String subtitle;
  final String imagePath;

  AuthRequestStrings({
    this.title = "Approve this login from your phone",
    this.subtitle =
        "A notification is sent to your trusted phone to confirm it's you.",
    this.imagePath = "assets/images/tap_device.png",
  });
}
