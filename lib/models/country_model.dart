class CountryModel {
  final String name;
  final String flag;
  final String currency;
  final String currencySymbol;
  final String localLanguage;
  final String regionLabel;
  final double defaultPricePerKg;

  const CountryModel({
    required this.name,
    required this.flag,
    required this.currency,
    required this.currencySymbol,
    required this.localLanguage,
    required this.regionLabel,
    required this.defaultPricePerKg,
  });
}