import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_app_mock/common/theme/colors.dart';
import 'package:tracking_app_mock/common/validator.dart';
import 'package:tracking_app_mock/common/widgets/custom_elevated_button.dart';
import 'package:tracking_app_mock/common/widgets/text_input_field.dart';
import 'package:tracking_app_mock/data/domain/device_instance.dart';
import 'package:tracking_app_mock/features/home/bloc/device_list_bloc.dart';

class DeviceTile extends StatefulWidget {
  final DeviceInstance device;
  const DeviceTile({super.key, required this.device});

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(children: [
        Text(widget.device.serialNumber),
        Spacer(),
        GestureDetector(
          onTap: () {
            if (widget.device.isPinged) {
              BlocProvider.of<DeviceListBloc>(context).add(
                AckPing(serialNumber: widget.device.serialNumber),
              );
            }
          },
          child: _ColorChangingIcon(widget.device.isPinged),
        )
      ]),
      leading: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.device.isOn ? Colors.greenAccent : Colors.redAccent,
        ),
        height: 30,
        width: 30,
      ),
      iconColor: AppColors.primary,
      children: [
        _DeviceTileExpansion(
          device: widget.device,
        )
      ],
    );
  }
}

class _DeviceTileExpansion extends StatefulWidget {
  final DeviceInstance device;
  const _DeviceTileExpansion({required this.device});

  @override
  State<_DeviceTileExpansion> createState() => _DeviceTileExpansionState();
}

class _DeviceTileExpansionState extends State<_DeviceTileExpansion> {
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();

  bool _isChangedButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _longitudeController.text = widget.device.longitude.toString();
    _latitudeController.text = widget.device.latitude.toString();
    _isChangedButtonEnabled = _validateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Form(
        onChanged: () {
          setState(() {
            _isChangedButtonEnabled = _validateForm();
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: TextInputField(
                labelText: "Longitude",
                controller: _longitudeController,
                validator: Validator.validateDouble,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: TextInputField(
                labelText: "Latitude",
                controller: _latitudeController,
                validator: Validator.validateDouble,
              ),
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      text: "Save Location",
                      onPressed: _isChangedButtonEnabled
                          ? () {
                              BlocProvider.of<DeviceListBloc>(context).add(
                                UpdateDeviceLocation(
                                    serialNumber: widget.device.serialNumber,
                                    newLongitude: _longitudeController.text,
                                    newLatitude: _latitudeController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("New Location saved successfully"),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: CustomElevatedButton(
                      text: widget.device.isOn ? "Turn Off" : "Turn On",
                      onPressed: () =>
                          BlocProvider.of<DeviceListBloc>(context).add(
                        TurnOnOffDevice(
                          device: widget.device,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    return Validator.validateDouble(_latitudeController.text) == null &&
        Validator.validateDouble(_longitudeController.text) == null;
  }
}

class _ColorChangingIcon extends StatefulWidget {
  final bool animate;
  const _ColorChangingIcon(this.animate);

  @override
  _ColorChangingIconState createState() => _ColorChangingIconState();
}

class _ColorChangingIconState extends State<_ColorChangingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: CupertinoColors.inactiveGray,
      end: AppColors.errorRed,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Icon(
          Icons.notifications,
          color: widget.animate
              ? _colorAnimation.value
              : CupertinoColors.inactiveGray,
          size: 30,
        );
      },
    );
  }
}
