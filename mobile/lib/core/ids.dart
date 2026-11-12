import 'dart:math';
import 'dart:typed_data';

/// Identifiers the client makes for itself.
///
/// Every row the client writes is keyed by a `uuid7` the device generates, so a row that
/// is created offline never has to be renumbered when it reaches the server (§4.2).
abstract final class Ids {
  static final Uuid7Generator _generator = Uuid7Generator();

  /// A new time-ordered identifier, as a string.
  ///
  /// `uuid7` sorts by creation time, which keeps SQLite indexes and sync cursors in the
  /// order things actually happened.
  static String uuid7() => _generator.next();

  /// Whether [value] is a well-formed identifier.
  static bool isUuid(String value) =>
      value.length == 36 &&
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      ).hasMatch(value);
}

/// Makes `uuid7` identifiers that keep their order.
///
/// The shape is the one of RFC 9562: forty-eight bits of milliseconds, four bits of
/// version, two bits of variant and the rest random. What this adds is a counter: two
/// identifiers made in the same millisecond still sort, because the last fifty-six bits
/// count up instead of being drawn again. A journal is written in bursts, and a burst
/// must not shuffle itself.
class Uuid7Generator {
  /// Creates a generator. The random source is injectable so that a test can be sure of
  /// what it gets.
  Uuid7Generator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  int _lastMillisecond = -1;
  List<int> _header = <int>[0, 0, 0];
  List<int> _tail = <int>[0, 0, 0, 0, 0, 0, 0];

  /// The next identifier.
  String next() {
    final int millisecond = DateTime.now().millisecondsSinceEpoch;

    if (millisecond != _lastMillisecond) {
      _lastMillisecond = millisecond;
      _header = <int>[
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      ];
      _tail = List<int>.generate(7, (_) => _random.nextInt(256));
    } else {
      _tail = _countUp(_tail);
    }

    final Uint8List bytes = Uint8List(16);

    bytes[0] = (millisecond >> 40) & 0xFF;
    bytes[1] = (millisecond >> 32) & 0xFF;
    bytes[2] = (millisecond >> 24) & 0xFF;
    bytes[3] = (millisecond >> 16) & 0xFF;
    bytes[4] = (millisecond >> 8) & 0xFF;
    bytes[5] = millisecond & 0xFF;

    bytes[6] = 0x70 | (_header[0] & 0x0F);
    bytes[7] = _header[1];
    bytes[8] = 0x80 | (_header[2] & 0x3F);

    for (int index = 0; index < 7; index++) {
      bytes[9 + index] = _tail[index];
    }

    return _unparse(bytes);
  }

  /// Counts the tail up by one, carrying to the left.
  static List<int> _countUp(List<int> bytes) {
    final List<int> result = List<int>.of(bytes);
    for (int index = result.length - 1; index >= 0; index--) {
      if (result[index] == 0xFF) {
        result[index] = 0;
        continue;
      }
      result[index] = result[index] + 1;
      break;
    }
    return result;
  }

  /// Writes the sixteen bytes as the usual eight-four-four-four-twelve shape.
  static String _unparse(Uint8List bytes) {
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < 16; index++) {
      if (index == 4 || index == 6 || index == 8 || index == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[index].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
