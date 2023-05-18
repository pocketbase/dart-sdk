PocketBase Dart SDK [![Pub Package](https://img.shields.io/pub/v/pocketbase.svg)](https://pub.dev/packages/pocketbase)
======================================================================

Official Multi-platform Dart SDK for interacting with the [PocketBase Web API](https://pocketbase.io/docs).

- [Installation](#installation)
- [Caveats](#caveats)
- [Services](#services)
- [Limitations](#limitations)
- [Development](#development)


## Installation

Add the library to your `dependencies`:

```sh
dart pub add pocketbase

# or with Flutter:
flutter pub add pocketbase
```

Import it in your Dart code:

```dart
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

...

// authenticate as regular user
final userData = await pb.collection('users').authWithPassword('test@example.com', '123456');

// list and filter "example" collection records
final result = await pb.collection('example').getList(
  page:    1,
  perPage: 20,
  filter:  'status = true && created >= "2022-08-01"',
  sort:    '-created',
  expand:  'someRelField',
);

// subscribe to realtime "example" collection changes
pb.collection('example').subscribe("*", (e) {
  print(e.action); // create, update, delete
  print(e.record); // the changed record
});

// and much more...
```

> More detailed API docs and copy-paste examples could be found in the [API documentation for each service](https://pocketbase.io/docs/api-authentication)
> or in the [Services section](#services) below.


## Caveats

#### File upload

PocketBase Dart SDK handles file upload seamlessly by using `http.MultipartFile` list.

Here is a simple example of uploading a single text file together with some other regular fields:

```dart
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

pb.collection('example').create(
  body: {
    'title': 'Hello world!',
    // ... any other regular field
  },
  files: [
    http.MultipartFile.fromString(
      'document', // the name of the file field
      'example content...',
      filename: 'example_document.txt',
    ),
  ],
).then((record) {
  print(record.id);
  print(record.getStringValue('title'));
});
```

#### Accessing RecordModel dynamic fields

The SDK comes with several helpers to make it easier working with the `RecordService` and `RecordModel` DTO.
You could find more detailed documentation in the [`RecordModel` class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RecordModel-class.html),
but here are some examples:

```dart
final record = await pb.collection('example').getOne('RECORD_ID');

...

final email   = record.getStringValue('email');
final options = record.getListValue<String>('options');
final status  = record.getBoolValue('status');
final total   = record.getIntValue('total');
final price   = record.getDoubleValue('price');
```

Alternatively, you can also create your own typed DTO data classes and use for example the `record.toJson()` to populate your object, eg:

```dart
import "package:pocketbase/pocketbase.dart";
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  Task({this.id = '', this.description = ''});

  // type the collection fields you want to use...
  final String id;
  final String description;

  /// Creates a new Task instance form the provided RecordModel.
  factory Task.fromRecord(RecordModel record) => Task.fromJson(record.toJson());

  /// Connect the generated [_$Task] function to the `fromJson` factory.
  factory Task.fromJson(Map<String, dynamic> json) => _$Task(json);

  /// Connect the generated [_$Task] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$Task(this);
}

...

// fetch your raw record model
final record = await pb.collection('tasks').getOne('TASK_ID');

final task = Task.fromRecord(record);
```

#### Error handling

All services return a standard Future-based response, so the error handling is straightforward:

```dart
pb.collection('example').getList(page: 1, perPage: 50).then((result) {
  // success...
  print('Result: $result');
}).catchError((error) {
  // error...
  print('Error: $error');
});

// OR if you are using the async/await syntax:
try {
  final result = await pb.collection('example').getList(page: 1, perPage: 50);
} catch (error) {
  print('Error: $error');
}
```

All response errors are normalized and wrapped as `ClientException` with the following public members that you could use:

```dart
ClientException {
    url            Uri     // The address of the failed request
    statusCode     int     // The status code of the failed request
    response       Map     // The JSON API error response
    isAbort        bool    // Indicates whether the request was aborted/cancelled
    originalError  dynamic // The original response error
}
```

#### AuthStore

The SDK keeps track of the authenticated token and auth model for you via the `pb.authStore` service.
The default `AuthStore` class has the following public members that you could use:

```dart
AuthStore {
    token:    String                      // Getter for the stored auth token
    model:    RecordModel|AdminModel|null // Getter for the stored auth RecordModel or AdminModel
    isValid   bool                        // Getter to loosely check if the store has an existing and unexpired token
    onChange  Stream                      // Stream that gets triggered on each auth store change

    // methods
    save(token, model)             // update the store with the new auth data
    clear()                        // clears the current auth store state
}
```

To _"logout"_ an authenticated record or admin, you can just call `pb.authStore.clear()`.

To _"listen"_ for changes in the auth store, you can _listen_ to the `onChange` broadcast stream:
```dart
pb.authStore.onChange.listen((e) {
  print(e.token);
  print(e.model);
});
```

If you want to customize the default `AuthStore`, you can extend it and pass a new custom instance as constructor argument to the client:

```dart
class CustomAuthStore extends AuthStore {
  ...
}

final pb = PocketBase('http://127.0.0.1:8090', authStore: CustomAuthStore());
```

_Please note that at the moment the default `AuthStore` is not persistent! Built-in persistent store for Flutter apps may get added in the future, but for now you can check [#13](https://github.com/pocketbase/dart-sdk/issues/13) (or [pocketbase#1887](https://github.com/pocketbase/pocketbase/discussions/1887#discussioncomment-5057297) for examples)._


## Services

#### RecordService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RecordService-class.html), [API docs](https://pocketbase.io/docs/api-records))

###### _Crud handlers_

```dart
// Returns a paginated records list.
🔓 pb.collection(collectionIdOrName).getList({page = 1, perPage = 30, filter?, sort?, expand?, fields?, query, headers});

// Returns a list with all records batch fetched at once.
🔓 pb.collection(collectionIdOrName).getFullList({batch = 100, filter?, sort?, expand?, fields?, query, headers});

// Returns the first found record matching the specified filter.
🔓 pb.collection(collectionIdOrName).getFirstListItem(filter, {expand?, fields?, query, headers});

// Returns a single record by its id.
🔓 pb.collection(collectionIdOrName).getOne(recordId, {expand?, fields?, query, headers});

// Creates (aka. register) a new record.
🔓 pb.collection(collectionIdOrName).create({body, files, expand?, fields?, query, headers});

// Updates an existing record by its id.
🔓 pb.collection(collectionIdOrName).update(recordId, {body, files, expand?, fields?, query, headers});

// Deletes a single record by its id.
🔓 pb.collection(collectionIdOrName).delete(recordId, {query, body, headers});
```

###### _Realtime handlers_

```dart
// Subscribe to realtime changes to the specified topic ("*" or recordId).
//
// It is safe to subscribe multiple times to the same topic.
//
// You can use the returned UnsubscribeFunc to remove a single registered subscription.
// If you want to remove all subscriptions related to the topic use unsubscribe(topic).
🔓 pb.collection(collectionIdOrName).subscribe(topic, callback);

// Unsubscribe from all registered subscriptions to the specified topic ("*" or recordId).
// If topic is not set, then it will remove all registered collection subscriptions.
🔓 pb.collection(collectionIdOrName).unsubscribe([topic]);
```

###### _Auth handlers_

> Available only for "auth" type collections.

```dart
// Returns all available application auth methods.
🔓 pb.collection(collectionIdOrName).listAuthMethods({query, headers});

// Authenticates a record with their username/email and password.
🔓 pb.collection(collectionIdOrName).authWithPassword(usernameOrEmail, password, {expand?, fields?, query, body, headers});

// Authenticates a record with OAuth2 provider without custom redirects, deeplinks or even page reload.
🔓 pb.collection(collectionIdOrName).authWithOAuth2(provider, urlCallback {scopes, createData, expand?});

// Authenticates a record with OAuth2 code.
🔓 pb.collection(collectionIdOrName).authWithOAuth2Code(provider, code, codeVerifier, redirectUrl, {createData?, expand?, fields?, query, body, headers});

// Refreshes the current authenticated record model and auth token.
🔐 pb.collection(collectionIdOrName).authRefresh({expand?, fields?, query, body, headers});

// Sends a user password reset email.
🔓 pb.collection(collectionIdOrName).requestPasswordReset(email, {query, body, headers});

// Confirms a record password reset request.
🔓 pb.collection(collectionIdOrName).confirmPasswordReset(resetToken, newPassword, newPasswordConfirm, {expand?, fields?, query, body, headers});

// Sends a record verification email request.
🔓 pb.collection(collectionIdOrName).requestVerification(email, {query, body, headers});

// Confirms a record email verification request.
🔓 pb.collection(collectionIdOrName).confirmVerification(verificationToken, {expand?, fields?, query, body, headers});

// Sends a record email change request to the provider email.
🔐 pb.collection(collectionIdOrName).requestEmailChange(newEmail, {query, body, headers});

// Confirms record new email address.
🔓 pb.collection(collectionIdOrName).confirmEmailChange(emailChangeToken, userPassword, {expand?, fields?, query, body, headers});

// Lists all linked external auth providers for the specified record.
🔐 pb.collection(collectionIdOrName).listExternalAuths(recordId, {query, headers});

// Unlinks a single external auth provider relation from the specified record.
🔐 pb.collection(collectionIdOrName).unlinkExternalAuth(recordId, provider, {query, body headers});
```

---

##### FileService

```js
// Builds and returns an absolute record file url for the provided filename.
🔓 pb.files.getUrl(record, filename, {thumb?, token?, query, body, headers});

// Requests a new private file access token for the current auth model (admin or record).
🔐 pb.files.getToken({query, body, headers});
```

---

#### AdminService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/AdminService-class.html), [API docs](https://pocketbase.io/docs/api-admins))

```dart
// Authenticates an admin account by its email and password.
🔓 pb.admins.authWithPassword(email, password, {query, body, headers});

// Refreshes the current admin authenticated model and token.
🔐 pb.admins.authRefresh({query, body, headers});

// Sends an admin password reset email.
🔓 pb.admins.requestPasswordReset(email, {query, body, headers});

// Confirms an admin password reset request.
🔓 pb.admins.confirmPasswordReset(resetToken, newPassword, newPasswordConfirm, {query, body, headers});

// Returns a paginated admins list.
🔐 pb.admins.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a list with all admins batch fetched at once.
🔐 pb.admins.getFullList({batch = 100, filter?, sort?, query, headers});

// Returns the first found admin matching the specified filter.
🔐 pb.admins.getFirstListItem(filter, {query, headers});

// Returns a single admin by their id.
🔐 pb.admins.getOne(id, {query, headers});

// Creates a new admin.
🔐 pb.admins.create({body, files, query, headers});

// Updates an existing admin by their id.
🔐 pb.admins.update(id, {body, files, query, headers});

// Deletes a single admin by their id.
🔐 pb.admins.delete(id, {query, body, headers});
```

---

#### CollectionService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/CollectionService-class.html), [API docs](https://pocketbase.io/docs/api-collections))

```dart
// Returns a paginated collections list.
🔐 pb.collections.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a list with all collections batch fetched at once.
🔐 pb.collections.getFullList({batch = 100, filter?, sort?, query, headers});

// Returns the first found collection matching the specified filter.
🔐 pb.collections.getFirstListItem(filter, {query, headers});

// Returns a single collection by its id.
🔐 pb.collections.getOne(id, {query, headers});

// Creates (aka. register) a new collection.
🔐 pb.collections.create({body, files, query, headers});

// Updates an existing collection by its id.
🔐 pb.collections.update(id, {body, files, query, headers});

// Deletes a single collection by its id.
🔐 pb.collections.delete(id, {query, body, headers});

// Imports the provided collections.
🔐 pb.collections.import(collections, {deleteMissing=false, query, body, headers});
```

---

#### LogService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/LogService-class.html), [API docs](https://pocketbase.io/docs/api-logs))

```dart
// Returns a paginated log requests list.
🔐 pb.logs.getRequestsList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single log request by its id.
🔐 pb.logs.getRequest(id, {query, headers});
```

---

#### SettingsService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/SettingsService-class.html), [API docs](https://pocketbase.io/docs/api-settings))

```dart
// Returns a map with all available app settings.
🔐 pb.settings.getAll({query, headers});

// Bulk updates app settings.
🔐 pb.settings.update({body, query, headers});

// Performs a S3 storage connection test.
🔐 pb.settings.testS3({body, query, headers});

// Sends a test email (verification, password-reset, email-change).
🔐 pb.settings.testEmail(toEmail, template, {body, query, headers});

// Generates a new Apple OAuth2 client secret.
🔐 pb.settings.generateAppleClientSecret(clientId, teamId, keyId, privateKey, duration, {body, query, headers});
```

---

#### RealtimeService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RealtimeService-class.html), [API docs](https://pocketbase.io/docs/api-realtime))

> This service is usually used with custom realtime actions.
> For records realtime subscriptions you can use the subscribe/unsubscribe
> methods available in the `pb.collection()` RecordService.

```dart
// Initialize the realtime connection (if not already) and register the subscription.
//
// You can subscribe to the `PB_CONNECT` event if you want to listen to the realtime connection connect/reconnect events.
🔓 pb.realtime.subscribe(subscription, callback);

// Unsubscribe from a subscription (if empty - unsubscibe from all registered subscriptions).
🔓 pb.realtime.unsubscribe([subscription = '']);

// Unsubscribe from all subscriptions starting with the provided prefix.
🔓 pb.realtime.unsubscribeByPrefix(subscriptionsPrefix);
```

---

##### BackupService

```js
// Returns list with all available backup files.
🔐 pb.backups.getFullList({query, headers});

// Initializes a new backup.
🔐 pb.backups.create(name, {body, query, headers});

// Deletes a single backup by its name.
🔐 pb.backups.delete(name, {body, query, headers});

// Initializes an app data restore from an existing backup.
🔐 pb.backups.restore(name, {body, query, headers});

// Builds a download url for a single existing backup using an
// admin file token and the backup name.
🔐 pb.backups.getDownloadUrl(token, name, {query});
```

---

##### HealthService

```dart
// Checks the health status of the api.
🔓 pb.health.check({query, headers});
```


## Limitations

PocketBase Dart SDK is built on top of the standard `dart-lang/http` package and inherits some of its limitations:

- Requests cancellation/abort is not supported yet - [dart-lang/http #424](https://github.com/dart-lang/http/issues/424)
- Streamed responses (used by the realtime service) are not supported on the web - [dart-lang/http #595](https://github.com/dart-lang/http/issues/595)

Depending on the users demand, we can implement workarounds for the above limitations,
but it would be better to wait the upstream library to apply the necessary fixes.


## Development

```sh
# run the unit tests
dart test

# view dartdoc locally
dart doc

# run the example
dart run example/example.dart

# generate the DTOs json serializable artifacts
dart run build_runner build
```
