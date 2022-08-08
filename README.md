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

final client = PocketBase('http://127.0.0.1:8090');

...

// authenticate as regular user
final userData = await client.users.authViaEmail("test@example.com", "123456");

// list and filter "example" collection records
final result = await client.records.getList(
  "example",
  page: 1,
  perPage: 20,
  filter: "status = true && created >= '2022-08-01'",
  sort: "-created",
);

// subscribe to realtime "example" collection changes
client.realtime.subscribe("example", (e) {
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

final client = PocketBase("http://127.0.0.1:8090");

client.records.create(
  'example',
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
final record = await client.records.getOne("example", "RECORD_ID");

...

final title   = record.getStringValue("title");
final options = record.getListValue<String>("options");
final status  = record.getBoolValue("status");
final total   = record.getIntValue("total");
final price   = record.getDoubleValue("price");
```

#### Errors handling

All services return a standard Future-based response, so the error handling is straightforward:

```dart
client.records.getList("example", page: 1, perPage: 50).then((result) {
  // success...
  print("Result: $result");
}).catchError((error) {
  // error...
  print("Error: $error");
});

// OR if you are using the async/await syntax:
try {
  final result = await client.records.getList("example", page: 1, perPage: 50);
} catch (error) {
  print("Error: $error");
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

The SDK keeps track of the authenticated token and auth model for you via the `client.authStore` service.
The default `AuthStore` class has the following public members that you could use:

```dart
AuthStore {
    token:    String               // Getter for the stored auth token
    model:    UserModel|AdminModel // Getter for the stored auth User or Admin model
    isValid   bool                 // Getter to loosely check if the store has an existing and unexpired token
    onChange  Stream               // Stream that gets triggered on each auth store change

    // methods
    save(token, model)             // update the store with the new auth data
    clear()                        // clears the current auth store state
}
```

To _"logout"_ an authenticated user or admin, you can just call `client.authStore.clear()`.

To _"listen"_ for changes in the auth store, you can _listen_ to the `onChange` broadcast stream:
```dart
client.authStore.onChange.listen((e) {
  print(e.token);
  print(e.model);
});
```

If you want to customize the default `AuthStore`, you can extend it and pass a new custom instance as constructor argument to the client:

```dart
class CustomAuthStore extends AuthStore {
  ...
}

final client = PocketBase("http://127.0.0.1:8090", authStore: CustomAuthStore());
```


## Services

#### AdminService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/AdminService-class.html), [API docs](https://pocketbase.io/docs/api-admins))

```dart
// Authenticates an admin account by its email and password.
🔓 client.admins.authViaEmail(email, password, {query, body, headers});

// Refreshes the current admin authenticated model and token.
🔐 client.admins.refresh({query, body, headers});

// Sends an admin password reset email.
🔓 client.admins.requestPasswordReset(email, {query, body, headers});

// Confirms an admin password reset request.
🔓 client.admins.confirmPasswordReset(resetToken, newPassword, newPasswordConfirm, {query, body, headers});

// Returns a list with all admins batch fetched at once.
🔐 client.admins.getFullList({batch = 100, filter?, sort?, query, headers});

// Returns a paginated admins list.
🔐 client.admins.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single admin by their id.
🔐 client.admins.getOne(id, {query, headers});

// Creates a new admin.
🔐 client.admins.create({body, files, query, headers});

// Updates an existing admin by their id.
🔐 client.admins.update(id, {body, files, query, headers});

// Deletes a single admin by their id.
🔐 client.admins.delete(id, {query, body, headers});
```

---

#### UserService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/UserService-class.html), [API docs](https://pocketbase.io/docs/api-users))

```dart
🔓 client.users.listAuthMethods({query, headers});

// Authenticates a user by their email and password.
🔓 client.users.authViaEmail(email, password, {query, body, headers});

// Authenticates a user by OAuth2 client provider.
🔓 client.users.authViaOAuth2(provider, code, codeVerifier, redirectUrl, {query, body, headers});

// Refreshes the current user authenticated model and token.
🔐 client.users.refresh({query, body, headers});

// Sends a user password reset email.
🔓 client.users.requestPasswordReset(email, {query, body, headers});

// Confirms a user password reset request.
🔓 client.users.confirmPasswordReset(resetToken, newPassword, newPasswordConfirm, {query, body, headers});

// Sends a user verification email request.
🔓 client.users.requestVerification(email, {query, body, headers});

// Confirms a user email verification request.
🔓 client.users.confirmVerification(verificationToken, {query, body, headers});

// Sends a user email change request to the provider email.
🔐 client.users.requestEmailChange(newEmail, {query, body, headers});

// Confirms user new email address.
🔓 client.users.confirmEmailChange(emailChangeToken, userPassword, {query, body, headers});

// Returns a list with all users batch fetched at once.
🔐 client.users.getFullList({batch = 100, filter?, sort?, query, headers});

// Returns a paginated users list.
🔐 client.users.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single user by their id.
🔐 client.users.getOne(id, {query, headers});

// Creates (aka. register) a new user.
🔓 client.users.create({body, files, query, headers});

// Updates an existing user by their id.
🔐 client.users.update(id, {body, files, query, headers});

// Deletes a single user by their id.
🔐 client.users.delete(id, {query, body, headers});
```

---

#### RealtimeService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RealtimeService-class.html), [API docs](https://pocketbase.io/docs/api-realtime))

```dart
// Initialize the realtime connection (if not already) and register the subscription.
🔓 client.realtime.subscribe(subscription, callback);

// Unsubscribe from a subscription (if empty - unsubscibe from all registered subscriptions).
🔓 client.realtime.unsubscribe([subscription = '']);
```

---

#### CollectionService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/CollectionService-class.html), [API docs](https://pocketbase.io/docs/api-collections))

```dart
// Returns a list with all collections batch fetched at once.
🔐 client.collections.getFullList({batch = 100, filter?, sort?, query, headers});

// Returns a paginated collections list.
🔐 client.collections.getList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single collection by its id.
🔐 client.collections.getOne(id, {query, headers});

// Creates (aka. register) a new collection.
🔐 client.collections.create({body, files, query, headers});

// Updates an existing collection by its id.
🔐 client.collections.update(id, {body, files, query, headers});

// Deletes a single collection by its id.
🔐 client.collections.delete(id, {query, body, headers});

// Imports the provided collections.
🔐 client.collections.import(collections, {deleteMissing=true, query, body, headers});
```

---

#### RecordService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/RecordService-class.html), [API docs](https://pocketbase.io/docs/api-records))

```dart
// Returns a list with all records batch fetched at once.
🔓 client.records.getFullList(collectionIdOrName, {batch = 100, filter?, sort?, query, headers});

// Returns a paginated records list.
🔓 client.records.getList(collectionIdOrName, {page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single record by its id.
🔓 client.records.getOne(collectionIdOrName, recordId, {query, headers});

// Creates (aka. register) a new record.
🔓 client.records.create(collectionIdOrName, {body, files, query, headers});

// Updates an existing record by its id.
🔓 client.records.update(collectionIdOrName, recordId, {body, files, query, headers});

// Deletes a single record by its id.
🔓 client.records.delete(collectionIdOrName, recordId, {query, body, headers});
```

---

#### LogService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/LogService-class.html), [API docs](https://pocketbase.io/docs/api-logs))

```dart
// Returns a paginated log requests list.
🔐 client.logs.getRequestsList({page = 1, perPage = 30, filter?, sort?, query, headers});

// Returns a single log request by its id.
🔐 client.logs.getRequest(id, {query, headers});
```

---

#### SettingsService ([Detailed class reference](https://pub.dev/documentation/pocketbase/latest/pocketbase/SettingsService-class.html), [API docs](https://pocketbase.io/docs/api-settings))

```dart
// Returns a map with all available app settings.
🔐 client.settings.getAll({query, headers});

// Bulk updates app settings.
🔐 client.settings.update({body, query, headers});
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
