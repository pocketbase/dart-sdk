/// Multi-platform [Future]-based library for interacting with the
/// [PocketBase API](https://pocketbase.io/docs/).
library pocketbase;

// main
export "src/auth_store.dart";
export "src/client.dart";
export "src/client_exception.dart";

// dtos
export "src/dtos/admin_auth.dart";
export "src/dtos/admin_model.dart";
export "src/dtos/apple_client_secret.dart";
export "src/dtos/auth_method_provider.dart";
export "src/dtos/auth_methods_list.dart";
export "src/dtos/backup_file_info.dart";
export "src/dtos/collection_model.dart";
export "src/dtos/external_auth_model.dart";
export "src/dtos/health_check.dart";
export "src/dtos/jsonable.dart";
export "src/dtos/log_request_model.dart";
export "src/dtos/log_request_stat.dart";
export "src/dtos/record_auth.dart";
export "src/dtos/record_model.dart";
export "src/dtos/record_subscription_event.dart";
export "src/dtos/result_list.dart";
export "src/dtos/schema_field.dart";

// services (exported mainly for dartdoc - https://github.com/dart-lang/dartdoc/issues/2154)
export "src/services/admin_service.dart";
export "src/services/backup_service.dart";
export "src/services/base_crud_service.dart";
export "src/services/collection_service.dart";
export "src/services/file_service.dart";
export "src/services/health_service.dart";
export "src/services/log_service.dart";
export "src/services/realtime_service.dart";
export "src/services/record_service.dart";
export "src/services/settings_service.dart";
