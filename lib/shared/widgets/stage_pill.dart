import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/leads/lead_model.dart';

class StagePill extends StatelessWidget {
  const StagePill(this.stage, {super.key});
  final LeadStage stage;

  Color get _color => switch (stage) {
        LeadStage.hot => AppColors.danger,
        LeadStage.warm => AppColors.warning,
        LeadStage.newLead => AppColors.info,
        LeadStage.converted || LeadStage.qualified => AppColors.success,
        LeadStage.lost => AppColors.textMuted,
        _ => AppColors.brand,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(stage.label,
          style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
