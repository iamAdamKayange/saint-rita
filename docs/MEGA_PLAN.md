# Saint Rita Novena — Mega Improvement Plan

App: Flutter (Android/iOS), Provider state, SharedPreferences storage,
`flutter_local_notifications` + Firebase Cloud Messaging, AdMob, Swahili/English.

Status legend: ✅ done in this pass · 🔜 next · 📋 backlog

---

## 1. Notifications (highest priority)

### Bugs found
| # | Problem | Where | Status |
|---|---------|-------|--------|
| N1 | Unread badge grows by 1 on **every app launch**: `_init()` re-schedules the general reminder, which calls `addNotification()` → `incrementUnread()` each time. | `provider/notification_provider.dart` | ✅ unread is now derived from the inbox, not a counter |
| N2 | 9-day and 15-hour reminders are scheduled on the device but **never appear in the in-app inbox**. | `scheduleDailyPrayer`, `scheduleHourlyPrayer` | ✅ each scheduled reminder is logged with its due time |
| N3 | Reminders say "5 minutes before" but use `inexactAllowWhileIdle`; Android Doze can delay them 10–60 min. | `services/not_services.dart` | ✅ exact alarms when allowed, inexact fallback |
| N4 | All notification text is Swahili even when the app is in English. | provider + `main.dart` | ✅ bilingual text follows `preferredLanguage` |
| N5 | Push messages received while the app is closed are lost from the inbox (background handler does nothing). | `main.dart` | ✅ background handler queues them; merged on next start |
| N6 | No explicit Android 13+ `POST_NOTIFICATIONS` request through the local plugin, and no `SCHEDULE_EXACT_ALARM` permission in the manifest. | manifest, service | ✅ |
| N7 | `toggleReminder` uses `context` after `await` (can crash if the screen closed). | provider | ✅ `context.mounted` guard |
| N8 | Inbox grows forever (every launch adds entries). | provider | ✅ capped at 100, de-duplicated |
| N9 | Duplicate, unused provider with a clashing `NotificationProvider` type, a fully commented-out provider, and a broken `InAppNotificationBanner`. | `pages/siku9/provider/`, `pages/masaa15/provider/`, `widgets/` | ✅ deleted |

### Inbox UX
- ✅ "Mark all as read" action.
- ✅ Swipe a card to remove it.
- 🔜 Detail sheet: "Pray now" button that opens the matching novena (daily → `NovenaTwo`, hourly → `NovenaOne`).
- 🔜 Group by Today / Yesterday / Earlier.
- 📋 App-icon badge count (`flutter_app_badger` or iOS badge field).

### Scheduling features
- 🔜 Let the user pick the time of the general reminder (fixed at 07:00 today).
- 🔜 Choose lead time (on time / 5 / 10 / 15 min before).
- 🔜 "Missed prayer" nudge: if a novena day passes without prayer, one gentle reminder the next morning.
- 🔜 Reschedule on timezone change and after the app is updated (re-run `ready` on `AppLifecycleState.resumed`).
- 📋 Notification actions: "Pray now" / "Snooze 15 min" buttons on the notification itself.
- 📋 Feast-day pushes (St. Rita feast, 22 May) via FCM topic + local fallback.
- 📋 Quiet hours (no reminders 22:00–06:00 unless the user chose that time).

### Permission flow
- 🔜 Move the permission prompt out of `main()` (it fires before the splash) into onboarding, with a short explanation screen first.
- 🔜 Settings row showing "Notifications blocked — open settings" when permission is denied.

---

## 2. Experience & visuals
- ✅ Animated 3D St. Rita / nun figure (`widgets/animated_nun_3d.dart`): drawn in code, no new packages, gentle turn, breathing, halo, floating petals; reduce-motion aware.
- 🔜 Use the nun on splash, novena completion pages and empty inbox state.
- 📋 Optional true 3D: model a low-poly nun in Blender → `.glb` → `model_viewer_plus` (adds a WebView, ~2–4 MB).
- 🔜 Prayer reading: font-size slider, keep-screen-awake while praying, resume scroll position.
- 📋 Audio: optional recorded prayers (Swahili/English) with background playback.
- 📋 Home-screen widget showing today's novena step.

## 3. Prayer journey
- 🔜 Streaks and a calendar heat-map in History.
- 🔜 Prayer intentions journal (write an intention when starting a novena, see it on completion).
- 📋 Share a completed novena card (image) via `share_plus`.
- 📋 Litany & extra devotions in the Devotions tab.

## 4. Code health
- 🔜 Remove dead code (see N9) and the 6 analyzer warnings.
- 🔜 Replace `SharedPreferences` JSON lists with a typed repository (later: `hive`/`isar`).
- 🔜 Centralise all user text in `localization/` (many screens use inline `sw ? … : …`).
- 🔜 Unit tests for scheduling math (day rollover, missed hour, DST) and widget test for the inbox; fix the stale default `widget_test.dart`.
- 📋 CI: `flutter analyze` + tests on every push (repo is not under git yet — `git init` first).

## 5. Release & store
- 🔜 Enable R8 (`isMinifyEnabled = true`) with proguard keep rules for Firebase/AdMob — smaller APK.
- 🔜 Real `README.md`, `pubspec` description, version bump policy.
- 🔜 **Security:** `android/key.properties` and `upload-keystore.jks` live in the project folder — keep them out of any git repo and back them up offline.
- 📋 Crashlytics + Analytics (opt-in) to see real reminder delivery rates.
- 📋 Ads: frequency cap, never show interstitials during prayer.

---

## Suggested order
1. Notification fixes (this pass) → test on a real Android 13/14 phone.
2. Permission flow + general-time picker + "Pray now" deep link.
3. Dead-code cleanup, tests, git + CI.
4. Visual polish (nun across screens, reading comfort).
5. Journey features, store/release hardening.
