class DistanceDurationModel {
  final double distanceInKm;
  final int? durationInSecond;

  final bool isFallback;

  DistanceDurationModel({required this.distanceInKm, this.durationInSecond, this.isFallback = false});

  double? get durationInHour => durationInSecond != null ? durationInSecond! / 3600 : null;
}
