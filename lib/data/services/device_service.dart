
import 'package:tracking_app_mock/data/domain/device_instance.dart';
import 'package:tracking_app_mock/data/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DeviceService extends ApiService {
  static const String _baseAdminUrl = "/api/admin";
  static const String _baseIOTUrl = "/api/iot";

  DeviceService(super.dio, super.authInterceptor, {required super.baseUrl});

  Future<List<DeviceInstance>> getAllDevices() async {
    var response = await dio.get("$_baseAdminUrl/device");

    return List<DeviceInstance>.from(
      response.data.map(
        (x) => DeviceInstance(serialNumber: x["serialNumber"]),
      ),
    );
  }

  Future<String> registerDevice() async{
    var response = await dio.post("$_baseAdminUrl/device/register");

    return response.data;
  }

  Future<Stream<dynamic>> listenForPing() async {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://${baseUrl.substring(7)}/websocketPath'),
    );

    await channel.ready;


    return channel.stream;
  }

  Future<void> sendLocationData(DeviceInstance device) async{
    var response = await dio.post("$_baseIOTUrl", data: {
      "deviceSerialNumber": device.serialNumber,
      "latitude": device.latitude,
      "longitude": device.longitude
    });

    print(response.data);
  }
}
