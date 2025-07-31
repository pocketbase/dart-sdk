/// Multi-platform [Future]-based library for interacting with the
/// [PocketBase API](https://pocketbase.io/docs/).
library;

// main
export "src/async_auth_store.dart";
export "src/auth_store.dart";
export "src/client.dart";
export "src/client_exception.dart";

// dtos
export "src/dtos/apple_client_secret.dart";
export "src/dtos/auth_alert_config.dart";
export "src/dtos/auth_method_mfa.dart";
export "src/dtos/auth_method_oauth2.dart";
export "src/dtos/auth_method_otp.dart";
export "src/dtos/auth_method_password.dart";
export "src/dtos/auth_method_provider.dart";
export "src/dtos/auth_methods_list.dart";
export "src/dtos/backup_file_info.dart";
export "src/dtos/batch_result.dart";
export "src/dtos/collection_field.dart";
export "src/dtos/collection_model.dart";
export "src/dtos/cron_job.dart";
export "src/dtos/email_template_config.dart";
export "src/dtos/health_check.dart";
export "src/dtos/jsonable.dart";
export "src/dtos/log_model.dart";
export "src/dtos/log_stat.dart";
export "src/dtos/mfa_config.dart";
export "src/dtos/oauth2_config.dart";
export "src/dtos/otp_config.dart";
export "src/dtos/otp_response.dart";
export "src/dtos/password_auth_config.dart";
export "src/dtos/record_auth.dart";
export "src/dtos/record_model.dart";
export "src/dtos/record_subscription_event.dart";
export "src/dtos/result_list.dart";
export "src/dtos/token_config.dart";

// services (exported mainly for dartdoc - https://github.com/dart-lang/dartdoc/issues/2154)
export "src/services/backup_service.dart";
export "src/services/base_crud_service.dart";
export "src/services/batch_service.dart";
export "src/services/collection_service.dart";
export "src/services/cron_service.dart";
export "src/services/file_service.dart";
export "src/services/health_service.dart";
export "src/services/log_service.dart";
export "src/services/realtime_service.dart";
export "src/services/record_service.dart";
export "src/services/settings_service.dart";
