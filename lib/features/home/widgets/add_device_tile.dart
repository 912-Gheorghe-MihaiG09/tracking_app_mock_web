import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_app_mock/common/theme/colors.dart';
import 'package:tracking_app_mock/features/home/bloc/device_list_bloc.dart';

class AddDeviceTile extends StatelessWidget {
  const AddDeviceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.add,
        color: AppColors.primary,
      ),
      title: const Text("Add new Device"),
      onTap: () => BlocProvider.of<DeviceListBloc>(context)
          .add(const RegisterNewDevice()),
    );
  }
}


