import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_app_mock/app_settings.dart';
import 'package:tracking_app_mock/common/theme/theme_builder.dart';
import 'package:tracking_app_mock/data/repository/auth_repository.dart';
import 'package:tracking_app_mock/data/repository/secure_local_storage.dart';
import 'package:tracking_app_mock/data/services/auth_service.dart';
import 'package:tracking_app_mock/data/services/device_service.dart';
import 'package:tracking_app_mock/data/services/interceptors/auth_interceptor.dart';
import 'package:tracking_app_mock/features/auth/login/bloc/auth_bloc.dart';
import 'package:tracking_app_mock/features/auth/login/login_screen.dart';
import 'package:tracking_app_mock/features/home/bloc/device_list_bloc.dart';
import 'package:tracking_app_mock/features/home/home_screen.dart';

void main() {
  runApp(MyApp(appSettings: AppSettings(baseUrl: 'http://34.159.189.145:8080')));
}

class MyApp extends StatelessWidget {
  final AppSettings appSettings;

  MyApp({super.key, required this.appSettings});

  late final AuthService _authService =
      AuthService(baseUrl: appSettings.baseUrl);

  late final AuthRepository _authRepository =
      AuthRepository(SecureLocalStorage(), _authService);

  final Dio _dio = Dio();

  late final AuthInterceptor authInterceptor =
      AuthInterceptor(_dio, SecureLocalStorage(), _authService, () {});

  late final DeviceService _deviceService =
      DeviceService(_dio, authInterceptor, baseUrl: appSettings.baseUrl);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DeviceListBloc(_deviceService),
        ),
        BlocProvider(
          create: (_) => AuthBloc(_authRepository)
            ..add(
              const LogIn(email: "admin@mail.com", password: "Parola@123"),
            ),
        ),
      ],
      child: MaterialApp(
        title: 'Tracking App Virtual Devices',
        theme: ThemeBuilder.getThemeData(true),
        home: BlocConsumer<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
            listener: (BuildContext context, AuthState state) =>
                Navigator.popUntil(context, (route) => route.isFirst)),
      ),
    );
  }
}
