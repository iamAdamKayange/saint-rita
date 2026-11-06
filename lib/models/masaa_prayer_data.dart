import 'dart:convert';

NovenaHourPrayer novenaHourPrayerFromMap(String str) =>
    NovenaHourPrayer.fromJson(json.decode(str));

String novenaHourPrayerToMap(NovenaHourPrayer data) =>
    json.encode(data.toJson());

class NovenaHourPrayer {
  final List<Novena> novena;

  NovenaHourPrayer({required this.novena});

  factory NovenaHourPrayer.fromJson(Map<String, dynamic> json) =>
      NovenaHourPrayer(
        novena: List<Novena>.from(
            (json['novena'] ?? []).map((x) => Novena.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "novena": List<dynamic>.from(novena.map((x) => x.toJson())),
  };
}

class Novena {
  final int hour;
  final String title;
  final String specialNote;
  final String opening;
  final String invocation;
  final List<String> mainPrayer;
  final String personalIntentionInstruction;
  final List<String> praises;
  final Litania litania;
  final List<String> lambOfGod;
  final LeaderResponse leaderResponse;
  final String closingPrayer;
  final String extraNote;

  Novena({
    required this.hour,
    required this.title,
    required this.specialNote,
    required this.opening,
    required this.invocation,
    required this.mainPrayer,
    required this.personalIntentionInstruction,
    required this.praises,
    required this.litania,
    required this.lambOfGod,
    required this.leaderResponse,
    required this.closingPrayer,
    required this.extraNote,
  });

  factory Novena.fromJson(Map<String, dynamic> json) => Novena(
    hour: json['hour'] ?? 0,
    title: json['title'] ?? '',
    specialNote: json['special_note'] ?? '',
    opening: json['opening'] ?? '',
    invocation: json['invocation'] ?? '',
    mainPrayer: List<String>.from(json['main_prayer'] ?? []),
    personalIntentionInstruction: json['personal_intention_instruction'] ?? '',
    praises: List<String>.from(json['praises'] ?? []),
    litania: Litania.fromJson(json['litania'] ?? {}),
    lambOfGod: List<String>.from(json['lamb_of_god'] ?? []),
    leaderResponse: LeaderResponse.fromJson(json['leader_response'] ?? {}),
    closingPrayer: json['closing_prayer'] ?? '',
    extraNote: json['extra_note'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "hour": hour,
    "title": title,
    "special_note": specialNote,
    "opening": opening,
    "invocation": invocation,
    "main_prayer": List<dynamic>.from(mainPrayer),
    "personal_intention_instruction": personalIntentionInstruction,
    "praises": List<dynamic>.from(praises),
    "litania": litania.toJson(),
    "lamb_of_god": List<dynamic>.from(lambOfGod),
    "leader_response": leaderResponse.toJson(),
    "closing_prayer": closingPrayer,
    "extra_note": extraNote,
  };
}

class Litania {
  final List<String> introAcclamation;
  final String response;
  final List<String> invocations;
  final String responseUtuombee;
  final List<String> maryTitles;
  final List<String> mtRitaTitles;

  Litania({
    required this.introAcclamation,
    required this.response,
    required this.invocations,
    required this.responseUtuombee,
    required this.maryTitles,
    required this.mtRitaTitles,
  });

  factory Litania.fromJson(Map<String, dynamic> json) => Litania(
    introAcclamation: List<String>.from(json['intro_acclamation'] ?? []),
    response: json['response'] ?? '',
    invocations: List<String>.from(json['invocations'] ?? []),
    responseUtuombee: json['response_utuombee'] ?? '',
    maryTitles: List<String>.from(json['mary_titles'] ?? []),
    mtRitaTitles: List<String>.from(json['mt_rita_titles'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    "intro_acclamation": List<dynamic>.from(introAcclamation),
    "response": response,
    "invocations": List<dynamic>.from(invocations),
    "response_utuombee": responseUtuombee,
    "mary_titles": List<dynamic>.from(maryTitles),
    "mt_rita_titles": List<dynamic>.from(mtRitaTitles),
  };
}

class LeaderResponse {
  final String kiongozi;
  final String wote;

  LeaderResponse({required this.kiongozi, required this.wote});

  factory LeaderResponse.fromJson(Map<String, dynamic> json) => LeaderResponse(
    kiongozi: json['kiongozi'] ?? '',
    wote: json['wote'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "kiongozi": kiongozi,
    "wote": wote,
  };
}

/// Extension to get Pages for PageView safely
extension NovenaPages on Novena {
  List<String> get pages {
    return [
      // PAGE 1
      """
🕐 Saa: $hour
Kichwa: $title

MAELEZO MAALUM:
$specialNote

Kufungua:
$opening

Maombi ya Mwanzo:
$invocation

Sala Kuu:
${mainPrayer.join("\n\n")}

Maelekezo ya Shida Yako:
$personalIntentionInstruction

Sifa:
${praises.join(", ")}
""",
      // PAGE 2 - Litania & Others
      """
Litania:

Ilikoje: ${litania.introAcclamation.join("\n")}
Kiitikio: "${litania.response}"

Ombi la Maombezi:
${litania.invocations.join("\n")}
Kiitikio: "${litania.responseUtuombee}"

Sifa za Bikira Maria:
${litania.maryTitles.join("\n")}

Sifa za Mt Rita:
${litania.mtRitaTitles.join("\n")}

Mwanakondoo wa Mungu:
${lambOfGod.join("\n")}

Majibu ya Kiongozi:
Kiongozi: ${leaderResponse.kiongozi}
Wote: ${leaderResponse.wote}

Sala ya Mwisho:
$closingPrayer

Kumbuka:
$extraNote
"""
    ];
  }
}
