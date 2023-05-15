import "dart:convert";

import "package:json_annotation/json_annotation.dart";
import "jsonable.dart";

part "record_model.dart";
part "admin_model.dart";
part "auth_model.g.dart";

/// Describes an authentication model which can be stored in the AuthStore.
/// Can be either a RecordModel, an AdminModel, or null
///
/// This allows to write :
/// ```dart
/// switch(model) {
///   RecordModel record => /** Authentified as user */,
///   AdminModel auth => /** Authentified as admin */,
///   _ => /** Unauthentified */
/// }
/// ```
sealed class AuthModel implements Jsonable {}
