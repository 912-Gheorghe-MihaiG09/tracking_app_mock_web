import 'package:equatable/equatable.dart';

class DeviceInstance extends Equatable {
  String serialNumber;
  late Stream<bool> pingStream;
  double longitude;
  double latitude;
  bool isOn;
  bool isPinged;

  DeviceInstance(
      {required this.serialNumber,
      this.longitude = 0,
      this.latitude = 0,
      this.isPinged = false,
      this.isOn = false}) {
    pingStream = const Stream.empty();
  }

  @override
  List<Object?> get props => [serialNumber, latitude, longitude, isOn, isPinged];
}
