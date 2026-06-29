import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'copilot_controller.dart';

class CopilotScreen extends ConsumerStatefulWidget {
  const CopilotScreen({super.key});
  @override
  ConsumerState<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends ConsumerState<CopilotScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(copilotControllerProvider);
    _autoScroll();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Icon(Icons.auto_awesome, color: AppColors.brand, size: 18),
          SizedBox(width: 8),
          Text('CRM Copilot', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                if (s.messages.isEmpty && !s.streaming)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text('Ask: "show my hot leads", "create a task to call Acme",\nor "what changed on deal X?"',
                          textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                  ),
                for (final m in s.messages) _Bubble(m),
                if (s.streaming) ...[
                  for (final line in s.progress) _ProgressLine(line),
                  if (s.progress.isEmpty) const _ProgressLine('Thinking…'),
                ],
                if (s.confirmPrompt != null) _ConfirmCard(prompt: s.confirmPrompt!),
              ],
            ),
          ),
          _Composer(input: _input),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final CopilotMessage m;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: m.fromUser ? AppColors.brand : AppColors.glass1,
          borderRadius: BorderRadius.circular(12),
          border: m.fromUser ? null : Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Text(m.text,
            style: TextStyle(color: m.fromUser ? AppColors.bg : AppColors.textPrimary, fontSize: 14, height: 1.35)),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.6, color: AppColors.brand)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
      ]),
    );
  }
}

class _ConfirmCard extends ConsumerWidget {
  const _ConfirmCard({required this.prompt});
  final String prompt;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(copilotControllerProvider.notifier);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(prompt, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: c.cancelConfirm, child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
            const SizedBox(width: 8),
            FilledButton(onPressed: c.confirm, child: const Text('Confirm')),
          ]),
        ],
      ),
    );
  }
}

class _Composer extends ConsumerWidget {
  const _Composer({required this.input});
  final TextEditingController input;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaming = ref.watch(copilotControllerProvider.select((s) => s.streaming));
    void submit() {
      final t = input.text.trim();
      if (t.isEmpty || streaming) return;
      input.clear();
      ref.read(copilotControllerProvider.notifier).send(t);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: input,
                minLines: 1,
                maxLines: 4,
                enabled: !streaming,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => submit(),
                decoration: const InputDecoration(hintText: 'Ask the copilot…', isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: streaming ? null : submit,
              style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(14)),
              child: streaming
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                  : const Icon(Icons.arrow_upward, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
