import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_model.dart';
import '../models/food_item_model.dart';
import '../models/madhhab_model.dart';
import '../services/mock_data_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/footer_section.dart';
import '../widgets/food_item_card.dart';
import '../widgets/gender_toggle.dart';
import '../widgets/info_accordion_item.dart';
import '../widgets/location_card.dart';
import '../widgets/madhhab_card.dart';
import '../widgets/primary_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CountryModel selectedCountry;
  late MadhhabModel selectedMadhhab;
  late FoodItemModel selectedFood;

  bool isSunni = true;
  bool isCompleted = false;
  int completedCount = 0;
  int openAccordionIndex = -1;

  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = MockDataService.countries.first;
    selectedFood = MockDataService.foodItems[1];
    selectedMadhhab = MockDataService.sunniMadhhabs.first;
    _setFoodBasedPrice();
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  List<MadhhabModel> get currentMadhhabs {
    return isSunni
        ? MockDataService.sunniMadhhabs
        : MockDataService.shiaMadhhabs;
  }

  String get currencySymbol {
    return selectedCountry.currencySymbol;
  }

  void _setFoodBasedPrice() {
    final double price =
        selectedFood.priceByCountry[selectedCountry.name] ??
            selectedCountry.defaultPricePerKg;
    priceController.text = price.toStringAsFixed(0);
  }

  double get pricePerKg {
    final text = priceController.text.trim();
    if (text.isEmpty) {
      return selectedFood.priceByCountry[selectedCountry.name] ??
          selectedCountry.defaultPricePerKg;
    }
    return double.tryParse(text) ??
        (selectedFood.priceByCountry[selectedCountry.name] ??
            selectedCountry.defaultPricePerKg);
  }

  double _kgForFood(FoodItemModel food) {
    if (!isSunni) {
      return 3.0;
    }

    switch (selectedMadhhab.nameBn) {
      case 'হানাফী':
        if (food.nameBn == 'গম') {
          return 1.75;
        }
        return 3.0;
      case 'শাফেঈ':
      case 'মালেকী':
      case 'হাম্বলী':
        return 3.0;
      default:
        return food.fitraKg;
    }
  }

  double get selectedKg {
    return _kgForFood(selectedFood);
  }

  double _priceForFood(FoodItemModel food) {
    return food.priceByCountry[selectedCountry.name] ??
        selectedCountry.defaultPricePerKg;
  }

  double _amountForFood(FoodItemModel food) {
    return _kgForFood(food) * _priceForFood(food);
  }

  double get totalAmount {
    return selectedKg * pricePerKg;
  }

  bool get _isBangladeshHanafiOverride {
    return isSunni &&
        selectedCountry.name == 'Bangladesh' &&
        selectedMadhhab.nameBn == 'হানাফী';
  }

  double get minAmount {
    if (_isBangladeshHanafiOverride) {
      return 110;
    }

    final values = MockDataService.foodItems.map(_amountForFood).toList();
    return values.reduce(min);
  }

  double get maxAmount {
    if (_isBangladeshHanafiOverride) {
      return 2805;
    }

    final values = MockDataService.foodItems.map(_amountForFood).toList();
    return values.reduce(max);
  }

  String get amountRuleText {
    if (isSunni) {
      switch (selectedMadhhab.nameBn) {
        case 'হানাফী':
          return 'হানাফী মতে সাধারণভাবে অর্ধ সা গম বা এক সা খেজুর, যব, কিসমিস ইত্যাদির সমমূল্য বা খাদ্য দেওয়া হয়ে থাকে।';
        case 'শাফেঈ':
          return 'শাফেঈ মতে সাধারণভাবে এক সা স্থানীয় প্রধান খাদ্য দেওয়া হয়।';
        case 'মালেকী':
          return 'মালেকী মতে সাধারণভাবে এক সা স্থানীয় প্রধান খাদ্য দেওয়া হয়।';
        case 'হাম্বলী':
          return 'হাম্বলী মতে সাধারণভাবে এক সা খাদ্য দেওয়া হয়, স্থানীয় নিয়ম অনুযায়ী।';
        default:
          return 'স্থানীয় আলেমের পরামর্শ অনুযায়ী পরিমাণ নির্ধারণ করুন।';
      }
    }

    return 'শিয়া মত অনুযায়ী সাধারণভাবে স্থানীয় প্রধান খাদ্যের নির্ধারিত পরিমাণ বা তার মূল্য দেওয়া হতে পারে। আপনার মারজার নির্দেশনা অনুসরণ করুন।';
  }

  String get kgRuleText {
    return 'এই হিসাবে প্রায় ${selectedKg.toStringAsFixed(2)} কেজি ${selectedFood.nameBn} ধরা হয়েছে।';
  }

  void updateCountry(CountryModel country) {
    setState(() {
      selectedCountry = country;
      _setFoodBasedPrice();
    });
  }

  void _showEligibilityDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 44,
                  child: Divider(thickness: 4),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'আমি কি ফিতরা দেওয়ার যোগ্য?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'নিচের ২টি সহজ প্রশ্নের মাধ্যমে সাধারণ ধারণা নিন।',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _qaItem(
                '১) ঈদের দিন ও রাতের প্রয়োজনের অতিরিক্ত সম্পদ আছে?',
                'যদি আপনার নিজের ও নির্ভরশীলদের মৌলিক প্রয়োজন মিটিয়ে অতিরিক্ত সামর্থ্য থাকে, তাহলে সাধারণভাবে আপনার উপর ফিতরা ওয়াজিব হতে পারে।',
              ),
              const SizedBox(height: 12),
              _qaItem(
                '২) আপনি মুসলিম এবং ঈদের আগে জীবিত আছেন?',
                'যদি আপনি মুসলিম হন এবং ঈদের সময় জীবিত থাকেন, তাহলে আপনার নিজের জন্য এবং অনেক ক্ষেত্রে যাদের দায়িত্ব আপনার উপর, তাদের পক্ষ থেকেও ফিতরা দিতে হতে পারে।',
              ),
              const SizedBox(height: 16),
              const Text(
                'চূড়ান্ত সিদ্ধান্তের জন্য স্থানীয় আলেমের পরামর্শ নিন।',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qaItem(String question, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE9DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showMadhhabHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'মাজহাব জানেন না?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'আপনি যদি নিশ্চিত না হন, তাহলে আপনার পরিবার, এলাকার মসজিদের ইমাম, বা স্থানীয় আলেমদের জিজ্ঞেস করুন। বাংলাদেশে অধিকাংশ মানুষ সাধারণভাবে হানাফী মাজহাব অনুসরণ করেন।',
            style: TextStyle(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে'),
            ),
          ],
        );
      },
    );
  }

  void _showIslamicMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'ইসলামিক স্মরণিকা',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'রাসূলুল্লাহ ﷺ ফিতরা আদায়ের ব্যাপারে গুরুত্ব দিয়েছেন, যাতে রোজাদার পবিত্র হয় এবং অভাবীদের উপকার হয়।',
                style: TextStyle(height: 1.6),
              ),
              SizedBox(height: 12),
              Text(
                'ঈদের সালাতের আগে ফিতরা আদায় করা উত্তম।',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('আলহামদুলিল্লাহ'),
            ),
          ],
        );
      },
    );
  }

  void _showCommunitySheet() {
    final marketPrice = pricePerKg.toStringAsFixed(0);
    final calculated = totalAmount.toStringAsFixed(0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 44,
                  child: Divider(thickness: 4),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Community তথ্য',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                '${selectedCountry.name} এর জন্য ${selectedFood.nameBn} ভিত্তিক কমিউনিটি তথ্য দেখানো হচ্ছে।',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _communityItem(
                'নির্বাচিত বাজারদর',
                '$currencySymbol $marketPrice প্রতি কেজি',
              ),
              const SizedBox(height: 12),
              _communityItem(
                'নির্বাচিত হিসাব',
                '$currencySymbol $calculated (${selectedKg.toStringAsFixed(2)} kg × $marketPrice)',
              ),
              const SizedBox(height: 12),
              _communityItem(
                'সাধারণ পরামর্শ',
                'চূড়ান্তভাবে দেওয়ার আগে স্থানীয় আলেম, মসজিদ, বা বিশ্বস্ত কমিউনিটি সোর্সের সাথে মিলিয়ে নেওয়া উত্তম।',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _communityItem(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE9DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCompleted() {
    setState(() {
      if (!isCompleted) {
        isCompleted = true;
        completedCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _showIslamicMessage,
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              const SizedBox(height: 28),
              _questionBanner(),
              const SizedBox(height: 18),
              _buildCountryCard(),
              const SizedBox(height: 22),
              _buildMadhhabSection(),
              const SizedBox(height: 16),
              _madhhabRuleCard(),
              const SizedBox(height: 16),
              _commonInfoCard(),
              const SizedBox(height: 22),
              _buildFoodSection(),
              const SizedBox(height: 22),
              _priceSection(),
              const SizedBox(height: 18),
              _infoSection(),
              const SizedBox(height: 18),
              _completionCard(),
              const SizedBox(height: 16),
              _statsCard(),
              const SizedBox(height: 16),
              _disclaimerCard(),
              const SizedBox(height: 28),
              const FooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionBanner() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _showEligibilityDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD2DDD3), width: 2),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8F3EC),
              child: Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আমি কি ফিতরা দেওয়ার যোগ্য?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '২টি সহজ প্রশ্নে জানুন',
                    style: TextStyle(fontSize: 16, color: AppColors.textSoft),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSoft, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryCard() {
    return LocationCard(
      country: selectedCountry,
      madhhabLabel: selectedMadhhab.nameBn,
      onCountryChanged: (country) {
        if (country != null) {
          updateCountry(country);
        }
      },
    );
  }

  Widget _buildMadhhabSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'মাজহাব',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showMadhhabHelpDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: AppColors.textSoft),
                      SizedBox(width: 6),
                      Text(
                        'Don\'t know yours?',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSoft,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GenderToggle(
            isMale: isSunni,
            onChanged: (value) {
              setState(() {
                isSunni = value;
                selectedMadhhab = currentMadhhabs.first;
              });
            },
          ),
          const SizedBox(height: 18),
          GridView.builder(
            itemCount: currentMadhhabs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final item = currentMadhhabs[index];
              return MadhhabCard(
                madhhab: item,
                isSelected: selectedMadhhab.nameBn == item.nameBn,
                onTap: () {
                  setState(() {
                    selectedMadhhab = item;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _madhhabRuleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCECDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedMadhhab.nameBn} মতে ফিতরার নিয়ম',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountRuleText,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSoft,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            kgRuleText,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'সর্বনিম্ন: $currencySymbol ${minAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'সর্বোচ্চ: $currencySymbol ${maxAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Most common worldwide\n${selectedKg.toStringAsFixed(2)} kg ${selectedFood.nameEn.toLowerCase()} per person · ${selectedMadhhab.region} · ${selectedCountry.name}',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildFoodSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'প্রধান খাদ্য',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                'Auto-set by country',
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            itemCount: MockDataService.foodItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = MockDataService.foodItems[index];
              return FoodItemCard(
                item: item,
                isSelected: selectedFood.nameBn == item.nameBn,
                onTap: () {
                  setState(() {
                    selectedFood = item;
                    _setFoodBasedPrice();
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F0F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '${selectedFood.nameBn} — ${selectedMadhhab.region}. এই খাদ্যের বর্তমান মূল্য অনুযায়ী হিসাব দেখানো হচ্ছে। স্থানীয় আলেম ভিন্ন শস্য পরামর্শ দিলে পরিবর্তন করতে পারেন।',
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'প্রতি কেজি মূল্য',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      currencySymbol,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showCommunitySheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8ED),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBBE7C7)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.people_outline, color: AppColors.primaryGreen),
                    SizedBox(width: 8),
                    Text(
                      'Community',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'নির্বাচিত খাদ্য: ${selectedFood.nameBn} · ${selectedCountry.name}',
          style: const TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 6),
        const Text(
          '📡 Community correction · cached Mar 2026',
          style: TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D7A46), Color(0xFF0B5E36)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'মোট ফিতরা',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                '$currencySymbol ${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${selectedKg.toStringAsFixed(2)} kg × ${pricePerKg.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoSection() {
    final items = [
      {
        'title': 'এই পরিমাণ কেন?',
        'content':
            'নির্বাচিত খাদ্য, মাজহাব এবং স্থানীয় প্রচলিত দামের উপর ভিত্তি করে আনুমানিক হিসাব দেখানো হচ্ছে। স্থানীয় আলেমের পরামর্শকে অগ্রাধিকার দিন।',
        'icon': Icons.menu_book_outlined,
      },
      {
        'title': 'কে ফিতরা পাওয়ার যোগ্য?',
        'content':
            'দরিদ্র, মিসকীন এবং যাদের মৌলিক প্রয়োজন মেটানো কঠিন, তারা ফিতরা পাওয়ার যোগ্য হতে পারেন। আপনার এলাকার নির্ভরযোগ্য আলেম বা ইমামের কাছে নিশ্চিত হয়ে নিন।',
        'icon': Icons.people_outline,
      },
      {
        'title': 'সাধারণভাবে দান করুন',
        'content':
            'ঈদের নামাজের আগে ফিতরা আদায় করা উত্তম। নগদ বা খাদ্য দেওয়ার বিষয়টি মাজহাব, দেশ ও স্থানীয় আলেমদের নির্দেশনার উপর নির্ভর করতে পারে।',
        'icon': Icons.wallet_outlined,
      },
    ];

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return InfoAccordionItem(
          title: item['title'] as String,
          content: item['content'] as String,
          icon: item['icon'] as IconData,
          isExpanded: openAccordionIndex == index,
          onTap: () {
            setState(() {
              openAccordionIndex = openAccordionIndex == index ? -1 : index;
            });
          },
        );
      }),
    );
  }

  Widget _completionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDECDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'আপনি কি ফিতরা বিতরণ করেছেন?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'ফিতরা প্রদান করার পর, নিচের বাটনে ক্লিক করে আপনার ইবাদত নিবন্ধিত করুন।',
            style: TextStyle(color: AppColors.textSoft, height: 1.5),
          ),
          const SizedBox(height: 16),
          PrimaryActionButton(
            text: isCompleted
                ? 'আলহামদুলিল্লাহ — সম্পন্ন হয়েছে'
                : 'হ্যাঁ — আমি ফিতরা সম্পন্ন করে বিতরণ করেছি',
            onTap: _toggleCompleted,
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFBF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '🌙 $completedCount জন মুসলিম এই মৌসুমে ফিতরা আদায় করেছেন · আলহামদুলিল্লাহ',
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _disclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0E0B2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'শুধু তথ্যের জন্য · ফতোয়া নয় · আলেম ও কুরআন অনুসরণ করুন',
            style: TextStyle(
              color: AppColors.warningText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'এই ক্যালকুলেটর শুধুমাত্র সাধারণ তথ্যের জন্য। এটি কোনো ফতোয়া বা ধর্মীয় বিধান নয়। সর্বদা কুরআন পড়ুন এবং আপনার নিজের পরিস্থিতিতে একজন যোগ্য আলেম বা ইমামের পরামর্শ নিন। ধর্মীয় নির্দেশনা জ্ঞান ও বিদ্বতা থেকে আসে, অ্যালগরিদম থেকে নয়।',
            style: TextStyle(
              color: Color(0xFFA98A44),
              height: 1.7,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}