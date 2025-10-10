import 'package:flutter/material.dart';

class DailyTotalBar extends StatelessWidget {
  final int dailyTotal;

  const DailyTotalBar({
    super.key,
    required this.dailyTotal,
  });

  @override
  Widget build(BuildContext context) {
    final total = dailyTotal / 100;

    return Column(
      children: [
        Container(
          height: 2,
          color: const Color(0xFFE2E8F0),
        ),
        Container(
          height: 56,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GÜNLÜK TOPLAM',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}