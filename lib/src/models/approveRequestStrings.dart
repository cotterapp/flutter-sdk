class ApproveRequestStrings {
  final String title;
  final String subtitle;
  final String logoPath;
  final String approve;
  final String reject;

  ApproveRequestStrings({
    this.title = "Are you trying to sign in?",
    this.subtitle =
        "Someone is trying to sign in to your account from another device.",
    this.logoPath = "assets/images/logo.png",
    this.approve = "Yes",
    this.reject = "No, it's not me",
  });
}
