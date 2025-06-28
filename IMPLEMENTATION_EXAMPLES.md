# 🔧 Implementation Examples - Clean Architecture

## 1. Core - Error Handling

### lib/core/errors/failures.dart
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

// General failures
class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure();
  
  @override
  List<Object> get props => [];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
  
  @override
  List<Object> get props => [];
}

// Auth-specific failures
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
  
  @override
  List<Object> get props => [];
}

class BiometricNotAvailableFailure extends Failure {
  const BiometricNotAvailableFailure();
  
  @override
  List<Object> get props => [];
}
```

### lib/core/errors/exceptions.dart
```dart
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class InvalidCredentialsException implements Exception {}

class BiometricNotAvailableException implements Exception {}
```

## 2. Core - Dependency Injection

### lib/core/di/injection_container.dart
```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Features
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/authenticate_with_pin.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      authenticateWithPin: sl(),
      authenticateWithBiometric: sl(),
      logout: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AuthenticateWithPin(sl()));
  sl.registerLazySingleton(() => AuthenticateWithBiometric(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
```

## 3. Feature - Auth Domain Layer

### lib/features/auth/domain/entities/user.dart
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? name;
  final bool hasPinSetup;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    this.name,
    required this.hasPinSetup,
    required this.biometricEnabled,
    required this.createdAt,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
    id, name, hasPinSetup, biometricEnabled, createdAt, lastLoginAt
  ];
}
```

### lib/features/auth/domain/repositories/auth_repository.dart
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> authenticateWithPin(String pin);
  Future<Either<Failure, User>> authenticateWithBiometric();
  Future<Either<Failure, bool>> setupPin(String pin);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isBiometricAvailable();
  Future<Either<Failure, void>> enableBiometric(bool enable);
}
```

### lib/features/auth/domain/usecases/authenticate_with_pin.dart
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithPin implements UseCase<User, AuthenticateWithPinParams> {
  final AuthRepository repository;

  AuthenticateWithPin(this.repository);

  @override
  Future<Either<Failure, User>> call(AuthenticateWithPinParams params) async {
    return await repository.authenticateWithPin(params.pin);
  }
}

class AuthenticateWithPinParams extends Equatable {
  final String pin;

  const AuthenticateWithPinParams({required this.pin});

  @override
  List<Object> get props => [pin];
}
```

### lib/core/usecases/usecase.dart
```dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

## 4. Feature - Auth Data Layer

### lib/features/auth/data/models/user_model.dart
```dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    String? name,
    required bool hasPinSetup,
    required bool biometricEnabled,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) : super(
          id: id,
          name: name,
          hasPinSetup: hasPinSetup,
          biometricEnabled: biometricEnabled,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      hasPinSetup: json['hasPinSetup'],
      biometricEnabled: json['biometricEnabled'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hasPinSetup': hasPinSetup,
      'biometricEnabled': biometricEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }
}
```

### lib/features/auth/data/datasources/auth_local_datasource.dart
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel userToCache);
  Future<bool> verifyPin(String pin);
  Future<void> savePin(String pin);
  Future<bool> hasPin();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString('CACHED_USER');
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    await sharedPreferences.setString(
      'CACHED_USER',
      json.encode(userToCache.toJson()),
    );
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final savedPin = await secureStorage.read(key: 'USER_PIN');
      return savedPin == pin;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> savePin(String pin) async {
    try {
      await secureStorage.write(key: 'USER_PIN', value: pin);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final pin = await secureStorage.read(key: 'USER_PIN');
      return pin != null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove('CACHED_USER');
    await secureStorage.delete(key: 'USER_PIN');
  }
}
```

## 5. Feature - Auth Presentation Layer

### lib/features/auth/presentation/bloc/auth_event.dart
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithPinEvent extends AuthEvent {
  final String pin;

  const LoginWithPinEvent({required this.pin});

  @override
  List<Object> get props => [pin];
}

class LoginWithBiometricEvent extends AuthEvent {
  const LoginWithBiometricEvent();
}

class SetupPinEvent extends AuthEvent {
  final String pin;

  const SetupPinEvent({required this.pin});

  @override
  List<Object> get props => [pin];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
```

### lib/features/auth/presentation/bloc/auth_state.dart
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
```

### lib/features/auth/presentation/bloc/auth_bloc.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/authenticate_with_pin.dart';
import '../../domain/usecases/authenticate_with_biometric.dart';
import '../../domain/usecases/logout.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateWithPin authenticateWithPin;
  final AuthenticateWithBiometric authenticateWithBiometric;
  final Logout logout;

  AuthBloc({
    required this.authenticateWithPin,
    required this.authenticateWithBiometric,
    required this.logout,
  }) : super(AuthInitial()) {
    on<LoginWithPinEvent>(_onLoginWithPin);
    on<LoginWithBiometricEvent>(_onLoginWithBiometric);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginWithPin(
    LoginWithPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await authenticateWithPin(
      AuthenticateWithPinParams(pin: event.pin),
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLoginWithBiometric(
    LoginWithBiometricEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await authenticateWithBiometric(NoParams());

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await logout(NoParams());
    emit(AuthUnauthenticated());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case InvalidCredentialsFailure:
        return 'Invalid PIN. Please try again.';
      case BiometricNotAvailableFailure:
        return 'Biometric authentication not available.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
```

## 6. Shared Components

### lib/shared/widgets/custom_button.dart
```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(context),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: _getTextStyle()),
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }

  TextStyle _getTextStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }
}

enum ButtonType { primary, secondary, outline }
```

Kiến trúc này cung cấp:

✅ **Separation of Concerns** rõ ràng  
✅ **Testability** cao với dependency injection  
✅ **Scalability** tốt với feature-based structure  
✅ **Maintainability** dễ dàng với clean architecture  
✅ **Reusability** với shared components  

Bạn có thể bắt đầu migrate từng feature một theo kiến trúc này! 