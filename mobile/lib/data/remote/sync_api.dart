import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:dio/dio.dart';

/// One operation pushed to the server (§7.3).
class SyncOperation {
  /// Creates an operation.
  const SyncOperation({
    required this.table,
    required this.op,
    required this.id,
    required this.updatedAt,
    this.data,
  });

  /// The table the operation applies to.
  final String table;

  /// `upsert` or `delete`.
  final String op;

  /// The client-generated identifier of the row.
  final String id;

  /// The moment the change was made on the device.
  final DateTime updatedAt;

  /// The fields of the row, when the operation carries them.
  final Map<String, Object?>? data;

  /// The operation as the server reads it.
  Map<String, Object?> toJson() => <String, Object?>{
    'table': table,
    'op': op,
    'id': id,
    // Seconds survive every JSON round-trip; microseconds are noise.
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    if (data != null) 'data': data,
  };
}

/// One row the server answers with (§7.3).
class SyncRow {
  /// Creates a row view.
  const SyncRow({
    required this.table,
    required this.op,
    required this.id,
    required this.updatedAt,
    required this.syncSeq,
    this.data,
  });

  /// The table the row belongs to.
  final String table;

  /// `upsert` for a live row, `delete` for a tombstone.
  final String op;

  /// The identifier of the row.
  final String id;

  /// The moment the row last changed.
  final DateTime updatedAt;

  /// The cursor of the row's write.
  final int syncSeq;

  /// The fields of the row, when it is alive.
  final Map<String, Object?>? data;

  /// Reads a row from the wire.
  static SyncRow fromJson(Map<String, dynamic> json) => SyncRow(
    table: json['table'] as String,
    op: json['op'] as String,
    id: json['id'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    syncSeq: (json['syncSeq'] as num).toInt(),
    data: json['data'] is Map ? Map<String, Object?>.from(json['data'] as Map) : null,
  );
}

/// What a sync batch answers with.
class SyncBatchResult {
  /// Creates a result.
  const SyncBatchResult({required this.cursor, required this.rows, required this.errors});

  /// The newest cursor the server wrote for the batch.
  final int cursor;

  /// The final state of every operation the server understood.
  final List<SyncRow> rows;

  /// The operations the server refused, with codes.
  final List<Map<String, Object?>> errors;
}

/// What a delta pull answers with.
class SyncPullPage {
  /// Creates a page.
  const SyncPullPage({required this.cursor, required this.hasMore, required this.rows});

  /// The cursor to ask again from next time.
  final int cursor;

  /// Whether another page is waiting.
  final bool hasMore;

  /// The rows changed since the cursor, oldest first.
  final List<SyncRow> rows;
}

/// The sync half of the API (§7.3).
class SyncApi {
  /// Creates the API client.
  SyncApi(this._dio, {SessionHolder? session}) : _session = session ?? SessionHolder();

  final Dio _dio;
  final SessionHolder _session;

  /// The holder the transport reads the bearer token from.
  SessionHolder get session => _session;

  /// Flushes a batch of local changes to the server.
  Future<Result<SyncBatchResult>> push(List<SyncOperation> operations) => _guard(() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/sync/batch',
      data: <String, Object?>{
        'operations': operations.map((SyncOperation operation) => operation.toJson()).toList(),
      },
    );

    final Map<String, dynamic> body = _asMap(response.data);
    return SyncBatchResult(
      cursor: (body['cursor'] as num?)?.toInt() ?? 0,
      rows: (body['rows'] as List<dynamic>? ?? const <dynamic>[]).map((dynamic row) => SyncRow.fromJson(_asMap(row))).toList(),
      errors: (body['errors'] as List<dynamic>? ?? const <dynamic>[]).map(_asMap).toList(),
    );
  });

  /// Pulls the rows changed since [cursor], oldest first.
  Future<Result<SyncPullPage>> pull(int cursor) => _guard(() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/sync',
      queryParameters: <String, Object?>{'since': cursor},
    );

    final Map<String, dynamic> body = _asMap(response.data);
    return SyncPullPage(
      cursor: (body['cursor'] as num?)?.toInt() ?? cursor,
      hasMore: body['hasMore'] as bool? ?? false,
      rows: (body['rows'] as List<dynamic>? ?? const <dynamic>[]).map((dynamic row) => SyncRow.fromJson(_asMap(row))).toList(),
    );
  });

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result<T>.success(await call());
    } on DioException catch (error) {
      return Result<T>.failure(_mapError(error));
    } catch (_) {
      return Result<T>.failure(
        const AppError.client(ClientErrorCodes.unexpected),
      );
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) => data is Map<String, dynamic> ? data : <String, dynamic>{};

  static AppError _mapError(DioException error) {
    final int? status = error.response?.statusCode;
    final dynamic data = error.response?.data;
    final String? code = data is Map && data['code'] is String ? data['code'] as String : null;

    if (status == null) {
      return const AppError.client(ClientErrorCodes.networkUnavailable);
    }

    if (code != null && code.isNotEmpty) {
      return AppError.server(code);
    }

    return switch (status) {
      401 => const AppError.server('refresh_token.reused'),
      403 => const AppError.server('auth.email_not_verified'),
      429 => const AppError.server('auth.rate_limited'),
      >= 500 => const AppError.client(ClientErrorCodes.serverUnavailable),
      _ => const AppError.client(ClientErrorCodes.unexpected),
    };
  }
}
