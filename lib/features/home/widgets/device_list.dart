import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_app_mock/common/widgets/custom_elevated_button.dart';
import 'package:tracking_app_mock/features/home/bloc/device_list_bloc.dart';
import 'package:tracking_app_mock/features/home/widgets/add_device_tile.dart';
import 'package:tracking_app_mock/features/home/widgets/device_tile.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<DeviceListBloc>(context).add(const FetchAllDevices());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceListBloc, DeviceListState>(
        builder: (context, state) {
          print(state);
      if (state is DeviceListLoaded) {
        return Column(
            children: [
              Expanded(child: ListView.builder(
                  itemCount: state.deviceInstances.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DeviceTile(device: state.deviceInstances[index]),);
                  }),),
              const AddDeviceTile(),
            ],
        );
      }
      if (state is DeviceListError) {
        return Column(
          children: [
            const Text("An error occurred, please try again"),
            CustomElevatedButton(
                onPressed: () => BlocProvider.of<DeviceListBloc>(context)
                    .add(const FetchAllDevices()),
                text: "Try Again")
          ],
        );
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
