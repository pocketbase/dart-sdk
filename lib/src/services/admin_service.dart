import "../client.dart";
import "../dtos/admin_auth.dart";
import "../dtos/admin_model.dart";
import "base_crud_service.dart";

/// The service that handles the **Admin APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.admins] should be used.
class AdminService extends CrudService<AdminModel> {
  AdminService(PocketBase client) : super(client);

  @override
  String get basePath => "/api/admins";

  @override
  AdminModel itemFactoryFunc(Map<String, dynamic> json) =>
      AdminModel.fromJson(json);

  /// Prepare successfull admin authentication response.
  AdminAuth _authResponse(Map<String, dynamic> data) {
    final auth = AdminAuth.fromJson(data);

    client.authStore.save(auth.token, auth.admin);

    return auth;
  }

  /// Authenticate an admin account by its email and password
  /// and returns a new auth token and admin data.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<AdminAuth> authViaEmail(
    String email,
    String password, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] = email;
    enrichedBody["password"] = password;

    final enrichedHeaders = Map<String, String>.of(headers);
    enrichedHeaders["Authorization"] = ""; // the request doesn't require auth

    return client
        .send(
          "$basePath/auth-via-email",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: enrichedHeaders,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Refreshes the current admin authenticated instance and
  /// returns a new auth token and admin data.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<AdminAuth> refresh({
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "$basePath/refresh",
          method: "POST",
          body: body,
          query: query,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Sends admin password reset request.
  Future<void> requestPasswordReset(
    String email, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] = email;

    return client.send(
      "$basePath/request-password-reset",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms admin password reset request.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<AdminAuth> confirmPasswordReset(
    String passwordResetToken,
    String password,
    String passwordConfirm, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = passwordResetToken;
    enrichedBody["password"] = password;
    enrichedBody["passwordConfirm"] = passwordConfirm;

    return client
        .send(
          "$basePath/confirm-password-reset",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }
}
