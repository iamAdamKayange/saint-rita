import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

class HistoryMasaaScreen extends StatefulWidget {
  const HistoryMasaaScreen({super.key});

  @override
  State<HistoryMasaaScreen> createState() => _HistoryMasaaScreenState();
}

class _HistoryMasaaScreenState extends State<HistoryMasaaScreen> {
  int _totalHoursPrayed = 0;
  int _mostFrequentHour = 0;
  int _missedHours = 0;
  String _lastPrayerDate = "Hajawai kusali";
  final Map<int, int> _hourFrequency = {};
  List<PrayerData> _prayerHistory = [];
  int _medalCount = 0;
  // ignore: unused_field
  int _novenaHourProgress = 0;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();

    // Timer ili update live kila sekunde 5
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadHistoryData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();

    final int totalHoursPrayed = prefs.getInt('totalHoursPrayed') ?? 0;
    final int novenaHourProgress = prefs.getInt('novenaHourProgress') ?? 0;

    final Map<int, int> hourFrequency = {};
    for (int i = 1; i <= 15; i++) {
      hourFrequency[i] = prefs.getInt('hour${i}Count') ?? 0;
    }

    int mostFrequentHour = 0;
    if (hourFrequency.isNotEmpty) {
      mostFrequentHour = hourFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    int medalCount = totalHoursPrayed ~/ 15;

    int missedHours = 0;
    String lastPrayerDate = "Hajawai kusali";
    final lastDateMillis = prefs.getInt('lastPrayerDateMasaa');
    if (lastDateMillis != null) {
      final lastDate = DateTime.fromMillisecondsSinceEpoch(lastDateMillis);
      missedHours = DateTime.now().difference(lastDate).inHours;
      lastPrayerDate = DateFormat('dd/MM/yyyy HH:mm').format(lastDate);
    }

    List<PrayerData> prayerHistory = [];
    final historyString = prefs.getString('prayerHistoryMasaa');
    if (historyString != null && historyString.isNotEmpty) {
      final List<String> historyItems = historyString.split(';');
      final Map<String, int> prayersByDate = {};
      for (final item in historyItems) {
        if (item.contains(':')) {
          final parts = item.split(':');
          if (parts.length == 2) {
            final date = parts[0];
            prayersByDate[date] = (prayersByDate[date] ?? 0) + 1;
          }
        }
      }

      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        final count = prayersByDate[dateString] ?? 0;

        prayerHistory.add(
          PrayerData(
            date: DateFormat('E').format(date),
            count: count,
            fullDate: DateFormat('MMM d').format(date),
          ),
        );
      }
    }

    // Update state if something changed
    if (mounted) {
      setState(() {
        _totalHoursPrayed = totalHoursPrayed;
        _novenaHourProgress = novenaHourProgress;
        _hourFrequency.clear();
        _hourFrequency.addAll(hourFrequency);
        _mostFrequentHour = mostFrequentHour;
        _medalCount = medalCount;
        _missedHours = missedHours;
        _lastPrayerDate = lastPrayerDate;
        _prayerHistory = prayerHistory;
      });
    }
  }

  Future<void> _resetHistoryData() async {
    final prefs = await SharedPreferences.getInstance();

    // Futa masaa yote yaliyosaliwa
    await prefs.remove('totalHoursPrayed');
    await prefs.setInt('novenaHourProgress', 0);
    await prefs.setBool('novenaHourCycleCompleted', false);
    await prefs.remove('novenaHourScheduleStart');
    final notifications = context.read<NotificationProvider>();
    if (notifications.hourlyReminder)
      await notifications.scheduleHourlyPrayer();

    // Futa frequency ya kila saa (1 hadi 15)
    for (int i = 1; i <= 15; i++) {
      await prefs.remove('hour${i}Count');
    }

    // Futa tarehe ya mwisho kusali
    await prefs.remove('lastPrayerDateMasaa');

    // Futa historia ya maombi ya siku
    await prefs.remove('prayerHistoryMasaa');

    // Baada ya kufuta, update UI
    if (mounted) {
      setState(() {
        _totalHoursPrayed = 0;
        _novenaHourProgress = 0;
        _hourFrequency.clear();
        _mostFrequentHour = 0;
        _medalCount = 0;
        _missedHours = 0;
        _lastPrayerDate = "Hajawai kusali";
        _prayerHistory.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Historia ya Novena ya Masaa 15",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
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
                        "Takwimu za Novena ya Masaa 15",
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  "Masaa Yaliyosaliwa",
                  _totalHoursPrayed.toString(),
                  Icons.access_time_filled,
                  GlassDesignSystem.emerald,
                ),
                _buildStatCard(
                  "Saa Inayopendwa",
                  _mostFrequentHour > 0 ? "Saa $_mostFrequentHour" : "Hakuna",
                  Icons.favorite,
                  GlassDesignSystem.divineBlue,
                ),
                _buildStatCard(
                  "Masaa Yanayokosekana",
                  _missedHours > 0 ? "$_missedHours masaa" : "Hakuna",
                  Icons.timer_off,
                  GlassDesignSystem.softGold,
                ),
                _buildStatCard(
                  "Mwisho Kusali",
                  _lastPrayerDate,
                  Icons.calendar_today,
                  GlassDesignSystem.emerald,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                      "Mara za Kusali Kila Saa",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(15, (index) {
                      final hour = index + 1;
                      final count = _hourFrequency[hour] ?? 0;
                      return _buildDayFrequencyRow(hour, count, context);
                    }),
                  ],
                ),
              ),
            ),
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
                          _medalCount >= 1,
                          Icons.emoji_events,
                        ),
                        _buildAchievement(
                          "Novena 5",
                          _medalCount >= 5,
                          Icons.workspace_premium,
                        ),
                        _buildAchievement(
                          "Novena 10",
                          _medalCount >= 10,
                          Icons.star,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                        "Mapigo ya Maombi (Siku 7 Zilizopita)",
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
                            ColumnSeries<PrayerData, String>(
                              dataSource: _prayerHistory,
                              xValueMapper: (PrayerData data, _) => data.date,
                              yValueMapper: (PrayerData data, _) => data.count,
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
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showResetConfirmationDialog(context);
                  },
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
    );
  }

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
            child: Text("Saa $day", style: const TextStyle(fontSize: 16)),
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
}

class PrayerData {
  final String date;
  final int count;
  final String fullDate;

  PrayerData({required this.date, required this.count, required this.fullDate});
}
