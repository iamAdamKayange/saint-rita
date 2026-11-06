import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../../provider/theme_provider.dart';
import '../../masaa15/screen/mtakatifu_rita_screen.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import '../../../screen/language_screen.dart';

class SettingMasaaScreen extends StatefulWidget {
  const SettingMasaaScreen({super.key});

  @override
  State<SettingMasaaScreen> createState() => _SettingMasaaScreenState();
}

class _SettingMasaaScreenState extends State<SettingMasaaScreen> {
  int _currentHourProgress = 0;

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: GlassDesignSystem.emerald,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget buildCard(BuildContext _, List<Widget> children) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHourProgress();
  }

  Future<void> _loadHourProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentHourProgress = prefs.getInt("novenaHourProgress") ?? 0;
    });
  }

  Future<void> _handleHourReminder(bool value) async {
    final provider = context.read<NotificationProvider>();
    await provider.toggleReminder(NotificationType.hourly, value, context);

    // notifyListeners ndani ya NotificationProvider itakamilisha update
    // setState(() {}); // optional, unaweza kuondoa ikiwa UI inajenga tena kupitia Consumer
  }

  Future<void> _selectTime() async {
    final provider = context.read<NotificationProvider>();
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.hourlyTime,
    );

    if (picked != null) {
      if (!mounted) return;

      // Updating the time reschedules and replaces the existing hourly alarms.
      await provider.setHourlyTime(picked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Muda wa kikumbusho umebadilishwa: ${picked.format(context)}",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _resetHourProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("novenaHourProgress", 0);
    await prefs.setBool('novenaHourCycleCompleted', false);
    await prefs.remove('novenaHourScheduleStart');
    final notifications = context.read<NotificationProvider>();
    if (notifications.hourlyReminder)
      await notifications.scheduleHourlyPrayer();
    setState(() {
      _currentHourProgress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            buildSectionTitle("Muonekano"),
            buildCard(context, [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Hali ya Giza"),
                subtitle: const Text(
                  "Tumia mitindo ya giza kwa usome na kuelewa vizuri usiku",
                ),
                trailing: CupertinoSwitch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) =>
                      context.read<ThemeProvider>().toggleTheme(),
                ),
              ),
            ]),

            // Notifications
            buildSectionTitle("Taarifa"),
            buildCard(context, [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Kikumbusho cha Kila Lisaa"),
                subtitle: const Text("Pata vikumbusho vya maombi kila Lisaa"),
                trailing: CupertinoSwitch(
                  value: notificationProvider.hourlyReminder,
                  onChanged: _handleHourReminder,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text("Muda wa Kikumbusho"),
                subtitle: Text(notificationProvider.hourlyTime.format(context)),
                onTap: _selectTime,
              ),
            ]),

            // Language
            buildSectionTitle("Lugha"),
            buildCard(context, [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Badilisha Lugha"),
                subtitle: const Text("Chagua lugha ya kutumia app"),
                onTap: () {
                  LanguageDialog.show(context);
                },
              ),
            ]),

            // Prayer Progress
            buildSectionTitle("Maendeleo ya Maombi"),
            buildCard(context, [
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text("Anzisha Upya Maendeleo"),
                subtitle: const Text("Anza novena kutoka Lisaa La 1"),
                onTap: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Anzisha Novena Upya"),
                      content: const Text(
                        "Kama kweli unataka uanzishe novena upya, bonyeza kitufe cha Ruhusu",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Zuhia"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Ruhusu"),
                        ),
                      ],
                    ),
                  );
                  if (confirm ?? false) {
                    await _resetHourProgress();
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Anzisha Novena Upya"),
                          content: const Text(
                            "Kama kweli unataka uanzishe novena upya, bonyeza kitufe cha Ruhusu",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Zuhia"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final ValueNotifier<bool> isLoading =
                                    ValueNotifier(true);

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => ValueListenableBuilder<bool>(
                                    valueListenable: isLoading,
                                    builder: (context, loading, child) => AlertDialog(
                                      content: SizedBox(
                                        height: 250,
                                        child: Center(
                                          child: loading
                                              ? const CircularProgressIndicator()
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Lottie.asset(
                                                      "assets/animations/completed.json",
                                                      repeat: false,
                                                      fit: BoxFit.contain,
                                                      height: 180,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      "Novena imesha anzishwa upya",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: GlassDesignSystem
                                                            .emerald,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      actions: loading
                                          ? null
                                          : [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sawa"),
                                              ),
                                            ],
                                    ),
                                  ),
                                );

                                isLoading.value = false;
                              },
                              child: const Text("Ruhusu"),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                title: const Text("Maendeleo"),
                subtitle: Text(
                  "Lisaa ${_currentHourProgress + 1} kati ya Masaa 15 yamekamilika",
                ),
                trailing: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: (_currentHourProgress + 1) / 15,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      GlassDesignSystem.emerald,
                    ),
                  ),
                ),
              ),
            ]),

            // About
            buildSectionTitle("Kuhusu"),
            buildCard(context, [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Kuhusu Mtakatifu Rita"),
                subtitle: const Text(
                  "Jifunze zaidi kuhusu Mtakatifu wa Yasiyo Wezekana",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MtakatifuRitaMasaaPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Shiriki App"),
                subtitle: const Text("Shiriki app hii na marafiki na familia"),
                onTap: () {
                  Share.share(
                    'Hii ndiyo app yetu nzuri! Pakua hapa: https://example.com/download',
                    subject: 'Jaribu app hii!',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_rounded),
                title: const Text("Toleo la App"),
                subtitle: const Text("1.0.0"),
              ),
              ListTile(
                leading: const Icon(Icons.star_rate),
                title: const Text("Tupe Tathmini"),
                subtitle: const Text("Tupatie maoni yako kuhusu app hii"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text("Sera ya Faragha"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text("Sheria na Masharti"),
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
