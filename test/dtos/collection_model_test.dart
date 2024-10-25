import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CollectionModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "type": "test_type",
        "created": "test_created",
        "updated": "test_updated",
        "name": "test_name",
        "fields": [
          {
            "id": "fields_id",
            "name": "fields_name",
            "type": "fields_type",
            "system": true,
            "required": false,
            "presentable": false,
            "options": {"a": 123},
          },
        ],
        "system": true,
        "listRule": "test_listRule",
        "viewRule": null,
        "createRule": "test_createRule",
        "updateRule": "",
        "deleteRule": "test_deleteRule",
        "indexes": ["a", "b"],
        "viewQuery": "test_viewQuery",
        "authRule": null,
        "manageRule": null,
        "authAlert": {
          "enabled": true,
          "emailTemplate": {"subject": "a", "body": "b"},
        },
        "oauth2": {
          "enabled": true,
          "mappedFields": {"a": "b"},
          "providers": [
            {"name": "a"}
          ]
        },
        "passwordAuth": {
          "enabled": true,
          "identityFields": ["a", "b"],
        },
        "mfa": {
          "duration": 100,
          "enabled": false,
          "rule": "abc",
        },
        "otp": {
          "duration": 100,
          "enabled": true,
          "length": 10,
          "emailTemplate": {"subject": "a", "body": "b"},
        },
        "authToken": {"duration": 100, "secret": "test"},
        "passwordResetToken": {"duration": 100, "secret": "test"},
        "emailChangeToken": {"duration": 100, "secret": "test"},
        "verificationToken": {"duration": 100, "secret": "test"},
        "fileToken": {"duration": 100, "secret": "test"},
        "verificationTemplate": {"subject": "a", "body": "b"},
        "resetPasswordTemplate": {"subject": "a", "body": "b"},
        "confirmEmailChangeTemplate": {"subject": "a", "body": "b"},
      };

      final model = CollectionModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
