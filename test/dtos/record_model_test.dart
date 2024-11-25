// ignore_for_file: deprecated_member_use_from_same_package

import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("RecordModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "collectionId": "test_collectionId",
        "collectionName": "test_collectionName",
        "expand": {
          "one": RecordModel({"id": "1"}).toJson(),
          "many": [
            RecordModel({"id": "2"}).toJson(),
            RecordModel.fromJson({
              "id": "3",
              "expand": {
                "recursive": RecordModel({"id": "4"}).toJson(),
              },
            }).toJson(),
          ],
        },
        "a": 1,
        "b": "test",
        "c": true,
      };

      final model = RecordModel.fromJson(json);

      expect(model.data, json);
      expect(model.id, "test_id");
      expect(model.created, "test_created");
      expect(model.updated, "test_updated");
      expect(model.collectionId, "test_collectionId");
      expect(model.collectionName, "test_collectionName");
      expect(model.expand["one"]?.length, 1);
      expect(model.expand["one"]?[0].id, "1");
      expect(model.expand["many"]?.length, 2);
      expect(model.expand["many"]?[0].id, "2");
      expect(model.expand["many"]?[1].id, "3");
      expect(model.expand["many"]?[1].expand["recursive"]?.length, 1);
      expect(model.expand["many"]?[1].expand["recursive"]?[0].id, "4");

      // to json
      expect(model.toJson(), json);
    });

    test("set()", () {
      final model = RecordModel({
        "a": 123,
      })
        ..set("a", 456)
        ..set("b", 789);

      expect(model.data["a"], 456);
      expect(model.data["b"], 789);
    });

    test("get()", () {
      final model = RecordModel({
        "a": null,
        "b": 1.5,
        "c": "test",
        "d": false,
        "e": ["1", "2", "3"],
        "f": {"test": 123},
        "g": [
          {"test": 123}
        ],
      });

      expect(model.get<dynamic>("unknown"), null);
      expect(model.get("unknown", "missing!"), "missing!");
      expect(model.get<num>("b"), 1.5);
      expect(model.get<double>("b"), 1.5);
      expect(model.get<int>("b"), 1);
      expect(model.get<String>("c"), "test");
      expect(model.get<List<String>>("e"), ["1", "2", "3"]);
      expect(model.get<Map<String, dynamic>>("f"), {"test": 123});
      expect(model.get<int>("f.test"), 123);
      expect(model.get<int>("f.test_2", -1), -1);
      expect(model.get<RecordModel>("f").toJson(), {"test": 123});
      // lists
      expect(model.get<List<RecordModel>>("missing"), <RecordModel>[]);
      expect(model.get<List<int>>("b"), <int>[1]);
      expect(model.get<List<int>>("d"), <int>[0]);
      expect(model.get<List<int>>("missing"), <int>[]);
      expect(model.get<List<int>>("e"), <int>[1, 2, 3]);
      expect(
          model.get<List<RecordModel>>("g").map((r) => r.toJson()).toList(), [
        {"test": 123}
      ]);
      expect(
          model.get<List<RecordModel?>>("g").map((r) => r?.toJson()).toList(), [
        {"test": 123}
      ]);
      expect(
          model.get<List<RecordModel>>("f").map((r) => r.toJson()).toList(), [
        {"test": 123}
      ]);
      expect(model.get<List<int>>("d"), [0]);
      // existing field as nullable type
      expect(model.get<num?>("b"), 1.5);
      expect(model.get<String?>("c"), "test");
      expect(model.get<bool?>("d"), false);
      expect(model.get<List<String>?>("e"), ["1", "2", "3"]);
      expect(model.get<Map<String, dynamic>?>("f"), {"test": 123});
      expect(model.get<int?>("f.test"), 123);
      expect(model.get<RecordModel?>("f")?.toJson(), {"test": 123});
      // non-existing field as nullable type
      expect(model.get<num?>("b_2"), null);
      expect(model.get<String?>("c_2"), null);
      expect(model.get<bool?>("d_2"), null);
      expect(model.get<List<String>?>("e_2"), null);
      expect(model.get<Map<String, dynamic>?>("f_2"), null);
      expect(model.get<int?>("f.test_2"), null);
      expect(model.get<RecordModel?>("f_2"), null);
    });

    test("getStringValue()", () {
      final model = RecordModel({
        "a": null,
        "b": 1,
        "c": "test",
        "d": false,
        "e": ["1", 2, 3],
        "f": {"test": 123},
      });
      expect(model.getStringValue("a"), "");
      expect(model.getStringValue("b"), "1");
      expect(model.getStringValue("c"), "test");
      expect(model.getStringValue("d"), "false");
      expect(model.getStringValue("e"), "[1, 2, 3]");
      expect(model.getStringValue("f"), "{test: 123}");
    });

    test("getListValue()", () {
      final model = RecordModel({
        "a": null,
        "b": 1,
        "c": "test",
        "d": false,
        "e": ["1", 2, 3],
      });
      expect(model.getListValue<String>("a"), <String>[]); // invalid type
      expect(model.getListValue<dynamic>("a"), <dynamic>[]);
      expect(model.getListValue<bool>("b"), <bool>[true]);
      expect(model.getListValue<num>("b"), <num>[1]);
      expect(model.getListValue<dynamic>("b"), [1]);
      expect(model.getListValue<dynamic>("c"), ["test"]);
      expect(model.getListValue<dynamic>("d"), [false]);
      expect(model.getListValue<dynamic>("e"), ["1", 2, 3]);
    });

    test("getBoolValue()", () {
      final model = RecordModel({
        "a": null,
        "b1": 1,
        "b2": 0,
        "b3": -1,
        "c1": "",
        "c2": "false",
        "c3": "0",
        "c4": "test",
        "d": false,
        "e1": <dynamic>[],
        "e2": ["1", 2, 3],
        "f1": <String, dynamic>{},
        "f2": {"test": 123},
      });
      expect(model.getBoolValue("a"), false);
      expect(model.getBoolValue("b1"), true);
      expect(model.getBoolValue("b2"), false);
      expect(model.getBoolValue("b3"), true);
      expect(model.getBoolValue("c1"), false);
      expect(model.getBoolValue("c2"), false);
      expect(model.getBoolValue("c3"), false);
      expect(model.getBoolValue("c4"), true);
      expect(model.getBoolValue("d"), false);
      expect(model.getBoolValue("e1"), false);
      expect(model.getBoolValue("e2"), true);
      expect(model.getBoolValue("f1"), false);
      expect(model.getBoolValue("f2"), true);
    });

    test("getIntValue()", () {
      final model = RecordModel({
        "a": null,
        "b1": 1,
        "b2": 2.4,
        "c1": "",
        "c2": "false",
        "c3": "123",
        "c4": "test",
        "d1": false,
        "d2": true,
        "e1": <dynamic>[],
        "e2": ["1", 2, 3],
        "f1": <String, dynamic>{},
        "f2": {"a": 123, "b": 456},
      });
      expect(model.getIntValue("a"), 0);
      expect(model.getIntValue("b1"), 1);
      expect(model.getIntValue("b2"), 2);
      expect(model.getIntValue("c1"), 0);
      expect(model.getIntValue("c2"), 0);
      expect(model.getIntValue("c3"), 123);
      expect(model.getIntValue("c4"), 0);
      expect(model.getIntValue("d1"), 0);
      expect(model.getIntValue("d2"), 1);
      expect(model.getIntValue("e1"), 0);
      expect(model.getIntValue("e2"), 3);
      expect(model.getIntValue("f1"), 0);
      expect(model.getIntValue("f2"), 2);
    });

    test("getDoubleValue()", () {
      final model = RecordModel({
        "a": null,
        "b1": 1,
        "b2": 2.4,
        "c1": "",
        "c2": "false",
        "c3": "123.4",
        "c4": "test",
        "d1": false,
        "d2": true,
        "e1": <dynamic>[],
        "e2": ["1", 2, 3],
        "f1": <String, dynamic>{},
        "f2": {"a": 123, "b": 456},
      });
      expect(model.getDoubleValue("a"), 0);
      expect(model.getDoubleValue("b1"), 1);
      expect(model.getDoubleValue("b2"), 2.4);
      expect(model.getDoubleValue("c1"), 0);
      expect(model.getDoubleValue("c2"), 0);
      expect(model.getDoubleValue("c3"), 123.4);
      expect(model.getDoubleValue("c4"), 0);
      expect(model.getDoubleValue("d1"), 0);
      expect(model.getDoubleValue("d2"), 1);
      expect(model.getDoubleValue("e1"), 0);
      expect(model.getDoubleValue("e2"), 3);
      expect(model.getDoubleValue("f1"), 0);
      expect(model.getDoubleValue("f2"), 2);
    });
  });
}
