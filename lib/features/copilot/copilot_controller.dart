import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'copilot_models.dart';
import 'copilot_repository.dart';

final copilotRepositoryProvider = Provider<CopilotRepository>((ref) => CopilotRepository(ref.read(apiClientProvider)));

class CopilotMessage {
  final bool fromUser;
  final String text;
  const CopilotMessage(this.fromUser, this.text);
}

class CopilotState {
  final List<CopilotMessage> messages;
  final List<String> progress;
  final bool streaming;
  final String? confirmPrompt;

  const CopilotState({
    this.messages = const [],
    this.progress = const [],
    this.streaming = false,
    this.confirmPrompt,
  });

  CopilotState copyWith({
    List<CopilotMessage>? messages,
    List<String>? progress,
    bool? streaming,
    String? confirmPrompt,
    bool clearConfirm = false,
  }) =>
      CopilotState(
        messages: messages ?? this.messages,
        progress: progress ?? this.progress,
        streaming: streaming ?? this.streaming,
        confirmPrompt: clearConfirm ? null : (confirmPrompt ?? this.confirmPrompt),
      );
}

class CopilotController extends AutoDisposeNotifier<CopilotState> {
  late final String _sessionId;

  @override
  CopilotState build() {
    _sessionId = _newId();
    return const CopilotState();
  }

  static String _newId() {
    final r = Random();
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final rand = List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
    return '$ts$rand';
  }

  Future<void> send(String text) => _run(text, confirmed: false, echo: true);
  Future<void> confirm() => _run('Confirmed.', confirmed: true, echo: false);
  void cancelConfirm() => state = state.copyWith(clearConfirm: true);

  Future<void> _run(String text, {required bool confirmed, required bool echo}) async {
    if (state.streaming) return;
    final msgs = echo ? [...state.messages, CopilotMessage(true, text)] : state.messages;
    state = state.copyWith(messages: msgs, progress: [], streaming: true, clearConfirm: true);

    try {
      await for (final ev in ref.read(copilotRepositoryProvider).stream(_sessionId, text, confirmed: confirmed)) {
        switch (ev) {
          case CopilotProgressEvent(:final progress):
            state = state.copyWith(progress: [...state.progress, progress.line]);
          case CopilotResultEvent(:final result):
            if (result.status == AgentStatus.awaitingConfirmation) {
              state = state.copyWith(confirmPrompt: result.confirmationPrompt ?? 'Confirm this action?');
            } else {
              state = state.copyWith(
                messages: [...state.messages, CopilotMessage(false, result.response.isEmpty ? '(no response)' : result.response)],
              );
            }
        }
      }
    } catch (e) {
      state = state.copyWith(messages: [...state.messages, CopilotMessage(false, '⚠️ $e')]);
    } finally {
      state = state.copyWith(streaming: false, progress: []);
    }
  }
}

final copilotControllerProvider =
    AutoDisposeNotifierProvider<CopilotController, CopilotState>(CopilotController.new);
