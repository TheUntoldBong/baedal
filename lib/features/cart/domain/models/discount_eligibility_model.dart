enum DiscountSource {
  happyHour('happy_hour'),
  restaurantDiscount('restaurant_discount');

  final String value;
  const DiscountSource(this.value);

  String get labelKey => this == DiscountSource.happyHour ? 'happy_hour_discount' : 'restaurant_discount';

  static DiscountSource? fromValue(String? value) {
    for (final DiscountSource source in DiscountSource.values) {
      if (source.value == value) return source;
    }
    return null;
  }
}

class DiscountEligibilityModel {
  final DiscountSource? source;
  final double? percentage;
  final double? minPurchase;
  final double? maxDiscount;
  final double? qualifyingAmount;
  final double? shortfall;
  final bool isQualified;
  final double discountAmount;

  const DiscountEligibilityModel({
    this.source, this.percentage, this.minPurchase, this.maxDiscount,
    this.qualifyingAmount, this.shortfall, this.isQualified = false, this.discountAmount = 0,
  });

  factory DiscountEligibilityModel.fromJson(Map<String, dynamic> json) {
    return DiscountEligibilityModel(
      source: DiscountSource.fromValue(json['source']),
      percentage: double.tryParse('${json['percentage']}'),
      minPurchase: double.tryParse('${json['min_purchase']}'),
      maxDiscount: double.tryParse('${json['max_discount']}'),
      qualifyingAmount: double.tryParse('${json['qualifying_amount']}'),
      shortfall: double.tryParse('${json['shortfall']}'),
      isQualified: json['is_qualified'] == true || json['is_qualified'] == 1,
      discountAmount: double.tryParse('${json['discount_amount']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source?.value, 'percentage': percentage, 'min_purchase': minPurchase,
    'max_discount': maxDiscount, 'qualifying_amount': qualifyingAmount,
    'shortfall': shortfall, 'is_qualified': isQualified, 'discount_amount': discountAmount,
  };
}
