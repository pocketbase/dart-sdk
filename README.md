PocketBase Dart SDK [![Pub Package](https://img.shields.io/pub/v/pocketbase.svg)](https://pub.dev/packages/pocketbase)
======================================================================

Official Multi-platform Dart SDK for interacting with the [PocketBase Web API](https://pocketbase.io/docs).

- [Installation](#installation)
- [Caveats](#caveats)
    - [File upload](#file-upload)
    - [RecordModel](#recordmodel)
    - [Error handling](#error-handling)
    - [AuthStore](#authstore)
    - [Binding filter parameters](#binding-filter-parameters)
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
}, filter: "someField > 10");

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
  print(record.get<String>('title'));
});
```

#### RecordModel

The SDK comes with several helpers to make it easier working with the `RecordService` and `RecordModel` DTO.
You could find more detailed documentation in the [`RecordModel` class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RecordModel-class.html),
but below is an example how to access and cast record data values:

```dart
final record = await pb.collection('example').getOne('RECORD_ID');

final options  = record.get<List<String>>('options');
final email    = record.get<String>('email');
final status   = record.get<bool>('status');
final total    = record.get<int>('total');
final price    = record.get<double>('price');
final nested1  = record.get<RecordModel>('expand.user', null);
final nested2  = record.get<String>('expand.user.title', 'N/A');
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

The SDK keeps track of the authenticated token and auth record for you via the `pb.authStore` service.
The default `AuthStore` class has the following public members that you could use:

```dart
AuthStore {
    token:    String           // Getter for the stored auth token
    record:   RecordModel|null // Getter for the stored auth RecordModel or AdminModel
    isValid   bool             // Getter to loosely check if the store has an existing and unexpired token
    onChange  Stream           // Stream that gets triggered on each auth store change

    // methods
    save(token, record)        // update the store with the new auth data
    clear()                    // clears the current auth store state
}
```

To _"logout"_ an authenticated record or admin, you can just call `pb.authStore.clear()`.

To _"listen"_ for changes in the auth store, you can _listen_ to the `onChange` broadcast stream:
```dart
pb.authStore.onChange.listen((e) {
  print(e.token);
  print(e.record);
});
```

**The default `AuthStore` is not persistent!**

If you want to persist the `AuthStore` state (eg. in case the app get closed), you can extend the default store and pass a new custom instance as constructor argument to the client.
To make it slightly easier, the SDK has a builtin `AsyncAuthStore` that you can combine with any async persistent layer (`shared_preferences`, `hive`, local file, etc.).
Here is an example using Flutter's [`shared_preferences`](https://pub.dev/packages/shared_preferences):

```dart
final prefs = await SharedPreferences.getInstance();

final store = AsyncAuthStore(
 save:    (String data) async => prefs.setString('pb_auth', data),
 initial: prefs.getString('pb_auth'),
);

final pb = PocketBase('http://example.com', authStore: store);
```

#### Binding filter parameters

The SDK comes with a helper `pb.filter(expr, params)` method to generate a filter string with placeholder parameters (`{:paramName}`) populated from a `Map`.

```dart
final records = await pb.collection('example').getList(filter: pb.filter(
  // the same as: "title ~ 'exa\\'mple' && created = '2023-10-18 18:20:00.123Z'"
  'title ~ {:title} && created >= {:created}',
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
🔓 pb.collection(collectionIdOrName).subscribe(topic, callback, {filter?, expand?, fields?, query, headers});

// Unsubscribe from all registered subscriptions to the specified topic ("*" or recordId).
// If topic is not set, then it will remove all registered collection subscriptions.
🔓 pb.collection(collectionIdOrName).unsubscribe([topic]);
```

###### _Auth handlers_

> Available only for "auth" type collections.

```dart
// Returns all available application auth methods.
🔓 pb.collection(collectionIdOrName).listAuthMethods({query, headers});

// Refreshes the current authenticated record model and auth token.
🔐 pb.collection(collectionIdOrName).authRefresh({expand?, fields?, query, body, headers});

// Authenticates a record with their username/email and password.
🔓 pb.collection(collectionIdOrName).authWithPassword(usernameOrEmail, password, {expand?, fields?, query, body, headers});

// Authenticates a record with OAuth2 provider without custom redirects, deeplinks or even page reload.
🔓 pb.collection(collectionIdOrName).authWithOAuth2(provider, urlCallback {scopes, createData, expand?});

// Authenticates a record with OAuth2 code.
🔓 pb.collection(collectionIdOrName).authWithOAuth2Code(provider, code, codeVerifier, redirectURL, {createData?, expand?, fields?, query, body, headers});

// Sends auth record OTP request to the provided email.
🔓 pb.collection(collectionIdOrName).requestOTP(email, {query, body, headers});

// Authenticates a record with OTP (email code).
🔓 pb.collection(collectionIdOrName).authWithOTP(otpId, password, {expand?, fields?, query, body, headers});

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

// Impersonate authenticates with the specified recordId and returns a new client with the received auth token in a memory store.
🔐 pb.collection(collectionIdOrName).impersonate(recordId, duration, {expand?, fields?, query, body, headers});
```

---

##### FileService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/FileService-class.html))

```js
// Builds and returns an absolute record file url for the provided filename.
🔓 pb.files.getURL(record, filename, {thumb?, token?, query, body, headers});

// Requests a new private file access token for the current auth model (admin or record).
🔐 pb.files.getToken({query, body, headers});
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

// Returns a single collection by its id or name.
🔐 pb.collections.getOne(idOrName, {query, headers});

// Creates (aka. register) a new collection.
🔐 pb.collections.create({body, files, query, headers});

// Updates an existing collection by its id or name.
🔐 pb.collections.update(idOrName, {body, files, query, headers});

// Deletes a single collection by its id or name.
🔐 pb.collections.delete(idOrName, {query, body, headers});

// Deletes all records associated with the specified collection.
🔐 pb.collections.truncate(idOrName, {query, body, headers});

// Imports the provided collections.
🔐 pb.collections.import(collections, {deleteMissing=false, query, body, headers});

// Returns type indexed map with scaffolded collection models populated with their default field values.
🔐 pb.collections.getScaffolds({query, body, headers});
```

---

#### LogService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/LogService-class.html), [API docs](https://pocketbase.io/docs/api-logs))

```dart
// Returns a paginated logs list.
🔐 pb.logs.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single log by its id.
🔐 pb.logs.getOne(id, {query, headers});

// Returns logs statistics.
🔐 pb.logs.getStats({query, headers});
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
🔐 pb.settings.testEmail(toEmail, template, {collection, body, query, headers});

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
🔓 pb.realtime.subscribe(subscription, callback, {filter?, expand?, fields?, query, headers});

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
🔐 pb.backups.create(basename, {body, query, headers});

// Uploads an existing backup file (_the multipart file key is "file"_).
🔐 pb.backups.upload(file, {body, query, headers});

// Deletes a single backup by its file key.
🔐 pb.backups.delete(key, {body, query, headers});

// Initializes an app data restore from an existing backup.
🔐 pb.backups.restore(key, {body, query, headers});

// Builds a download url for a single existing backup using an
// admin file token and the backup file key.
🔐 pb.backups.getDownloadURL(token, key, {query});
```

---

##### HealthService

```dart
// Checks the health status of the api.
🔓 pb.health.check({query, headers});
```

---

#### BatchService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/BatchService-class.html), [API docs](https://pocketbase.io/docs/api-bach))

```dart
// create a new batch instance
final batch = pb.createBatch();

// register create/update/delete/upsert requests to the created batch
batch.collection('example1').create(body: { ... });
batch.collection('example2').update('RECORD_ID', body: { ... });
batch.collection('example3').delete('RECORD_ID');
batch.collection('example4').upsert(body: { ... });

// send the batch request
final result = await batch.send()
```


## Limitations

PocketBase Dart SDK is built on top of the standard `dart-lang/http` package and inherits some of its limitations:

- Requests cancellation/abort is not supported yet - [dart-lang/http #424](https://github.com/dart-lang/http/issues/424)
- Streamed responses (used by the realtime service and the "all-in-one" OAuth2 flow) are not supported on the web - [dart-lang/http #595](https://github.com/dart-lang/http/issues/595)

One possible workaround for the latter is to provide a 3rd party `http.Client` implementation specific for the web like [`fetch_client`](https://pub.dev/packages/fetch_client) using the `httpClientFactory` constructor option:

```dart
import 'package:pocketbase/pocketbase.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  final pb = PocketBase(
    'http://127.0.0.1:8090',
    // load the fetch_client only for web, otherwise - fallback to the default http.Client()
    //
    // (note: if you want to be able to compile both for web and mobile you may have to import the FetchClient conditionally)
    httpClientFactory: kIsWeb ? () => FetchClient(mode: RequestMode.cors) : null,
  );

  // ...
}
```


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
