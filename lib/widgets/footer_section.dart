import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          AppConstants.footerArabic,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            color: Color(0xFF7AA68C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppConstants.footerEnglish,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSoft,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Made with ❤️ for the Ummah',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: 8),
        const Text(
          'Reduanul Islam',
          style: TextStyle(fontSize: 18, color: AppColors.textSoft),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⚡ Changelog', style: TextStyle(color: AppColors.textSoft)),
            SizedBox(width: 18),
            Text('🔒 Legal', style: TextStyle(color: AppColors.textSoft)),
            SizedBox(width: 18),
            Text('👤 About', style: TextStyle(color: AppColors.textSoft)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'A free tool · No ads · No tracking · © 2026',
          style: TextStyle(color: AppColors.textSoft),
        ),
      ],
    );
  }
}