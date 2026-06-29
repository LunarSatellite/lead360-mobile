import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';

class LeadStats {
  final int total, newCount, warmCount, hotCount, nurturingCount, convertedCount, lostCount, convertedToday;
  final double conversionRate;
  const LeadStats({
    this.total = 0, this.newCount = 0, this.warmCount = 0, this.hotCount = 0, this.nurturingCount = 0,
    this.convertedCount = 0, this.lostCount = 0, this.convertedToday = 0, this.conversionRate = 0,
  });
  factory LeadStats.fromJson(Map<String, dynamic> j) => LeadStats(
        total: intOr(j, 'total'),
        newCount: intOr(j, 'newCount'),
        warmCount: intOr(j, 'warmCount'),
        hotCount: intOr(j, 'hotCount'),
        nurturingCount: intOr(j, 'nurturingCount'),
        convertedCount: intOr(j, 'convertedCount'),
        lostCount: intOr(j, 'lostCount'),
        convertedToday: intOr(j, 'convertedToday'),
        conversionRate: doubleOr(j, 'conversionRate'),
      );
}

class DealStats {
  final int openCount, closedWonCount;
  final double winRate, avgDealSize, totalPipelineValue, closingThisMonthValue;
  const DealStats({
    this.openCount = 0, this.closedWonCount = 0, this.winRate = 0,
    this.avgDealSize = 0, this.totalPipelineValue = 0, this.closingThisMonthValue = 0,
  });
  factory DealStats.fromJson(Map<String, dynamic> j) => DealStats(
        openCount: intOr(j, 'openCount'),
        closedWonCount: intOr(j, 'closedWonCount'),
        winRate: doubleOr(j, 'winRate'),
        avgDealSize: doubleOr(j, 'avgDealSize'),
        totalPipelineValue: doubleOr(j, 'totalPipelineValue'),
        closingThisMonthValue: doubleOr(j, 'closingThisMonthValue'),
      );
}

class DashboardData {
  final LeadStats leads;
  final DealStats deals;
  const DashboardData(this.leads, this.deals);
}

/// Loads lead + deal stats in parallel. A failing half degrades to zeros rather
/// than blanking the whole dashboard.
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final api = ref.read(apiClientProvider);
  Future<LeadStats> leads() async {
    try {
      final r = await api.dio.get('/v1/crm/leads/stats');
      return r.data is Map ? LeadStats.fromJson(Map<String, dynamic>.from(r.data)) : const LeadStats();
    } catch (_) {
      return const LeadStats();
    }
  }

  Future<DealStats> deals() async {
    try {
      final r = await api.dio.get('/v1/crm/analytics/deals');
      return r.data is Map ? DealStats.fromJson(Map<String, dynamic>.from(r.data)) : const DealStats();
    } catch (_) {
      return const DealStats();
    }
  }

  final res = await Future.wait([leads(), deals()]);
  return DashboardData(res[0] as LeadStats, res[1] as DealStats);
});
