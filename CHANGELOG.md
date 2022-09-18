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
