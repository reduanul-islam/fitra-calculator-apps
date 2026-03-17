class FoodItemModel {
  final String nameBn;
  final String nameEn;
  final String emoji;
  final double fitraKg;
  final Map<String, double> priceByCountry;

  const FoodItemModel({
    required this.nameBn,
    required this.nameEn,
    required this.emoji,
    required this.fitraKg,
    required this.priceByCountry,
  });
}