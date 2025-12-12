import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'core/network/network_info.dart';
import 'core/services/parsers/bank_parser_factory.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/is_authenticated_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/sms/data/datasources/sms_data_source.dart';
import 'features/sms/data/repositories/sms_repository_impl.dart';
import 'features/sms/domain/repositories/sms_repository.dart';
import 'features/sms/domain/usecases/get_all_transactions_usecase.dart';
import 'features/sms/domain/usecases/has_sms_permissions_usecase.dart';
import 'features/sms/domain/usecases/request_sms_permissions_usecase.dart';
import 'features/sms/presentation/bloc/sms_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  sl.registerLazySingleton(() => dio);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Bank parser factory for SMS parsing
  sl.registerLazySingleton(() => BankParserFactory());

  // Auth feature
  _initAuth();

  // SMS feature
  _initSms();
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => IsAuthenticatedUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      isAuthenticatedUseCase: sl(),
    ),
  );
}

void _initSms() {
  // Data sources
  sl.registerLazySingleton<SmsDataSource>(
    () => SmsDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<SmsRepository>(
    () => SmsRepositoryImpl(
      dataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => RequestSmsPermissionsUseCase(sl()));
  sl.registerLazySingleton(() => HasSmsPermissionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTransactionsUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => SmsBloc(
      requestSmsPermissionsUseCase: sl(),
      hasSmsPermissionsUseCase: sl(),
      getAllTransactionsUseCase: sl(),
    ),
  );
}
