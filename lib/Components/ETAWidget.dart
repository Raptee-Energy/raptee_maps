import 'package:flutter/material.dart';
import '../Constants/styles.dart';

class ETAWidget extends StatelessWidget {
  final String arrivalTime;
  final String distanceRemaining;
  final String durationRemaining;

  const ETAWidget({
    super.key,
    required this.arrivalTime,
    required this.distanceRemaining,
    required this.durationRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Estimated Time of Arrival (ETA)',
            style: Style.conigenBlackRegularText(),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ETAInfoColumn(
                title: 'Arrival Time',
                value: arrivalTime,
              ),
              _ETAInfoColumn(
                title: 'Distance Left',
                value: distanceRemaining,
              ),
              _ETAInfoColumn(
                title: 'Duration Left',
                value: durationRemaining,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ETAInfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _ETAInfoColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: Style.conigenBlackRegularText(),
        ),
        Text(
          value,
          style: Style.conigenBlackRegularText(),
        ),
      ],
    );
  }
}