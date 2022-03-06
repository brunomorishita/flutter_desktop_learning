String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String ret = "";

  int hour = duration.inHours.remainder(24);
  int minute = duration.inMinutes.remainder(60);
  int second = duration.inSeconds.remainder(60);
  int milissecond = duration.inMilliseconds.remainder(1000);

  String twoDigitHours = twoDigits(hour);
  String twoDigitMinutes = twoDigits(minute);
  String twoDigitSeconds = twoDigits(second);
  String twoDigitMilliseconds = twoDigits(milissecond);

  if (hour > 0) {
    ret += twoDigitHours + ":";
  }

  if (minute > 0) {
    ret += twoDigitMinutes + ":";
  }

  if (second > 0) {
    ret += twoDigitSeconds + ".";
  }

  if (milissecond > 0) {
    ret += twoDigitMilliseconds;
  }

  return ret;
}