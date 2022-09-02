import "../client.dart";
import "../dtos/auth_methods_list.dart";
import "../dtos/user_auth.dart";
import "../dtos/user_model.dart";
import "../dtos/external_auth_model.dart";
import "base_crud_service.dart";

/// The service that handles the **User APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.users] should be used.
class UserService extends CrudService<UserModel> {
  UserService(PocketBase client) : super(client);

  @override
  String get basePath => "/api/users";

  @override
  UserModel itemFactoryFunc(Map<String, dynamic> json) =>
      UserModel.fromJson(json);

  /// Prepare successful user authentication response.
  UserAuth _authResponse(Map<String, dynamic> data) {
    final auth = UserAuth.fromJson(data);

    client.authStore.save(auth.token, auth.user);

    return auth;
  }

  /// Returns all available application auth methods.
  Future<AuthMethodsList> listAuthMethods({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "$basePath/auth-methods",
          query: query,
          headers: headers,
        )
        .then((data) =>
            AuthMethodsList.fromJson(data as Map<String, dynamic>? ?? {}));
  }

  /// Authenticate a user account by its email and password and returns
  /// a new user token and data.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> authViaEmail(
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

  /// Authenticate a user via OAuth2 client provider and returns
  /// a new user token and data (including the OAuth2 user profile).
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> authViaOAuth2(
    String provider,
    String code,
    String codeVerifier,
    String redirectUrl, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["provider"] = provider;
    enrichedBody["code"] = code;
    enrichedBody["codeVerifier"] = codeVerifier;
    enrichedBody["redirectUrl"] = redirectUrl;

    final enrichedHeaders = Map<String, String>.of(headers);
    enrichedHeaders["Authorization"] = ""; // the request doesn't require auth

    return client
        .send(
          "$basePath/auth-via-oauth2",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: enrichedHeaders,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Refreshes the current user authenticated instance and
  /// returns a new token and user data.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> refresh({
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

  /// Sends user password reset request.
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

  /// Confirms user password reset request.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> confirmPasswordReset(
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

  /// Sends user verification email request.
  Future<void> requestVerification(
    String email, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] = email;

    return client.send(
      "$basePath/request-verification",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms user email verification request.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> confirmVerification(
    String verificationToken, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = verificationToken;

    return client
        .send(
          "$basePath/confirm-verification",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Sends a user email change request to the provided email.
  Future<void> requestEmailChange(
    String newEmail, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["newEmail"] = newEmail;

    return client.send(
      "$basePath/request-email-change",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms user new email address.
  ///
  /// On success this method automatically updates the client"s AuthStore.
  Future<UserAuth> confirmEmailChange(
    String emailChangeToken,
    String userPassword, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = emailChangeToken;
    enrichedBody["password"] = userPassword;

    return client
        .send(
          "$basePath/confirm-email-change",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Lists all linked external auth providers for the specified user.
  Future<List<ExternalAuthModel>> listExternalAuths(
    String userId, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
      "$basePath/${Uri.encodeComponent(userId)}/external-auths",
      query: query,
      headers: headers,
    )
        .then((data) {
      return (data as List<dynamic>)
          .map(
            (item) => ExternalAuthModel.fromJson(item as Map<String, dynamic>),
          )
          .toList()
          .cast<ExternalAuthModel>();
    });
  }

  /// Unlinks a single external auth provider relation from the specified user.
  Future<void> unlinkExternalAuth(
    String userId,
    String provider, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "$basePath/${Uri.encodeComponent(userId)}/external-auths/${Uri.encodeComponent(provider)}",
      method: "DELETE",
      query: query,
      body: body,
      headers: headers,
    );
  }
}
