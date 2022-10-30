import "package:http/http.dart" as http;

import "../client.dart";
import "../dtos/auth_methods_list.dart";
import "../dtos/external_auth_model.dart";
import "../dtos/record_auth.dart";
import "../dtos/record_model.dart";
import "../dtos/record_subscription_event.dart";
import "base_crud_service.dart";

/// The definition of a realtime record subscription callback function.
typedef RecordSubscriptionFunc = void Function(RecordSubscriptionEvent e);

/// The service that handles the **Record APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.collection("COLLECTION")] should be used.
class RecordService extends BaseCrudService<RecordModel> {
  RecordService(PocketBase client, this._collectionIdOrName) : super(client);

  final String _collectionIdOrName;

  /// Returns the current collection service base path.
  String get baseCollectionPath =>
      "/api/collections/${Uri.encodeComponent(_collectionIdOrName)}";

  @override
  String get baseCrudPath => "$baseCollectionPath/records";

  @override
  RecordModel itemFactoryFunc(Map<String, dynamic> json) =>
      RecordModel.fromJson(json);

  // -----------------------------------------------------------------
  // Realtime handlers
  // -----------------------------------------------------------------

  /// Subscribe to the realtime changes of any record from the collection.
  Future<void> subscribe(RecordSubscriptionFunc callback) {
    return client.realtime.subscribe(_collectionIdOrName, (e) {
      callback(RecordSubscriptionEvent.fromJson(e.jsonData()));
    });
  }

  /// Subscribe to the realtime changes of a single record in the collection.
  Future<void> subscribeOne(String recordId, RecordSubscriptionFunc callback) {
    return client.realtime.subscribe(
      "$_collectionIdOrName/$recordId",
      (e) {
        callback(RecordSubscriptionEvent.fromJson(e.jsonData()));
      },
    );
  }

  /// Unsubscribe from the collection record subscription(s).
  ///
  /// If `recordId` is not set, then this method will unsubscribe from
  /// all subscriptions associated to the current collection.
  Future<void> unsubscribe([String recordId = ""]) {
    if (recordId.isNotEmpty) {
      return client.realtime.unsubscribe("$_collectionIdOrName/$recordId");
    }

    return client.realtime.unsubscribeByPrefix(_collectionIdOrName);
  }

  // ---------------------------------------------------------------
  // Post update/delete AuthStore sync
  // ---------------------------------------------------------------

  /// Updates a single record model by its id.
  ///
  /// If the current AuthStore.model matches with the updated id, then
  /// on success the client AuthStore will be updated with the result model.
  @override
  Future<RecordModel> update(
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
          client.authStore.model is RecordModel &&
          (client.authStore.model as RecordModel).id == item.id) {
        client.authStore.save(client.authStore.token, item);
      }

      return item;
    });
  }

  /// Deletes a single record model by its id.
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
          client.authStore.model is RecordModel &&
          (client.authStore.model as RecordModel).id == id) {
        client.authStore.clear();
      }

      return;
    });
  }

  // -----------------------------------------------------------------
  // Auth collection handlers
  // -----------------------------------------------------------------

  /// Prepare successful record authentication response.
  RecordAuth _authResponse(Map<String, dynamic> data) {
    final auth = RecordAuth.fromJson(data);

    client.authStore.save(auth.token, auth.record);

    return auth;
  }

  /// Returns all available application auth methods.
  Future<AuthMethodsList> listAuthMethods({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "$baseCollectionPath/auth-methods",
          query: query,
          headers: headers,
        )
        .then((data) =>
            AuthMethodsList.fromJson(data as Map<String, dynamic>? ?? {}));
  }

  /// Authenticate an auth record by its username/email and password
  /// and returns a new auth token and record data.
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> authWithPassword(
    String usernameOrEmail,
    String password, {
    String? expand,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["identity"] = usernameOrEmail;
    enrichedBody["password"] = password;

    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    final enrichedHeaders = Map<String, String>.of(headers);
    enrichedHeaders["Authorization"] = ""; // the request doesn't require auth

    return client
        .send(
          "$baseCollectionPath/auth-with-password",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: enrichedHeaders,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Authenticate an auth record with an OAuth2 client provider and returns
  /// a new auth token and record data (including the OAuth2 user profile).
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> authWithOAuth2(
    String provider,
    String code,
    String codeVerifier,
    String redirectUrl, {
    Map<String, dynamic> createData = const {},
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
    String? expand,
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["provider"] = provider;
    enrichedBody["code"] = code;
    enrichedBody["codeVerifier"] = codeVerifier;
    enrichedBody["redirectUrl"] = redirectUrl;
    enrichedBody["createData"] ??= createData;

    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    return client
        .send(
          "$baseCollectionPath/auth-with-oauth2",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Refreshes the current authenticated auth record instance and
  /// returns a new token and record data.
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> authRefresh({
    String? expand,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    return client
        .send(
          "$baseCollectionPath/auth-refresh",
          method: "POST",
          body: body,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Sends auth record password reset request.
  Future<void> requestPasswordReset(
    String email, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] = email;

    return client.send(
      "$baseCollectionPath/request-password-reset",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms auth record password reset request.
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> confirmPasswordReset(
    String passwordResetToken,
    String password,
    String passwordConfirm, {
    String? expand,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = passwordResetToken;
    enrichedBody["password"] = password;
    enrichedBody["passwordConfirm"] = passwordConfirm;

    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    return client
        .send(
          "$baseCollectionPath/confirm-password-reset",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Sends auth record verification email request.
  Future<void> requestVerification(
    String email, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] = email;

    return client.send(
      "$baseCollectionPath/request-verification",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms auth record email verification request.
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> confirmVerification(
    String verificationToken, {
    String? expand,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = verificationToken;

    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    return client
        .send(
          "$baseCollectionPath/confirm-verification",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Sends auth record email change request to the provided email.
  Future<void> requestEmailChange(
    String newEmail, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["newEmail"] = newEmail;

    return client.send(
      "$baseCollectionPath/request-email-change",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Confirms auth record new email address.
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> confirmEmailChange(
    String emailChangeToken,
    String userPassword, {
    String? expand,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = emailChangeToken;
    enrichedBody["password"] = userPassword;

    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;

    return client
        .send(
          "$baseCollectionPath/confirm-email-change",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Lists all linked external auth providers for the specified record.
  Future<List<ExternalAuthModel>> listExternalAuths(
    String recordId, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
      "$baseCrudPath/${Uri.encodeComponent(recordId)}/external-auths",
      query: query,
      headers: headers,
    )
        .then((data) {
      return (data as List<dynamic>)
          .map((item) =>
              ExternalAuthModel.fromJson(item as Map<String, dynamic>))
          .toList()
          .cast<ExternalAuthModel>();
    });
  }

  /// Unlinks a single external auth provider relation from the
  /// specified record.
  Future<void> unlinkExternalAuth(
    String recordId,
    String provider, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "$baseCrudPath/${Uri.encodeComponent(recordId)}/external-auths/${Uri.encodeComponent(provider)}",
      method: "DELETE",
      query: query,
      body: body,
      headers: headers,
    );
  }
}
