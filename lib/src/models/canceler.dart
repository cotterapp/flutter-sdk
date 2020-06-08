class Canceler {
  bool canceled;
  Canceler({this.canceled});
  void cancel() {
    this.canceled = true;
  }
}
