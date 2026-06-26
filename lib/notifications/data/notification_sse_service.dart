import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationSseEvent {
  const NotificationSseEvent({required this.type, this.data});

  final String type;
  final Map<String, dynamic>? data;
}

class NotificationSseService {
  NotificationSseService({required this.baseUrl, this.enableLog = false});

  final String baseUrl;
  bool enableLog;

  void _log(String message) {
    if (enableLog) debugPrint(message);
  }

  final _controller = StreamController<NotificationSseEvent>.broadcast();
  Stream<NotificationSseEvent> get events => _controller.stream;

  http.Client? _client;
  StreamSubscription<String>? _streamSub;
  Timer? _reconnectTimer;
  int _retryCount = 0;
  bool _disposed = false;
  bool _connected = false;
  String? _token;

  bool get isConnected => _connected;

  Future<void> connect({required String token}) async {
    if (_disposed) return;
    _token = token;
    disconnect(keepToken: true);

    try {
      _client = http.Client();
      final uri = Uri.parse('$baseUrl/api/notifications/stream');
      final request = http.Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache'
        ..headers['Authorization'] = 'Bearer $token';

      final response = await _client!.send(request);

      if (response.statusCode == 401 || response.statusCode == 403) {
        _log('SSE: auth failed (${response.statusCode}), not reconnecting');
        _connected = false;
        return;
      }

      if (response.statusCode != 200) {
        _log('SSE: unexpected status ${response.statusCode}');
        _scheduleReconnect();
        return;
      }

      _connected = true;
      _log('SSE: connected');

      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      var eventType = '';
      var dataBuffer = StringBuffer();

      _streamSub = lines.listen(
        (line) {
          // Bytes are flowing: the connection is genuinely healthy, so reset
          // backoff. Resetting on HTTP 200 alone caused a 2s hot-loop when the
          // server accepted then immediately closed the stream.
          _retryCount = 0;
          if (line.startsWith('event:')) {
            eventType = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataBuffer.write(line.substring(5).trim());
          } else if (line.isEmpty && dataBuffer.isNotEmpty) {
            _emitEvent(
              eventType.isNotEmpty ? eventType : 'message',
              dataBuffer.toString(),
            );
            eventType = '';
            dataBuffer = StringBuffer();
          }
        },
        onDone: () {
          _log('SSE: stream closed');
          _connected = false;
          _scheduleReconnect();
        },
        onError: (Object e) {
          _log('SSE: stream error: $e');
          _connected = false;
          _scheduleReconnect();
        },
      );
    } on Exception catch (e) {
      _log('SSE: connect error: $e');
      _connected = false;
      _scheduleReconnect();
    }
  }

  void _emitEvent(String type, String rawData) {
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } on FormatException catch (_) {
      // rawData is not valid JSON — emit event without data
    }

    _controller.add(NotificationSseEvent(type: type, data: data));
  }

  static final _jitterRng = Random();

  void _scheduleReconnect() {
    if (_disposed || _token == null) return;
    _reconnectTimer?.cancel();
    final base = min(30, 2 * pow(2, _retryCount)).toInt();
    final jitter = _jitterRng.nextInt(max(1, base ~/ 2));
    final delay = base + jitter;
    _retryCount++;
    _log('SSE: reconnecting in ${delay}s (attempt $_retryCount)');
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_disposed && _token != null) {
        connect(token: _token!);
      }
    });
  }

  void disconnect({bool keepToken = false}) {
    _reconnectTimer?.cancel();
    _streamSub?.cancel();
    _streamSub = null;
    _client?.close();
    _client = null;
    _connected = false;
    if (!keepToken) _token = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller.close();
  }
}
