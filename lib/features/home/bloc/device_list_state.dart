part of 'device_list_bloc.dart';

sealed class DeviceListState extends Equatable {
  const DeviceListState();

  @override
  List<Object?> get props => [];
}

final class DeviceListInitial extends DeviceListState{
  const DeviceListInitial();
}

final class DeviceListLoading extends DeviceListState{
  const DeviceListLoading();
}

final class DeviceListLoaded extends DeviceListState{
  final List<DeviceInstance> deviceInstances;

  const DeviceListLoaded({required this.deviceInstances});

  @override
  List<Object?> get props => [deviceInstances];
}

final class DeviceListError extends DeviceListState{
  const DeviceListError();
}