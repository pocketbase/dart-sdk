import 'dart:async';

import "package:http/http.dart" as http;

import "../client.dart";
import "../client_exception.dart";
import "../dtos/auth_method_provider.dart";
import "../dtos/auth_methods_list.dart";
import "../dtos/external_auth_model.dart";
import "../dtos/record_auth.dart";
import "../dtos/record_model.dart";
import "../dtos/record_subscription_event.dart";
import "base_crud_service.dart";
import "realtime_service.dart";

/// The definition of a realtime record subscription callback function.
typedef RecordSubscriptionFunc = void Function(RecordSubscriptionEvent e);

typedef OAuth2UrlCallbackFunc = void Function(Uri url);

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

  ///
  /// Subscribe to realtime changes to the specified topic ("*" or record id).
  ///
  /// If [topic] is the wildcard "*", then this method will subscribe to
  /// any record changes in the collection.
  ///
  /// If [topic] is a record id, then this method will subscribe only
  /// to changes of the specified record id.
  ///
  /// It's OK to subscribe multiple times to the same topic.
  ///
  /// You can use the returned [UnsubscribeFunc] to remove the subscription.
  /// Or use [unsubscribe(topic)] if you want to remove all
  /// subscriptions attached to the topic.
  Future<UnsubscribeFunc> subscribe(
      String topic, RecordSubscriptionFunc callback) {
    // @todo after v0.8 change to just "$_collectionIdOrName/$topic"
    var subscribeTopic = _collectionIdOrName;
    if (topic != "*") {
      subscribeTopic += "/$topic";
    }

    return client.realtime.subscribe(subscribeTopic, (e) {
      callback(RecordSubscriptionEvent.fromJson(e.jsonData()));
    });
  }

  /// Unsubscribe from all subscriptions of the specified topic
  /// ("*" or record id).
  ///
  /// If [topic] is not set, then this method will unsubscribe from
  /// all subscriptions associated to the current collection.
  Future<void> unsubscribe([String topic = ""]) {
    if (topic.isNotEmpty) {
      // @todo after v0.8 change to just "$_collectionIdOrName/$topic"
      var unsubscribeTopic = _collectionIdOrName;
      if (topic != "*") {
        unsubscribeTopic += "/$topic";
      }

      return client.realtime.unsubscribe(unsubscribeTopic);
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
          (client.authStore.model as RecordModel).id == item.id &&
          [
            (client.authStore.model as RecordModel).collectionId,
            (client.authStore.model as RecordModel).collectionName,
          ].contains(_collectionIdOrName)) {
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
          (client.authStore.model as RecordModel).id == id &&
          [
            (client.authStore.model as RecordModel).collectionId,
            (client.authStore.model as RecordModel).collectionName,
          ].contains(_collectionIdOrName)) {
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

    return client
        .send(
          "$baseCollectionPath/auth-with-password",
          method: "POST",
          body: enrichedBody,
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => _authResponse(data as Map<String, dynamic>? ?? {}));
  }

  /// Authenticate an auth record with an OAuth2 client provider and returns
  /// a new auth token and record data (including the OAuth2 user profile).
  ///
  /// On success this method automatically updates the client's AuthStore.
  Future<RecordAuth> authWithOAuth2Code(
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

  /// Authenticate a single auth collection record with OAuth2
  /// **without custom redirects, deeplinks or even page reload**.
  ///
  /// This method initializes a one-off realtime subscription and will
  /// call [urlCallback] with the OAuth2 vendor url to authenticate.
  /// Once the external OAuth2 sign-in/sign-up flow is completed, the popup
  /// window will be automatically closed and the OAuth2 data sent back
  /// to the user through the previously established realtime connection.
  ///
  /// On success this method automatically updates the client's AuthStore.
  ///
  /// Example:
  ///
  /// ```dart
  /// await pb.collection('users').authWithOAuth2('google', (url) async {
  ///   await launchUrl(url);
  /// });
  /// ```
  ///
  /// _Site-note_: when creating the OAuth2 app in the provider dashboard
  /// you have to configure `https://yourdomain.com/api/oauth2-redirect`
  /// as redirect URL.
  Future<RecordAuth> authWithOAuth2(
    String providerName,
    OAuth2UrlCallbackFunc urlCallback, {
    List<String> scopes = const [],
    Map<String, dynamic> createData = const {},
    String? expand,
  }) async {
    final authMethods = await listAuthMethods();

    final AuthMethodProvider provider;
    try {
      provider =
          authMethods.authProviders.firstWhere((p) => p.name == providerName);
    } catch (err) {
      throw ClientException(originalError: err);
    }

    final redirectUrl = client.buildUrl("/api/oauth2-redirect");

    final completer = Completer<RecordAuth>();

    Future<void> Function()? unsubscribeFunc;

    try {
      unsubscribeFunc = await client.realtime.subscribe("@oauth2", (e) async {
        final oldState = client.realtime.clientId;

        try {
          final eventData = e.jsonData();
          final code = eventData["code"] as String? ?? "";
          final state = eventData["state"] as String? ?? "";

          if (state.isEmpty || state != oldState) {
            throw StateError("State parameters don't match.");
          }

          final auth = await authWithOAuth2Code(
            provider.name,
            code,
            provider.codeVerifier,
            redirectUrl.toString(),
            createData: createData,
            expand: expand,
          );

          completer.complete(auth);

          if (unsubscribeFunc != null) {
            unawaited(unsubscribeFunc());
          }
        } catch (err) {
          if (err is ClientException) {
            completer.completeError(err);
          } else {
            completer.completeError(ClientException(originalError: err));
          }
        }
      });

      final authUrl = Uri.parse(provider.authUrl + redirectUrl.toString());

      final queryParameters = Map<String, String>.of(authUrl.queryParameters);
      queryParameters["state"] = client.realtime.clientId;

      // set custom scopes (if any)
      if (scopes.isNotEmpty) {
        queryParameters["scope"] = scopes.join(" ");
      }

      urlCallback(authUrl.replace(queryParameters: queryParameters));
    } catch (err) {
      if (err is ClientException) {
        completer.completeError(err);
      } else {
        completer.completeError(ClientException(originalError: err));
      }
    }

    return completer.future;
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
      "$baseCollectionPath/confirm-password-reset",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
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
  Future<void> confirmVerification(
    String verificationToken, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = verificationToken;

    return client.send(
      "$baseCollectionPath/confirm-verification",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
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
  Future<void> confirmEmailChange(
    String emailChangeToken,
    String userPassword, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["token"] = emailChangeToken;
    enrichedBody["password"] = userPassword;

    return client.send(
      "$baseCollectionPath/confirm-email-change",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
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
