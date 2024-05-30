import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_app_mock/common/validator.dart';
import 'package:tracking_app_mock/data/services/device_service.dart';

import '../../../data/domain/device_instance.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final DeviceService _deviceService;
  late StreamSubscription<dynamic> _pingStreamSubscription;
  late Timer _timer;

  DeviceListBloc(this._deviceService) : super(const DeviceListInitial()) {
    on<FetchAllDevices>(_onFetchAllDevices);
    on<RegisterNewDevice>(_onRegisterNewDevice);
    on<TurnOnOffDevice>(_onTurnOnOffDevice);
    on<NewPingReceived>(_onNewPingReceived);
    on<UpdateDeviceLocation>(_onUpdateDeviceLocation);
    on<AckPing>(_onAckPing);
    on<SendData>(_onSendData);
    _deviceService.listenForPing().then(_setUpPingListener);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      add(SendData());
    });
  }

  FutureOr<void> _onFetchAllDevices(
      FetchAllDevices event, Emitter<DeviceListState> emit) async {
    emit(const DeviceListLoading());
    try {
      List<DeviceInstance> devices = await _deviceService.getAllDevices();
      emit(DeviceListLoaded(deviceInstances: devices));
    } catch (e) {
      print(e);
      emit(const DeviceListError());
    }
  }

  FutureOr<void> _onRegisterNewDevice(
      RegisterNewDevice event, Emitter<DeviceListState> emit) async {
    emit(const DeviceListLoading());
    try {
      await _deviceService.registerDevice();
      List<DeviceInstance> devices = await _deviceService.getAllDevices();
      emit(DeviceListLoaded(deviceInstances: devices));
    } catch (e) {
      print(e);
      emit(const DeviceListError());
    }
  }

  FutureOr<void> _onTurnOnOffDevice(
      TurnOnOffDevice event, Emitter<DeviceListState> emit) {
    if (state is DeviceListLoaded) {
      List<DeviceInstance> devices =
          (state as DeviceListLoaded).deviceInstances;
      emit(const DeviceListLoading());
      devices
          .firstWhere(
              (element) => element.serialNumber == event.device.serialNumber)
          .isOn = !event.device.isOn;
      emit(DeviceListLoaded(deviceInstances: devices));
    }
  }

  FutureOr<void> _onNewPingReceived(
      NewPingReceived event, Emitter<DeviceListState> emit) {
    if (state is DeviceListLoaded) {
      List<DeviceInstance> devices =
          (state as DeviceListLoaded).deviceInstances;
      if (devices
          .where((element) => element.serialNumber == event.serialNumber)
          .isNotEmpty) {
        emit(const DeviceListLoading());
        devices
            .firstWhere((element) => element.serialNumber == event.serialNumber)
            .isPinged = true;
        emit(DeviceListLoaded(deviceInstances: devices));
      }
    }
  }

  FutureOr<void> _onAckPing(AckPing event, Emitter<DeviceListState> emit) {
    if (state is DeviceListLoaded) {
      List<DeviceInstance> devices =
          (state as DeviceListLoaded).deviceInstances;
      emit(const DeviceListLoading());
      devices
          .firstWhere((element) => element.serialNumber == event.serialNumber)
          .isPinged = false;
      emit(DeviceListLoaded(deviceInstances: devices));
    }
  }


  FutureOr<void> _onUpdateDeviceLocation(UpdateDeviceLocation event, Emitter<DeviceListState> emit) {
    if (state is DeviceListLoaded) {
      List<DeviceInstance> devices =
          (state as DeviceListLoaded).deviceInstances;
      emit(const DeviceListLoading());
      devices
          .firstWhere((element) => element.serialNumber == event.serialNumber)
          .longitude = double.parse(event.newLongitude);
      devices
          .firstWhere((element) => element.serialNumber == event.serialNumber)
          .latitude = double.parse(event.newLatitude);
      emit(DeviceListLoaded(deviceInstances: devices));
    }
  }

  void _setUpPingListener(Stream<dynamic> stream) {
    _pingStreamSubscription = stream.listen(
      (event) {
        String eventString = event.toString();
        if (eventString.length == 23 &&
            eventString.substring(0, 6) == "ping: ") {
          String serialNumber = eventString.substring(6);
          if (Validator.validateBatterySerialNumber(serialNumber) == null) {
            add(NewPingReceived(serialNumber: serialNumber));
          }
        }
      },
    );
  }

  FutureOr<void> _onSendData(SendData event, Emitter<DeviceListState> emit) async{
    if(state is DeviceListLoaded){
      print("Sending Data");
      List<DeviceInstance> devices =
          (state as DeviceListLoaded).deviceInstances;
      for(DeviceInstance device in devices){
        if(device.isOn){
          await _deviceService.sendLocationData(device);
        }
      }
    }
  }

  @override
  Future<void> close() {
    _pingStreamSubscription.cancel();
    return super.close();
  }
}
