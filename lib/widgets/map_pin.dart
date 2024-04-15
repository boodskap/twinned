import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  final String deviceName;
  final String deviceModel;
  const MapPin(
      {super.key, required this.deviceName, required this.deviceModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
            child: SizedBox(
                width: 24,
                height: 24,
                child: Tooltip(
                  message: '$deviceName - $deviceModel',
                  child: const Icon(
                    Icons.location_pin,
                  ),
                ))),
        Text(deviceName,
            style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 14,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontFamily: 'openSans')),
      ],
    );
  }
}
