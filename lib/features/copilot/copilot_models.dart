import '../../core/network/json.dart';

/// Agent turn status (mirrors backend AgentRuntimeStatus int enum).
class AgentStatus {
  static const completed = 0;
  static const awaitingConfirmation = 1;
  static const maxIterations = 2;
  static const error = 3;
  static const disabled = 4;
}

/// One streamed progress frame (event: progress).
class AgentProgress {
  final String kind; // tool_call | tool_result | final
  final String? toolName;
  final String? detail;
  final bool success;

  const AgentProgress({required this.kind, this.toolName, this.detail, this.success = true});

  factory AgentProgress.fromJson(Map<String, dynamic> j) => AgentProgress(
        kind: str(j, 'kind') ?? 'final',
        toolName: str(j, 'toolName'),
        detail: str(j, 'detail'),
        success: boolOr(j, 'success', true),
      );

  String get line => switch (kind) {
        'tool_call' => 'Calling ${toolName ?? 'tool'}…',
        'tool_result' => detail ?? '${toolName ?? 'tool'} done',
        _ => 'Thinking…',
      };
}

/// Final turn result (event: result).
class AgentResult {
  final int status;
  final String response;
  final String? confirmationPrompt;

  const AgentResult({required this.status, required this.response, this.confirmationPrompt});

  factory AgentResult.fromJson(Map<String, dynamic> j) => AgentResult(
        status: intOr(j, 'status', AgentStatus.completed),
        response: str(j, 'response') ?? '',
        confirmationPrompt: str(j, 'confirmationPrompt'),
      );
}

/// Discriminated stream event.
sealed class CopilotEvent {
  const CopilotEvent();
  factory CopilotEvent.progress(AgentProgress p) = CopilotProgressEvent;
  factory CopilotEvent.result(AgentResult r) = CopilotResultEvent;
}

class CopilotProgressEvent extends CopilotEvent {
  final AgentProgress progress;
  const CopilotProgressEvent(this.progress);
}

class CopilotResultEvent extends CopilotEvent {
  final AgentResult result;
  const CopilotResultEvent(this.result);
}
