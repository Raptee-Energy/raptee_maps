String convertRemainingTimeHHMM(int minutes) {
  final int hours = (minutes ~/ 60);
  final int remainingMinutes = minutes % 60;

  if (hours > 0) {
    if (remainingMinutes > 0) {
      return '${hours}H $remainingMinutes Mins';
    } else {
      return '${hours}H';
    }
  } else {
    return '$remainingMinutes Mins';
  }
}
