enum VegType {
  all('all'),
  veg('veg'),
  nonVeg('non_veg');

  const VegType(this.value);

  final String value;

  static VegType fromValue(String? value) {
    return VegType.values.firstWhere((VegType type) => type.value == value, orElse: () => VegType.all);
  }
}
