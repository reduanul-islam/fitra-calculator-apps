import '../models/country_model.dart';
import '../models/food_item_model.dart';
import '../models/madhhab_model.dart';

class MockDataService {
  static List<CountryModel> countries = const [
    CountryModel(
      name: 'Bangladesh',
      flag: '🇧🇩',
      currency: 'BDT',
      currencySymbol: '৳',
      localLanguage: 'বাংলা',
      regionLabel: 'হানাফী',
      defaultPricePerKg: 60,
    ),
    CountryModel(
      name: 'India',
      flag: '🇮🇳',
      currency: 'INR',
      currencySymbol: '₹',
      localLanguage: 'हिन्दी',
      regionLabel: 'হানাফী',
      defaultPricePerKg: 58,
    ),
    CountryModel(
      name: 'Saudi Arabia',
      flag: '🇸🇦',
      currency: 'SAR',
      currencySymbol: 'ر.س',
      localLanguage: 'العربية',
      regionLabel: 'হাম্বলী',
      defaultPricePerKg: 10,
    ),
  ];

  static List<MadhhabModel> sunniMadhhabs = const [
    MadhhabModel(
      nameBn: 'হানাফী',
      nameEn: 'Madhhab al-Hanafiyyah',
      region: 'South Asia',
      rule: 'Cash payment is permitted',
      cashAllowed: true,
    ),
    MadhhabModel(
      nameBn: 'শাফেঈ',
      nameEn: 'Madhhab al-Shafi\'iyyah',
      region: 'Southeast Asia',
      rule: 'Physical food required',
      cashAllowed: false,
    ),
    MadhhabModel(
      nameBn: 'মালেকী',
      nameEn: 'Madhhab al-Malikiyyah',
      region: 'West Africa',
      rule: 'Physical food required',
      cashAllowed: false,
    ),
    MadhhabModel(
      nameBn: 'হাম্বলী',
      nameEn: 'Madhhab al-Hanabilah',
      region: 'Saudi Arabia',
      rule: 'Physical food required',
      cashAllowed: false,
    ),
  ];

  static List<MadhhabModel> shiaMadhhabs = const [
    MadhhabModel(
      nameBn: 'জাফরী',
      nameEn: 'Ja\'fari',
      region: 'Iran, Iraq',
      rule: 'Food or value may be given',
      cashAllowed: true,
    ),
    MadhhabModel(
      nameBn: 'ইথনা আশারী',
      nameEn: 'Ithna Ashari',
      region: 'Shia communities',
      rule: 'Staple food amount applies',
      cashAllowed: true,
    ),
    MadhhabModel(
      nameBn: 'শিয়া মত ১',
      nameEn: 'Shia View 1',
      region: 'Community based',
      rule: 'Local scholar guidance needed',
      cashAllowed: true,
    ),
    MadhhabModel(
      nameBn: 'শিয়া মত ২',
      nameEn: 'Shia View 2',
      region: 'Community based',
      rule: 'Local scholar guidance needed',
      cashAllowed: true,
    ),
  ];

  static List<FoodItemModel> foodItems = const [
    FoodItemModel(
      nameBn: 'গম',
      nameEn: 'Wheat',
      emoji: '🌾',
      fitraKg: 1.75,
      priceByCountry: {
        'Bangladesh': 70,
        'India': 65,
        'Saudi Arabia': 8,
      },
    ),
    FoodItemModel(
      nameBn: 'চাল',
      nameEn: 'Rice',
      emoji: '🍚',
      fitraKg: 1.0,
      priceByCountry: {
        'Bangladesh': 60,
        'India': 58,
        'Saudi Arabia': 10,
      },
    ),
    FoodItemModel(
      nameBn: 'খেজুর',
      nameEn: 'Dates',
      emoji: '🌴',
      fitraKg: 3.0,
      priceByCountry: {
        'Bangladesh': 350,
        'India': 300,
        'Saudi Arabia': 18,
      },
    ),
    FoodItemModel(
      nameBn: 'যব',
      nameEn: 'Barley',
      emoji: '🌿',
      fitraKg: 3.0,
      priceByCountry: {
        'Bangladesh': 90,
        'India': 80,
        'Saudi Arabia': 9,
      },
    ),
    FoodItemModel(
      nameBn: 'কিসমিস',
      nameEn: 'Raisins',
      emoji: '🍇',
      fitraKg: 3.0,
      priceByCountry: {
        'Bangladesh': 480,
        'India': 420,
        'Saudi Arabia': 20,
      },
    ),
    FoodItemModel(
      nameBn: 'বাজরা',
      nameEn: 'Millet',
      emoji: '🌼',
      fitraKg: 2.0,
      priceByCountry: {
        'Bangladesh': 85,
        'India': 75,
        'Saudi Arabia': 8,
      },
    ),
    FoodItemModel(
      nameBn: 'ভুট্টা',
      nameEn: 'Corn',
      emoji: '🌽',
      fitraKg: 2.0,
      priceByCountry: {
        'Bangladesh': 65,
        'India': 60,
        'Saudi Arabia': 7,
      },
    ),
    FoodItemModel(
      nameBn: 'জোয়ার',
      nameEn: 'Sorghum',
      emoji: '🌺',
      fitraKg: 2.0,
      priceByCountry: {
        'Bangladesh': 75,
        'India': 70,
        'Saudi Arabia': 8,
      },
    ),
  ];
}