## 0.23.1

- Fixed a bug with the "all-in-one" OAuth2 flow that prevented successfully authenticating second time after a failed/canceled attempt ([#76](https://github.com/pocketbase/dart-sdk/issues/76)).


## 0.23.0+1

- Added [note in the README](https://github.com/pocketbase/dart-sdk#oauth2-and-android-15) about Android 15+ and the "All-in-one" OAuth2 flow.


## 0.23.0

- Added `reuseHTTPClient` `PocketBase` constructor parameter to initialize a single HTTP client and reuse it for all requests, in order to improve slightly the performance by keeping a persistent connection.
  More details you can find in the ["Optional HTTP client reuse" section in the README](https://github.com/pocketbase/dart-sdk#optional-http-client-reuse).


## 0.22.0

- Bumped `http` to min 1.3 to enable streamed responses on the web.
  _If you have previously relied on `fetch_client` for the realtime subscriptions, with this release it should no longer be necessary and the custom `httpClientFactory` instantiation can be removed._


## 0.21.0

- Added `pb.crons` service to interact with the cron Web APIs.


## 0.20.0

- Added optional `pb.realtime.onDisconnect` hook function.
  _Note that the realtime client autoreconnect on its own and this hook is useful only for the cases where you want to apply a special behavior on server error or after closing the realtime connection._


## 0.19.1

**⚠️ This release works only with PocketBase v0.23.0+.**

- Added annotation to exclude the deprecated `RecordModel.expand` key from the parent JSON serialization ([pocketbase#5946](https://github.com/pocketbase/pocketbase/issues/5946)).

- Added `RecordModel.set` for consistency with `RecordModel.get`.


## 0.19.0

**⚠️ This release introduces some breaking changes and works only with PocketBase v0.23.0+.**

- Added support for sending batch/transactional create/updated/delete/**upsert** requests with the new batch Web APIs.
    ```dart
    final batch = pb.createBatch();

    batch.collection('example1').create(body: { ... });
    batch.collection('example2').update('RECORD_ID', body: { ... });
    batch.collection('example3').delete('RECORD_ID');
    batch.collection('example4').upsert(body: { ... });

    final result = await batch.send();
    ```

- Added support for authenticating with OTP (email code):
    ```dart
    final result = await pb.collection('users').requestOTP('test@example.com');

    // ... show a modal for users to check their email and to enter the received code ...

    await pb.collection('users').authWithOTP(result.otpId, 'EMAIL_CODE');
    ```

    Note that PocketBase v0.23.0 comes also with Multi-factor authentication (MFA) support.
    When enabled from the dashboard, the first auth attempt will result in 401 response and a `mfaId` response,
    that will have to be submitted with the second auth request. For example:
    ```dart
    try {
      await pb.collection('users').authWithPassword('test@example.com', '1234567890');
    } on ClientException catch (e) {
      final mfaId = e.response['mfaId'];
      if (mfaId == null) {
        throw e; // not mfa -> rethrow
      }

      // the user needs to authenticate again with another auth method, for example OTP
      final result = await pb.collection('users').requestOTP('test@example.com');
      // ... show a modal for users to check their email and to enter the received code ...
      await pb.collection('users').authWithOTP(result.otpId, 'EMAIL_CODE', query: { 'mfaId': mfaId });
    }
    ```

- Added "impersonate" support for superusers to create a non-refreshable auth token for any other auth record:
    ```dart
    // authenticate as superuser
    await pb.collection('_superusers').authWithPassword('test@example.com', '1234567890');

    // create a new auth token for the specified user loaded in a new PocketBase client
    final userClient = pb.collection('users').impersonate('RECORD_ID', 0);

    // send the request as the impersonated user
    final result = await userClient.collection('example').getFullList();
    ```

- Added optional `collection` argument to `SettingsService.testEmail()` to allow target the email templates of a specific auth collection.

- Added `pb.collections.getScaffolds()` method to return a collection type indexed map with blank collection models loaded with their type specific defaults.

- Added `pb.collections.truncate(idOrName)` method to delete all records associated with the specified collection.

- Added `body`, `query`, `headers` optional arguments to `authWithOAuth2()` ([#62](https://github.com/pocketbase/dart-sdk/issues/62)).

- Instead of replacing the entire `pb.authStore.record`, on auth record update we now only replace the available returned response record data ([pocketbase#5638](https://github.com/pocketbase/pocketbase/issues/5638)).

- ⚠️ Soft-deprecated and aliased `pb.admins` because with PockeBase v0.23+ admins are now stored as regular `_superusers` collection records.
    ```dart
    // before   ->  after
    pb.admins.* ->  pb.collection('_superusers').*
    ```

- Since there is no longer `AdminModel`, `pb.authStore.model` is superseeded by `pb.authStore.record`.

- ⚠️ Changes to the `RecordModel`:
    - Simplified constructor - `RecordModel([Map<String, dynamic>? data])`.
    - Simplified new accessor method `get<T>(key, fallback)`.
      It works with all record data, including nested `expand` properties, not just the regular record fields!
      ```dart
      final price     = record.get<double>('price');
      final user      = record.get<RecordModel>('expand.user', null);
      final userEmail = record.get<String>('expand.user.email', 'N/A');
      ```

- ⚠️ Flatten the `CollectionModel` model fields, aka. there is no longer
  the dynamic `CollectionModel.options` map and every Collection type field is added as member to the class.

- ⚠️ Changed `AuthMethodsList` fields to accomodate the new auth methods and `listAuthMethods()` response.
    ```
    {
      "mfa": {
        "duration": 100,
        "enabled": true
      },
      "otp": {
        "duration": 0,
        "enabled": false
      },
      "password": {
        "enabled": true,
        "identityFields": ["email", "username"]
      },
      "oauth2": {
        "enabled": true,
        "providers": [{"name": "gitlab", ...}, {"name": "google", ...}]
      }
    }
    ```

- ⚠️ Soft-deprecated the OAuth2 success auth `meta["avatarUrl"]` response field in favour of `meta["avatarURL"]` for consistency with the JS SDK and the accepted Go API conventions.

- ⚠️ Soft-deprecated and aliased `*Url()` -> `*URL()` fields and methods for consistency with the JS SDK and the accepted Go API conventions.
    _The old methods still works but you may get a analyzer warnings to replace them because they will be removed in the future._
    ```js
    pb.baseUrl                  -> pb.baseURL
    pb.buildUrl()               -> pb.buildURL()
    pb.files.getUrl()           -> pb.files.getURL()
    pb.backups.getDownloadUrl() -> pb.backups.getDownloadURL()
    ```

- ⚠️ Removed `RecordService.listExternalAuths()` and `RecordService.unlinkExternalAuth()` methods because `_externalAuths` is now a regular collection:
    ```dart
    // old: pb.collection('users').listExternalAuths("RECORD_ID")
    pb.collection("_externalAuths").getFullList()

    // old: pb.collection('users').unlinkExternalAuth("RECORD_ID", "provider")
    pb.collection("_externalAuths").delete("EXTERNAL_AUTH_RECORD_ID")
    ```

- ⚠️ Renamed `CollectionModel.schema` to `CollectionModel.fields`.

- ⚠️ Renamed class `SchemaField` to `CollectionField`.


## 0.18.1

- Manually update the verified state of the current matching `AuthStore` model on successful "confirm-verification" call.

- Manually clear the current matching `AuthStore` on "confirm-email-change" call because previous tokens are always invalidated.


## 0.18.0

**⚠️ This release works only with PocketBase v0.21.0+ due to changes of how the `multipart/form-data` body is handled.**

- Properly sent json body with `multipart/form-data` requests.
  _This fixes a similar issue described in [js-sdk#274](https://github.com/pocketbase/js-sdk/issues/274)._

- Gracefully handle OAuth2 redirect error with the `authWithOAuth2()` call.


## 0.17.1

- Throw 404 `ClientException` on `getOne("")`  with empty id.


## 0.17.0

- Added experimental `expand`, `filter`, `fields`, custom query and headers parameters support for the realtime subscriptions.
    ```dart
    pb.collection("example").subscribe("*", (e) {
      ...
    }, filter: "someField > 10");
    ```
    _This works only with PocketBase v0.20.0+._

- Changes to the logs service methods in relation to the logs generalization in PocketBase v0.20.0+:
    ```dart
    pb.logs.getRequestsList(...)  -> pb.logs.getList(...)
    pb.logs.getRequest(...)       -> pb.logs.getOne(...)
    pb.logs.getRequestsStats(...) -> pb.logs.getStats(...)
    ```

- Added missing `SchemaField.presentable` bool field.

- Added new `AuthMethodProvider.displayName` string field.

- Added new `AuthMethodsList.onlyVerified` bool field.


## 0.16.0

- Added `pb.filter(rawExpr, params?)` helper to construct a filter string with placeholder parameters populated from a `Map`.

    ```dart
    final records = await pb.collection("example").getList(filter: pb.filter(
      // the same as: "title ~ 'exa\\'mple' && created = '2023-10-18 18:20:00.123Z'"
      "title ~ {:title} && created >= {:created}",
      { "title": "exa'mple", "created": DateTime.now() },
    ));
    ```

    The supported placeholder parameter values are:

    - `String` (_single quotes are autoescaped_)
    - `DateTime`
    - `bool`
    - `num`
    - `null`
    - everything else is converted to a string using `jsonEncode()`


## 0.15.1

- Fixed `multipart/form-data` body serialization when `null` values are submitted ([#48](https://github.com/pocketbase/dart-sdk/issues/48)).


## 0.15.0

- Added `pb.backups.upload(file)` action (_available with PocketBase v0.18.0_).


## 0.14.1

- `pb.files.getUrl()` now returns empty URI in case an empty filename is passed.


## 0.14.0+2

- Run `dart formatter`.


## 0.14.0+1

- Updated the examples in README.


## 0.14.0

- Added new generic `RecordModel.getDataValue<T>(key, [default])` data value getter to support retrieval of any value type.
  We now also allow accessing nested json object values via dot-notation.
  For example:
  ```dart
  final record = RecordModel(data: {"a": {"b": [{"b1": 1}, {"b2": 2}, {"b3": 3}]}});

  record.getDataValue<int>("a.b.1.b2", 2); // 2
  record.getDataValue<int>("a.b.c");       // 0 (no explicit default)
  record.getDataValue<int>("a.b.c", -1);   // -1 (explicit default)
  ```
  The old `RecordModel` getters are aliased to use `getDataValue`.
  ```
  getStringValue(field)   is the same as  getDataValue<String>(field)
  getBoolValue(field)     is the same as  getDataValue<bool>(field)
  getIntValue(field)      is the same as  getDataValue<int>(field)
  getDoubleValue(field)   is the same as  getDataValue<double>(field)
  getListValue<T>(field)  is the same as  getDataValue<List<T>>(field)
  ```


## 0.13.0

- Added new `AsyncAuthStore` helper class that could be used with any external async persistent layer (shared_preferences, hive, local file, etc.).
  For example:
  ```dart
  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
   save:    (String data) async => prefs.setString('pb_auth', data),
   initial: prefs.getString('pb_auth'),
  );

  final pb = PocketBase('http://example.com', authStore: store);
  ```


## 0.12.0

- Require Dart 3.0 or later.


## 0.11.0

- Added `skipTotal=1` query parameter by default for the `getFirstListItem()` and `getFullList()` requests.
  _Note that this have performance boost only with PocketBase v0.17+._

- Added optional `download=1` query parameter to force file urls with `Content-Disposition: attachment` (_supported with PocketBase v0.17+_).


## 0.10.3

- Explicitly disable `BaseRequest.persistentConnection` since it is
  ignored anyway when using the default `dart-lang/http.Cient` on Web
  and it is [causing issues](https://github.com/Zekfad/fetch_client/issues/6)
  with the alternative `fetch_client` package.


## 0.10.2

- Modified the original `http.MultipartRequest` to support List field values ([pocketbase#2763](https://github.com/pocketbase/pocketbase/discussions/2763)).


## 0.10.1

- Exposed the internal `PocketBase.httpClientFactory` constructor option to allow users to provide their own `http.Client` implementation as workaround
  for the realtime events on Flutter Web ([#11](https://github.com/pocketbase/dart-sdk/issues/11)).


## 0.10.0

- Added `fields` optional parameter to the crud services to limit the returned API fields (_available with PocketBase v0.16.0_).

- Added `pb.backups` service for the new PocketBase backup and restore APIs (_available with PocketBase v0.16.0_).

- Added `filesystem` optional parameter to `pb.settings.testS3()` to allow specifying a filesystem for test - `storage` or `backups` (_available with PocketBase v0.16.0_).


## 0.9.1

- Fixed `RealtimeService._connect()` completer not properly resolving.


## 0.9.0

- Added simplified `authWithOAuth2()` version without having to implement custom redirect, deeplink or even page reload:
  ```dart
  await pb.collection('users').authWithOAuth2('google', (url) async {
    await launchUrl(url);
  })
  ```

  Works with PocketBase v0.15.0+.

  This method initializes a one-off realtime subscription and will
  call `urlCallback` with the OAuth2 vendor url to authenticate.
  Once the external OAuth2 sign-in/sign-up flow is completed, the browser
  window will be automatically closed and the OAuth2 data sent back
  to the user through the previously established realtime connection.

  _Site-note_: when creating the OAuth2 app in the provider dashboard
  you have to configure `https://yourdomain.com/api/oauth2-redirect`
  as redirect URL.

  **!** _The "manual" code exchange flow is still supported as `authWithOAuth2Code(provider, code, codeVerifier, redirectUrl)`._

- Adde new `pb.files` service:
  ```js
  // Builds and returns an absolute record file url for the provided filename.
  🔓 pb.files.getUrl(record, filename, queryParams = {});

  // Requests a new private file access token for the current auth model (admin or record).
  🔐 pb.files.getToken(queryParams = {});
  ```
  _`pb.getFileUrl()` is soft deprecated and acts as alias calling `pb.files.getUrl()` under the hood._
  Works with PocketBase v0.15.0+.

- Removed deprecated `SchemaField.unique` field.


## 0.8.0

- Added `CollectionModel.indexes` field for the new collection indexes support in the upcoming PocketBase v0.14.0.

- Added `pb.settings.generateAppleClientSecret()` for sending a request to generate Apple OAuth2 client secret in the upcoming PocketBase v0.14.0.


## 0.7.3

- Improved the realtime autoretry handling (added `infinity` and stepped retries timeout duration).


## 0.7.2

- Added support for handling non-json response when calling `pb.send()`.


## 0.7.1+1

- Removed version install constraint from the README.


## 0.7.1

- Added check for the collection name before auto updating the `pb.authStore` state on auth record update/delete.


## 0.7.0

- Allowed sending the existing valid auth token with the `authWithPassword()` calls.

- Minor docs improvements.


## 0.6.0

- Added `pb.health.check()` that checks the health status of the PocketBase server (_available in PocketBase v0.10.0_)


## 0.5.0+1

- Updated the realtime examples in the README.


## 0.5.0

> ⚠️ Please note that this release works only with the new PocketBase v0.8+ API!
>
> See the breaking changes below for more information on what has changed.

#### Non breaking changes:

- Added new crud method `getFirstListItem(filter)` to fetch a single item by a list filter.

- Added optional named `expand` argument to all crud functions that returns a `RecordModel` (with v0.8 we now also support [indirect expansion](https://github.com/pocketbase/pocketbase/issues/312#issuecomment-1242893496)).

- You can now pass additional account `createData` when authenticating with OAuth2.

- Added `AuthMethodsList.usernamePassword` return field (we now support combined username/email authentication; see below `authWithPassword`).

#### Breaking changes:

- For easier and more conventional parsing, all DateTime strings now have `Z` as suffix, eg. `2022-01-01 01:02:03.456Z`.

- Moved `pb.records.getFileUrl()` to `pb.getFileUrl()`.

- Moved all `pb.records.*` handlers under `pb.collection().*`:
  ```
  pb.records.getFullList('example');              => pb.collection('example').getFullList();
  pb.records.getList('example');                  => pb.collection('example').getList();
  pb.records.getOne('example', 'RECORD_ID');      => pb.collection('example').getOne('RECORD_ID');
  (no old equivalent)                             => pb.collection('example').getFirstListItem(filter);
  pb.records.create('example', ...);              => pb.collection('example').create(...);
  pb.records.update('example', 'RECORD_ID', ...); => pb.collection('example').update('RECORD_ID', ...);
  pb.records.delete('example', 'RECORD_ID');      => pb.collection('example').delete('RECORD_ID');
  ```

- The `pb.realtime` service has now a more general callback form so that it can be used with custom realtime handlers.
  Dedicated records specific subscribtions could be found under `pb.collection().*`:
  ```
  pb.realtime.subscribe('example', callback)           => pb.collection('example').subscribe('*', callback);
  pb.realtime.subscribe('example/RECORD_ID', callback) => pb.collection('example').subscribe('RECORD_ID', callback);
  pb.realtime.unsubscribe('example')                   => pb.collection('example').unsubscribe('*');
  pb.realtime.unsubscribe('example/RECORD_ID')         => pb.collection('example').unsubscribe('RECORD_ID');
  (no old equivalent)                                  => pb.collection('example').unsubscribe();
  ```
  Additionally, `subscribe()` now return `UnsubscribeFunc` that could be used to unsubscribe only from a single subscription listener.

- Moved all `pb.users.*` handlers under `pb.collection().*`:
  ```
  pb.users.listAuthMethods();                                                         => pb.collection('users').listAuthMethods();
  pb.users.authViaEmail(email, password);                                             => pb.collection('users').authWithPassword(usernameOrEmail, password);
  pb.users.authViaOAuth2(provider, code, codeVerifier, redirectUrl, createData: ...); => pb.collection('users').authWithOAuth2(provider, code, codeVerifier, redirectUrl, createData: ...);
  pb.users.refresh();                                                                 => pb.collection('users').authRefresh();
  pb.users.requestPasswordReset(email);                                               => pb.collection('users').requestPasswordReset(email);
  pb.users.confirmPasswordReset(resetToken, newPassword, newPasswordConfirm);         => pb.collection('users').confirmPasswordReset(resetToken, newPassword, newPasswordConfirm);
  pb.users.requestVerification(email);                                                => pb.collection('users').requestVerification(email);
  pb.users.confirmVerification(verificationToken);                                    => pb.collection('users').confirmVerification(verificationToken);
  pb.users.requestEmailChange(newEmail);                                              => pb.collection('users').requestEmailChange(newEmail);
  pb.users.confirmEmailChange(emailChangeToken, password);                            => pb.collection('users').confirmEmailChange(emailChangeToken, password);
  pb.users.listExternalAuths(recordId);                                               => pb.collection('users').listExternalAuths(recordId);
  pb.users.unlinkExternalAuth(recordId, provider);                                    => pb.collection('users').unlinkExternalAuth(recordId, provider);
  ```

- Changes in `pb.admins` for consistency with the new auth handlers in `pb.collection().*`:
  ```
  pb.admins.authViaEmail(email, password); => pb.admins.authWithPassword(email, password);
  pb.admins.refresh();                     => pb.admins.authRefresh();
  ```

- To prevent confusion with the auth method responses, the following methods now returns 204 with empty body (previously 200 with token and auth model):
  ```dart
  Future<void> pb.admins.confirmPasswordReset(...)
  Future<void> pb.collection("users").confirmPasswordReset(...)
  Future<void> pb.collection("users").confirmVerification(...)
  Future<void> pb.collection("users").confirmEmailChange(...)
  ```

- Removed `UserModel` because users are now regular records (aka. `RecordModel`).
  This means that if you want to access for example the email of an auth record, you can do something like:
  `record.getStringValue('email')`.
  **The old user fields `lastResetSentAt`, `lastVerificationSentAt` and `profile` are no longer available** (the `profile` fields are available under the `RecordModel.data` property like any other fields).

- Since there is no longer `UserModel`, `pb.authStore.model` can now be of type `RecordModel`, `AdminModel` or `null`.

- **`RecordModel.expand` is now always `Map<String, List<RecordModel>>`** and it is resolved recursively (previously it was plain `Map<String, dynamic>`).
  _Please note that for easier and unified record(s) access, the map value is always `List`, even for single relations. When calling `RecordModel.toJson()` it will output the `expand` in its original format._

- Removed `lastResetSentAt` from `AdminModel`.

- Renamed the getter `CrudService.basePath` to `CrudService.baseCrudPath`.

- Replaced `ExternalAuthModel.userId` with 2 new `recordId` and `collectionId` props.

- Renamed `SubscriptionEvent` to `RecordSubscriptionEvent`.


## 0.4.1

- Stop sending empty JSON map as body (thanks @rodydavis) [[#7](https://github.com/pocketbase/dart-sdk/issues/7)].
- Changed the default  `ClientException.statusCode` from `500` to `0`.


## 0.4.0

- Added `UserService.listExternalAuths()` to list all linked external auth providers for a single user.
- Added `UserService.unlinkExternalAuth()` to delete a single user external auth provider relation.


## 0.3.0

- Renamed `LogRequestModel.ip` to `LogRequestModel.remoteIp`.
- Added `LogRequestModel.userIp` (the "real" user ip when behind a reverse proxy).
- Added `SettingsService.testS3()` to test the S3 storage connection.
- Added `SettingsService.testEmail()` to send a test email.


## 0.2.0

- Added `CollectionService.import()`.
- Added `totalPages` to the `ResultList<M>` dto.


## 0.1.1

- Fixed base64.decode exception when `AuthStore.isValid` is used (related to [dart-lang/sdk #39510](https://github.com/dart-lang/sdk/issues/39510); thanks @irmhonde).


## 0.1.0+4

- This release just removes the `homepage` directive from the `pubspec.yaml`.


## 0.1.0+3

- No changes were made again. This release is just to trigger the pub.dev analyzer tool in order to test [dart-lang/pub-dev #5927](https://github.com/dart-lang/pub-dev/issues/5927) but this time with ICMP enabled for the homepage domain.


## 0.1.0+2

- No changes were made. This release is just to trigger the pub.dev analyzer tool in order to test [dart-lang/pub-dev #5927](https://github.com/dart-lang/pub-dev/issues/5927).


## 0.1.0+1

- Added RecordService to the library exports for dartdoc.


## 0.1.0

- First public release.
