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
    - `num`
    - `bool`
    - `DateTime`
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
