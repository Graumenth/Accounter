import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onSettingsChanged;

  const AppHeader({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      color: Colors.white,
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
                onPressed: () async {
                  await Navigator.pushNamed(context, '/settings');
                  onSettingsChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}