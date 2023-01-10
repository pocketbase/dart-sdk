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
