import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'copilot_models.dart';

/// Streams an agent turn over SSE (POST /v1/agent-runtime/message/stream).
/// Yields progress frames as the loop runs, then a final result frame.
/// Mirrors the web agent.api.ts parser: CRLF-normalized, event/data aware,
/// partial-frame buffered.
class CopilotRepository {
  CopilotRepository(this._api);
  final ApiClient _api;

  Stream<CopilotEvent> stream(String sessionId, String message, {bool confirmed = false}) async* {
    final resp = await _api.dio.post(
      '/v1/agent-runtime/message/stream',
      data: {'sessionId': sessionId, 'message': message, 'confirmed': confirmed},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (resp.statusCode != 200 || resp.data is! ResponseBody) {
      yield CopilotEvent.result(AgentResult(status: AgentStatus.error, response: 'The copilot is unavailable (${resp.statusCode}).'));
      return;
    }

    final body = resp.data as ResponseBody;
    var buffer = '';
    await for (final chunk in body.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      buffer = buffer.replaceAll('\r\n', '\n');

      final frames = buffer.split('\n\n');
      buffer = frames.isNotEmpty ? frames.removeLast() : '';

      for (final frame in frames) {
        var eventName = 'message';
        final dataLines = <String>[];
        for (final line in frame.split('\n')) {
          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataLines.add(line.substring(5).replaceFirst(RegExp(r'^ '), ''));
          }
        }
        final payload = dataLines.join('\n').trim();
        if (payload.isEmpty) continue;
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          if (eventName == 'progress') {
            yield CopilotEvent.progress(AgentProgress.fromJson(json));
          } else if (eventName == 'result') {
            yield CopilotEvent.result(AgentResult.fromJson(json));
          }
        } catch (_) {
          // skip malformed frame, keep the stream alive
        }
      }
    }
  }
}
