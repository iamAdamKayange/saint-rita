import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

class HistorySikuScreen extends StatefulWidget {
  const HistorySikuScreen({super.key});

  @override
  State<HistorySikuScreen> createState() => _HistorySikuScreenState();
}

class _HistorySikuScreenState extends State<HistorySikuScreen> {
  // Stats
  int _totalNovenasCompleted = 0;
  int _currentDayProgress = 0;
  int _mostFrequentDay = 0;
  int _missedDays = 0;
  String _lastPrayerDate = "Hajawai kumaliza";

  // Daily counts
  final Map<int, int> _dayFrequency = {};

  // Last 7 days history for chart
  List<PrayerDayData> _prayerHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load daily counts na calculate total progress
    // ignore: unused_local_variable
    int totalDaysPrayed = 0;
    for (int i = 1; i <= 9; i++) {
      _dayFrequency[i] = prefs.getInt('day${i}Count') ?? 0;
      totalDaysPrayed += _dayFrequency[i]!;
    }

    // Load total completed novenas
    _totalNovenasCompleted = prefs.getInt('totalNovenasCompleted') ?? 0;

    // Update current progress
    _currentDayProgress = prefs.getInt('novenaProgress') ?? 0;

    // Most frequent day
    if (_dayFrequency.isNotEmpty) {
      _mostFrequentDay = _dayFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // Last prayer date na missed days
    final lastDateMillis = prefs.getInt('lastPrayerDate');
    if (lastDateMillis != null) {
      final lastDate = DateTime.fromMillisecondsSinceEpoch(lastDateMillis);
      final now = DateTime.now();
      _missedDays = now.difference(lastDate).inDays;
      _lastPrayerDate = DateFormat('dd/MM/yyyy').format(lastDate);
    } else {
      _missedDays = 0;
      _lastPrayerDate = "Hajawai kumaliza";
    }

    // Load last 7 days history
    List<PrayerDayData> prayerHistory = [];
    final historyString = prefs.getString('prayerHistorySiku') ?? '';
    final Map<String, int> prayersByDate = {};

    if (historyString.isNotEmpty) {
      for (final item in historyString.split(';')) {
        if (item.contains(':')) {
          final parts = item.split(':');
          if (parts.length == 2) {
            final date = parts[0];
            final count = int.tryParse(parts[1]) ?? 0;
            prayersByDate[date] = count;
          }
        }
      }
    }

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final count = prayersByDate[dateString] ?? 0;

      prayerHistory.add(
        PrayerDayData(
          date: DateFormat('E', 'sw_TZ').format(date),
          count: count,
          fullDate: DateFormat('MMM d').format(date),
        ),
      );
    }

    setState(() {
      _prayerHistory = prayerHistory;
    });

    // 🔹 Debug print ili kuona kama data inasomwa
    debugPrint('Loaded _dayFrequency: $_dayFrequency');
    debugPrint('Loaded _currentDayProgress: $_currentDayProgress');
    debugPrint('Loaded _prayerHistory (last 7 days): $_prayerHistory');
  }

  // Complete Novena when progress reaches 9
  Future<void> _completeNovena() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset progress and daily counts
    await prefs.setInt('novenaProgress', 0);
    await prefs.setBool('novenaCompleted', false);
    final notifications = context.read<NotificationProvider>();
    if (notifications.dailyReminder) await notifications.scheduleDailyPrayer();
    _totalNovenasCompleted += 1;

    for (int i = 1; i <= 9; i++) {
      await prefs.remove('day${i}Count');
    }
    await prefs.remove('lastPrayerDate');
    await prefs.remove('prayerHistorySiku');

    setState(() {
      _currentDayProgress = 0;
      _dayFrequency.clear();
      _prayerHistory.clear();
      _lastPrayerDate = "Hajawai kumaliza";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hongera! Umemaliza Novena"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Reset all history data
  Future<void> _resetHistoryData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('totalNovenasCompleted');
    for (int i = 1; i <= 9; i++) {
      await prefs.remove('day${i}Count');
    }
    await prefs.remove('lastPrayerDate');
    await prefs.remove('novenaProgress');
    await prefs.setBool('novenaCompleted', false);
    await prefs.remove('prayerHistorySiku');
    final notifications = context.read<NotificationProvider>();
    if (notifications.dailyReminder) await notifications.scheduleDailyPrayer();

    setState(() {
      _currentDayProgress = 0;
      _totalNovenasCompleted = 0;
      _dayFrequency.clear();
      _prayerHistory.clear();
      _lastPrayerDate = "Hajawai kumaliza";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Takwimu zimefutwa kikamilifu"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Confirmation dialog before reset
  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Safisha Takwimu?"),
          content: const Text(
            "Unahakika unataka kufuta takwimu zote za historia ya maombi yako? Hatua hii haiwezi kutenduliwa.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ghairi"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetHistoryData();
              },
              child: const Text("Safisha", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadHistoryData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Historia ya Novena Yako",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card with Lottie animation
              Center(
                child: Card(
                  elevation: 4,
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Lottie.asset(
                          "assets/animations/history.json",
                          height: 100,
                          width: 100,
                          repeat: true,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Takwimu za Novena ya Siku 9",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Stats cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    "Novena Zilizokamilika",
                    _totalNovenasCompleted.toString(),
                    Icons.check_circle,
                    GlassDesignSystem.emerald,
                  ),
                  _buildStatCard(
                    "Siku ya Mwisho Kusali",
                    _lastPrayerDate,
                    Icons.calendar_today,
                    GlassDesignSystem.divineBlue,
                  ),
                  _buildStatCard(
                    "Siku Zilizokosekana",
                    _missedDays > 0 ? "$_missedDays siku" : "Hakuna ukosefu",
                    Icons.error_outline,
                    GlassDesignSystem.softGold,
                  ),
                  _buildStatCard(
                    "Siku Unayopenda Zaidi",
                    _mostFrequentDay > 0
                        ? "Siku $_mostFrequentDay"
                        : "Bado hakuna",
                    Icons.favorite,
                    GlassDesignSystem.cathedralStone,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Progress bar and "Malizia Novena"
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: _currentDayProgress / 9,
                        minHeight: 10,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Siku $_currentDayProgress / 9 zimefika",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_currentDayProgress == 9)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _completeNovena,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Malizia Novena"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Daily counts
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mara za Kusali Kila Siku",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(9, (index) {
                        final day = index + 1;
                        final count = _dayFrequency[day] ?? 0;
                        return _buildDayFrequencyRow(day, count, context);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Medals
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medali Zako",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAchievement(
                            "Novena 1",
                            _totalNovenasCompleted >= 1,
                            Icons.emoji_events,
                          ),
                          _buildAchievement(
                            "Novena 5",
                            _totalNovenasCompleted >= 5,
                            Icons.workspace_premium,
                          ),
                          _buildAchievement(
                            "Novena 10",
                            _totalNovenasCompleted >= 9,
                            Icons.star,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Last 7 days chart
              if (_prayerHistory.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Historia ya Siku 7 Zilizopita",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(labelRotation: 0),
                            series: <CartesianSeries>[
                              ColumnSeries<PrayerDayData, String>(
                                dataSource: _prayerHistory,
                                xValueMapper: (PrayerDayData data, _) =>
                                    data.date,
                                yValueMapper: (PrayerDayData data, _) =>
                                    data.count,
                                color: Theme.of(context).colorScheme.primary,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _prayerHistory.map((data) {
                            return Chip(
                              label: Text("${data.fullDate}: ${data.count}"),
                              backgroundColor: data.count > 0
                                  ? Theme.of(context).colorScheme.primary
                                        .withAlpha((0.2 * 255).toInt())
                                  : Colors.grey[300],
                              labelStyle: TextStyle(
                                color: data.count > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Reset button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showResetConfirmationDialog(context),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text("Safisha Takwimu Zote"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Stat card builder
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.tertiary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Day frequency row builder
  Widget _buildDayFrequencyRow(int day, int count, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: GlassDesignSystem.emerald,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text("Siku $day", style: const TextStyle(fontSize: 16)),
          ),
          Text(
            "$count mara",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Achievement / medal builder
  Widget _buildAchievement(String title, bool achieved, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 36,
          color: achieved ? GlassDesignSystem.softGold : Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: achieved ? GlassDesignSystem.softGold : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

// Data class for daily history
class PrayerDayData {
  final String date;
  final int count;
  final String fullDate;

  PrayerDayData({
    required this.date,
    required this.count,
    required this.fullDate,
  });
}
