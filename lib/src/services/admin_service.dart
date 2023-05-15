import "package:http/http.dart" as http;

import "../client.dart";
import "../dtos/admin_auth.dart";
import "../dtos/auth_model.dart" show AdminModel;
import "base_crud_service.dart";

/// The service that handles the **Admin APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.admins] should be used.
class AdminService extends BaseCrudService<AdminModel> {
  AdminService(PocketBase client) : super(client);

  @override
  String get baseCrudPath => "/api/admins";

  @override
  AdminModel itemFactoryFunc(Map<String, dynamic> json) =>
      AdminModel.fromJson(json);

  // ---------------------------------------------------------------
  // Post update/delete AuthStore sync
  // ---------------------------------------------------------------

  /// Updates a single admin model by its id.
  ///
  /// If the current AuthStore.model matches with the updated id, then
  /// on success the client AuthStore will be updated with the result model.
  @override
  Future<AdminModel> update(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
    String? expand,
  }) {
    return super
        .update(
      id,
      body: body,
      query: query,
      files: files,
      headers: headers,
      expand: expand,
    )
        .then((item) {
      if (client.authStore.model != null &&
          client.authStore.model is AdminModel &&
          (client.authStore.model as AdminModel).id == item.id) {
        client.authStore.save(client.authStore.token, item);
      }

      return item;
    });
  }

  /// Deletes a single admin model by its id.
  ///
  /// If the current AuthStore.model matches with the deleted id,
  /// then on success the client AuthStore will be also cleared.
  @override
  Future<void> delete(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return super
        .delete(
      id,
      body: body,
      query: query,
      headers: headers,
    )
        .then((_) {
      if (client.authStore.model != null &&
          client.authStore.model is AdminModel &&
          (client.authStore.model as AdminModel).id == id) {
        client.authStore.clear();
      }

      return;
    });
  }

  // -----------------------------------------------------------------
  // Auth collection handlers
  // -----------------------------------------------------------------

  /// Prepare successful admin authentication response.
  AdminAuth _authResponse(Map<String, dynamic> data) {
    final auth = AdminAuth.fromJson(data);

    client.authStore.save(auth.token, auth.admin);

    return auth;
  }

  /// Authenticate an admin account by its email and password
  /// and returns a new auth token and admin data.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<AdminAuth> authWithPassword(
    String email,
    String password, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["identity"] = email;
    enrichedBody["password"] = password;

    return client
        .send(
          "$baseCrudPath/auth-with-password",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: headers,
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
          "$baseCrudPath/auth-refresh",
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
      "$baseCrudPath/request-password-reset",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms admin password reset request.
  Future<void> confirmPasswordReset(
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

    return client.send(
      "$baseCrudPath/confirm-password-reset",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }
}
