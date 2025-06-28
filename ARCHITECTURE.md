# 🏗️ DID Wallet - Kiến trúc đề xuất

## 📁 Cấu trúc thư mục đề xuất

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # App configuration
│
├── core/                              # Core system components
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── api_constants.dart         # API endpoints
│   │   └── storage_keys.dart          # Storage key constants
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   ├── failures.dart              # Failure classes
│   │   └── error_handler.dart         # Global error handling
│   ├── network/
│   │   ├── dio_client.dart            # HTTP client setup
│   │   ├── network_info.dart          # Network connectivity
│   │   └── interceptors/              # Request/Response interceptors
│   ├── storage/
│   │   ├── secure_storage.dart        # Secure storage (keychain/keystore)
│   │   ├── local_storage.dart         # Local storage wrapper
│   │   └── cache_manager.dart         # Cache management
│   ├── utils/
│   │   ├── crypto_utils.dart          # Cryptographic utilities
│   │   ├── date_utils.dart            # Date formatting
│   │   ├── validators.dart            # Input validation
│   │   └── logger.dart                # Logging utility
│   ├── extensions/
│   │   ├── string_extensions.dart     # String utilities
│   │   ├── datetime_extensions.dart   # DateTime utilities
│   │   └── context_extensions.dart    # BuildContext utilities
│   ├── theme/
│   │   ├── app_theme.dart             # Theme configuration
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_text_styles.dart       # Typography
│   │   └── app_dimensions.dart        # Spacing, sizes
│   └── di/
│       ├── injection_container.dart   # Dependency injection setup
│       └── service_locator.dart       # Service locator pattern
│
├── features/                          # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_token_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart
│   │   │   │   └── auth_token.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── authenticate_with_pin.dart
│   │   │       ├── authenticate_with_biometric.dart
│   │   │       ├── setup_pin.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── pin_setup_page.dart
│   │       │   ├── pin_login_page.dart
│   │       │   └── biometric_setup_page.dart
│   │       └── widgets/
│   │           ├── pin_input_widget.dart
│   │           ├── biometric_button.dart
│   │           └── auth_loading_widget.dart
│   │
│   ├── credentials/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── credential_local_datasource.dart
│   │   │   │   └── credential_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── credential_model.dart
│   │   │   │   └── verifiable_credential_model.dart
│   │   │   └── repositories/
│   │   │       └── credential_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── credential.dart
│   │   │   │   └── verifiable_credential.dart
│   │   │   ├── repositories/
│   │   │   │   └── credential_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_credentials.dart
│   │   │       ├── add_credential.dart
│   │   │       ├── verify_credential.dart
│   │   │       └── delete_credential.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── credential_bloc.dart
│   │       │   ├── credential_event.dart
│   │       │   └── credential_state.dart
│   │       ├── pages/
│   │       │   ├── credentials_list_page.dart
│   │       │   ├── credential_detail_page.dart
│   │       │   └── add_credential_page.dart
│   │       └── widgets/
│   │           ├── credential_card.dart
│   │           ├── credential_filter.dart
│   │           └── credential_search.dart
│   │
│   ├── dids/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── did_local_datasource.dart
│   │   │   │   └── did_blockchain_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── did_model.dart
│   │   │   │   └── did_document_model.dart
│   │   │   └── repositories/
│   │   │       └── did_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── did.dart
│   │   │   │   └── did_document.dart
│   │   │   ├── repositories/
│   │   │   │   └── did_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_did.dart
│   │   │       ├── resolve_did.dart
│   │   │       ├── update_did.dart
│   │   │       └── deactivate_did.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── did_bloc.dart
│   │       │   ├── did_event.dart
│   │       │   └── did_state.dart
│   │       ├── pages/
│   │       │   ├── dids_list_page.dart
│   │       │   ├── did_detail_page.dart
│   │       │   └── create_did_page.dart
│   │       └── widgets/
│   │           ├── did_card.dart
│   │           ├── did_method_selector.dart
│   │           └── verification_method_widget.dart
│   │
│   ├── qr_scanner/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── qr_scanner_datasource.dart
│   │   │   └── repositories/
│   │   │       └── qr_scanner_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── qr_result.dart
│   │   │   ├── repositories/
│   │   │   │   └── qr_scanner_repository.dart
│   │   │   └── usecases/
│   │   │       ├── scan_qr_code.dart
│   │   │       └── process_qr_data.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── qr_scanner_bloc.dart
│   │       │   ├── qr_scanner_event.dart
│   │       │   └── qr_scanner_state.dart
│   │       ├── pages/
│   │       │   └── qr_scanner_page.dart
│   │       └── widgets/
│   │           ├── qr_scanner_widget.dart
│   │           └── qr_result_widget.dart
│   │
│   └── settings/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_datasource.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       ├── update_biometric_setting.dart
│       │       └── reset_app.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── settings_bloc.dart
│           │   ├── settings_event.dart
│           │   └── settings_state.dart
│           ├── pages/
│           │   ├── settings_page.dart
│           │   ├── security_settings_page.dart
│           │   └── about_page.dart
│           └── widgets/
│               ├── settings_tile.dart
│               └── security_toggle.dart
│
└── shared/                            # Shared components
    ├── widgets/
    │   ├── loading_widget.dart        # Common loading indicators
    │   ├── error_widget.dart          # Error display widgets
    │   ├── empty_state_widget.dart    # Empty state displays
    │   ├── custom_button.dart         # Reusable buttons
    │   ├── custom_text_field.dart     # Custom input fields
    │   └── bottom_navigation.dart     # App bottom navigation
    ├── models/
    │   ├── api_response.dart          # Generic API response
    │   └── base_entity.dart           # Base entity class
    ├── services/
    │   ├── notification_service.dart  # Push notifications
    │   ├── analytics_service.dart     # Analytics tracking
    │   └── biometric_service.dart     # Biometric authentication
    └── validators/
        ├── pin_validator.dart         # PIN validation rules
        ├── did_validator.dart         # DID format validation
        └── credential_validator.dart  # Credential validation
```

## 🎯 Lợi ích của kiến trúc này

### 1. **Separation of Concerns**
- Mỗi layer có trách nhiệm rõ ràng
- Business logic tách biệt khỏi UI
- Data layer độc lập với presentation

### 2. **Testability**
- Dễ dàng unit test từng layer
- Mock dependencies một cách đơn giản
- Test coverage cao hơn

### 3. **Scalability**
- Thêm features mới mà không ảnh hưởng code cũ
- Team có thể làm việc parallel trên các features
- Dễ dàng maintain và debug

### 4. **Reusability**
- Shared components có thể tái sử dụng
- Business logic có thể share giữa platforms
- Consistent UI/UX patterns

### 5. **Clean Dependencies**
- Domain layer không phụ thuộc vào implementation
- Infrastructure có thể thay đổi mà không ảnh hưởng business logic
- Dependency inversion principle

## 🔧 Technology Stack đề xuất

### State Management
```dart
// Thay Provider bằng BLoC cho complex state
dependencies:
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
```

### Dependency Injection
```dart
dependencies:
  get_it: ^7.6.4
  injectable: ^2.3.2
```

### Storage & Security
```dart
dependencies:
  flutter_secure_storage: ^9.0.0
  hive: ^4.0.0
  hive_flutter: ^1.1.0
```

### Network & API
```dart
dependencies:
  dio: ^5.3.2
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
```

### Code Generation
```dart
dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
```

## 📋 Migration Plan

### Phase 1: Core Infrastructure
1. Setup dependency injection
2. Implement error handling
3. Create base classes và interfaces

### Phase 2: Refactor Authentication
1. Move auth logic sang Clean Architecture
2. Implement proper security
3. Add comprehensive testing

### Phase 3: Credentials & DIDs
1. Refactor existing features
2. Add blockchain integration
3. Implement verifiable credentials

### Phase 4: Additional Features
1. QR scanner implementation
2. Advanced settings
3. Analytics và monitoring

## 🧪 Testing Strategy

```
test/
├── unit/
│   ├── features/
│   │   ├── auth/
│   │   ├── credentials/
│   │   └── dids/
│   └── core/
├── widget/
│   ├── auth/
│   ├── credentials/
│   └── dids/
└── integration/
    ├── auth_flow_test.dart
    ├── credential_management_test.dart
    └── did_operations_test.dart
```

Kiến trúc này sẽ giúp project dễ dàng scale, maintain và phát triển trong tương lai! 