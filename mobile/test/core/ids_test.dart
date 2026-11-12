import 'package:aroel/core/ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an identifier is a uuid', () {
    expect(Ids.isUuid(Ids.uuid7()), isTrue);
  });

  test('identifiers are made by the device, not by the server', () {
    final String first = Ids.uuid7();
    final String second = Ids.uuid7();

    expect(first, isNot(second));
  });

  test('identifiers sort by the moment they were made', () {
    final String first = Ids.uuid7();
    final String second = Ids.uuid7();

    expect(first.compareTo(second), lessThan(0));
  });
}
