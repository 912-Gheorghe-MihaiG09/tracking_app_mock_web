import 'package:flutter/material.dart';
import 'package:tracking_app_mock/features/home/widgets/device_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Tracking Devices"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(32),
        child: DeviceList(),
      ),
    );
  }
}
