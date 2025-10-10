import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Accounter',
            style: TextStyle(
              color: Color(0xFF1A202C),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Color(0xFF4A5568)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF4A5568)),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}