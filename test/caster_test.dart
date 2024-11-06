import "package:pocketbase/src/caster.dart" as caster;
import "package:test/test.dart";

void main() {
  group("caster", () {
    test("extract()", () {
      final data = {
        "a": null,
        "b": 1.5,
        "c": "test",
        "d": false,
        "e": ["1", "2", "3"],
        "f": {
          "a": {
            "b": [
              {"b1": 1},
              {"b2": 2},
              {"b3": 3}
            ]
          }
        },
      };

      expect(caster.extract<dynamic>(data, "unknown"), null);
      expect(caster.extract<dynamic>(data, "unknown", "missing!"), "missing!");
      expect(caster.extract<num>(data, "b"), 1.5);
      expect(caster.extract<int>(data, "b"), 1);
      expect(caster.extract<String>(data, "c"), "test");
      expect(caster.extract<List<String>>(data, "e"), ["1", "2", "3"]);
      expect(caster.extract<List<int>>(data, "e"), [1, 2, 3]);
      expect(caster.extract<List<dynamic>>(data, "f.a.b"), [
        {"b1": 1},
        {"b2": 2},
        {"b3": 3}
      ]);
      expect(caster.extract<int>(data, "f.a.b.1.b2"), 2);
      expect(caster.extract<int>(data, "f.a.b.2.b2"), 0);
      expect(caster.extract<int>(data, "f.missing", -1), -1);
    });

    test("toString()", () {
      expect(caster.toString(null), "");
      expect(caster.toString(1), "1");
      expect(caster.toString("test"), "test");
      expect(caster.toString(false), "false");
      expect(caster.toString(["1", 2, 3]), "[1, 2, 3]");
      expect(caster.toString({"test": 123}), "{test: 123}");
    });

    test("toList()", () {
      expect(caster.toList<bool>(1), <bool>[true]);
      expect(caster.toList<bool>(0), <bool>[false]);
      expect(caster.toList<bool>(null), <bool>[]);
      expect(caster.toList<num>(1), <num>[1]);
      expect(caster.toList<int>(1.5), <int>[1]);
      expect(caster.toList<String>(null), <String>[]);
      expect(caster.toList<dynamic>(null), <dynamic>[]);
      expect(caster.toList<dynamic>(1), [1]);
      expect(caster.toList<dynamic>("test"), ["test"]);
      expect(caster.toList<dynamic>("false"), ["false"]);
      expect(caster.toList<dynamic>(["1", 2, 3]), ["1", 2, 3]);
    });

    test("toBool()", () {
      expect(caster.toBool(null), false);
      expect(caster.toBool(1), true);
      expect(caster.toBool(0), false);
      expect(caster.toBool(-1), true);
      expect(caster.toBool(""), false);
      expect(caster.toBool("false"), false);
      expect(caster.toBool("0"), false);
      expect(caster.toBool("test"), true);
      expect(caster.toBool("false"), false);
      expect(caster.toBool(<dynamic>[]), false);
      expect(caster.toBool(["1", 2, 3]), true);
      expect(caster.toBool(<String, dynamic>{}), false);
      expect(caster.toBool({"test": 123}), true);
    });

    test("toInt()", () {
      expect(caster.toInt(null), 0);
      expect(caster.toInt(1), 1);
      expect(caster.toInt(2.4), 2);
      expect(caster.toInt(""), 0);
      expect(caster.toInt("false"), 0);
      expect(caster.toInt("123"), 123);
      expect(caster.toInt("test"), 0);
      expect(caster.toInt(false), 0);
      expect(caster.toInt(true), 1);
      expect(caster.toInt(<dynamic>[]), 0);
      expect(caster.toInt(["1", 2, 3]), 3);
      expect(caster.toInt(<String, dynamic>{}), 0);
      expect(caster.toInt({"a": 123, "b": 456}), 2);
    });

    test("getDoubleValue()", () {
      expect(caster.toDouble(null), 0);
      expect(caster.toDouble(1), 1);
      expect(caster.toDouble(2.4), 2.4);
      expect(caster.toDouble(""), 0);
      expect(caster.toDouble("false"), 0);
      expect(caster.toDouble("123.4"), 123.4);
      expect(caster.toDouble("test"), 0);
      expect(caster.toDouble(false), 0);
      expect(caster.toDouble(true), 1);
      expect(caster.toDouble(<dynamic>[]), 0);
      expect(caster.toDouble(["1", 2, 3]), 3);
      expect(caster.toDouble(<String, dynamic>{}), 0);
      expect(caster.toDouble({"a": 123, "b": 456}), 2);
    });
  });
}
