import 'package:aroel/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the email rules', () {
    test('an address is trimmed and lowercased', () {
      expect(
        Validators.normalizeEmail('  Ada@Example.COM '),
        'ada@example.com',
      );
    });

    test('an address needs one separator and a domain with a dot', () {
      expect(Validators.isValidEmail('ada@example.com'), isTrue);
      expect(Validators.isValidEmail('ada@example'), isFalse);
      expect(Validators.isValidEmail('ada@@example.com'), isFalse);
      expect(Validators.isValidEmail('ada example.com'), isFalse);
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail('ada@.example.com'), isFalse);
      expect(Validators.isValidEmail('ada@example.com.'), isFalse);
      expect(Validators.isValidEmail(''), isFalse);
    });

    test(
      'an address is not longer than two hundred and fifty-four characters',
      () {
        final String long = '${'a' * 250}@example.com';
        expect(long.length, greaterThan(254));
        expect(Validators.isValidEmail(long), isFalse);
      },
    );
  });

  group('the password rules', () {
    test('eight characters is enough, and nothing else is required', () {
      expect(Validators.isValidPassword('12345678'), isTrue);
      expect(Validators.isValidPassword('abcdefgh'), isTrue);
      expect(Validators.isValidPassword('a much longer sentence'), isTrue);
    });

    test('seven characters is not enough', () {
      expect(Validators.isValidPassword('1234567'), isFalse);
      expect(Validators.isValidPassword(''), isFalse);
    });

    test('the shortest password is the one the server accepts', () {
      expect(Validators.minimumPasswordLength, 8);
    });
  });
}
