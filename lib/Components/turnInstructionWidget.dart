import 'package:flutter/material.dart';

class TurnInstructionsWidget extends StatelessWidget {
  final String turnInstruction;
  final String turnIcon;
  final String turnDistance;

  const TurnInstructionsWidget({
    super.key,
    required this.turnInstruction,
    required this.turnIcon,
    required this.turnDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (turnIcon.isNotEmpty)
            Image.asset(
              turnIcon,
              width: 40.0,
              height: 40.0,
            ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turnInstruction,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  turnDistance.isNotEmpty ? 'in $turnDistance' : '',
                  style:
                  const TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}