import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text(
            'Tümü',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF38A169),
            ),
          ),
        ),
        Container(
          height: 2,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }
}