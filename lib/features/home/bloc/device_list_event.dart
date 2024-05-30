part of 'device_list_bloc.dart';

sealed class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object?> get props => [];
}

class RegisterNewDevice extends DeviceListEvent {
  const RegisterNewDevice();
}

class FetchAllDevices extends DeviceListEvent {
  const FetchAllDevices();
}

class NewPingReceived extends DeviceListEvent {
  final String serialNumber;

  const NewPingReceived({required this.serialNumber});

  @override
  List<Object?> get props => [serialNumber];
}

class AckPing extends DeviceListEvent {
  final String serialNumber;

  const AckPing({required this.serialNumber});

  @override
  List<Object?> get props => [serialNumber];
}

class TurnOnOffDevice extends DeviceListEvent{
  final DeviceInstance device;

  const TurnOnOffDevice({required this.device});

  @override
  List<Object?> get props => [device];
}

class UpdateDeviceLocation extends DeviceListEvent {
  final String serialNumber;
  final String newLongitude;
  final String newLatitude;

  const UpdateDeviceLocation(
      {required this.serialNumber,
      required this.newLongitude,
      required this.newLatitude});

  @override
  List<Object?> get props => [serialNumber, newLongitude, newLatitude];
}

class SendData extends DeviceListEvent{

}
