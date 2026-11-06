// To parse this JSON data, do
//
//     final novenaDailyPrayer = novenaDailyPrayerFromMap(jsonString);

import 'dart:convert';

NovenaDailyPrayer novenaDailyPrayerFromMap(String str) =>
    NovenaDailyPrayer.fromMap(json.decode(str));

String novenaDailyPrayerToMap(NovenaDailyPrayer data) =>
    json.encode(data.toMap());

class NovenaDailyPrayer {
  List<Novena> novena;

  NovenaDailyPrayer({required this.novena});

  factory NovenaDailyPrayer.fromMap(Map<String, dynamic> json) =>
      NovenaDailyPrayer(
        novena: json["novena"] != null
            ? List<Novena>.from(json["novena"].map((x) => Novena.fromMap(x)))
            : [],
      );

  Map<String, dynamic> toMap() => {
    "novena": List<dynamic>.from(novena.map((x) => x.toMap())),
  };
}

class Novena {
  int day;
  String title;
  String opening;
  String invocation;
  List<String> mainPrayer;
  String personalIntentionInstruction;
  List<String> praises;
  Repetitions repetitions;
  List<String> miraclesList;
  List<String> acclamations;
  String doxology;
  LeaderResponse leaderResponse;
  String closingPrayer;
  String extraNote;

  Novena({
    required this.day,
    required this.title,
    required this.opening,
    required this.invocation,
    required this.mainPrayer,
    required this.personalIntentionInstruction,
    required this.praises,
    required this.repetitions,
    required this.miraclesList,
    required this.acclamations,
    required this.doxology,
    required this.leaderResponse,
    required this.closingPrayer,
    required this.extraNote,
  });

  // Updated fromMap with null safety
  factory Novena.fromMap(Map<String, dynamic> json) => Novena(
    day: json["day"] ?? 0,
    title: json["title"] ?? "",
    opening: json["opening"] ?? "",
    invocation: json["invocation"] ?? "",
    mainPrayer: json["main_prayer"] != null
        ? List<String>.from(json["main_prayer"].map((x) => x))
        : [],
    personalIntentionInstruction: json["personal_intention_instruction"] ?? "",
    praises: json["praises"] != null
        ? List<String>.from(json["praises"].map((x) => x))
        : [],
    repetitions: Repetitions.fromMap(json["repetitions"] ?? {}),
    miraclesList: json["miracles_list"] != null
        ? List<String>.from(json["miracles_list"].map((x) => x))
        : [],
    acclamations: json["acclamations"] != null
        ? List<String>.from(json["acclamations"].map((x) => x.toString()))
        : [],
    doxology: json["doxology"] ?? "",
    leaderResponse: LeaderResponse.fromMap(json["leader_response"] ?? {}),
    closingPrayer: json["closing_prayer"] ?? "",
    extraNote: json["extra_note"] ?? "",
  );

  Map<String, dynamic> toMap() => {
    "day": day,
    "title": title,
    "opening": opening,
    "invocation": invocation,
    "main_prayer": List<dynamic>.from(mainPrayer.map((x) => x)),
    "personal_intention_instruction": personalIntentionInstruction,
    "praises": List<dynamic>.from(praises.map((x) => x)),
    "repetitions": repetitions.toMap(),
    "miracles_list": List<dynamic>.from(miraclesList.map((x) => x)),
    "acclamations": List<dynamic>.from(acclamations),
    "doxology": doxology,
    "leader_response": leaderResponse.toMap(),
    "closing_prayer": closingPrayer,
    "extra_note": extraNote,
  };
}

enum Acclamation {
  HISPANIA_WANAKUTANGAZA_KUWA_MTAKATIFU_WA_MAMBO_YALIYOSHINDIKANA,
  KASHIA_HUTUKUSA_JINA_LAKO,
  KASHIA_HUTUKUZA_JINA_LAKO,
  WATU_WENGI_WANAIMBA_FADHILI_ZAKO,
  WATU_WENGI_WANAIMBA_SIFA_ZAKO,
}

// Enum mapping
final acclamationValues = EnumValues({
  "Hispania wanakutangaza kuwa Mtakatifu wa mambo yaliyoshindikana.":
      Acclamation
          .HISPANIA_WANAKUTANGAZA_KUWA_MTAKATIFU_WA_MAMBO_YALIYOSHINDIKANA,
  "Kashia hutukusa jina lako.": Acclamation.KASHIA_HUTUKUSA_JINA_LAKO,
  "Kashia hutukuza jina lako.": Acclamation.KASHIA_HUTUKUZA_JINA_LAKO,
  "Watu wengi wanaimba fadhili zako.":
      Acclamation.WATU_WENGI_WANAIMBA_FADHILI_ZAKO,
  "Watu wengi wanaimba sifa zako.": Acclamation.WATU_WENGI_WANAIMBA_SIFA_ZAKO,
});

class LeaderResponse {
  String kiongozi;
  String wote;

  LeaderResponse({required this.kiongozi, required this.wote});

  factory LeaderResponse.fromMap(Map<String, dynamic> json) => LeaderResponse(
    kiongozi: json["kiongozi"] ?? "",
    wote: json["wote"] ?? "",
  );

  Map<String, dynamic> toMap() => {"kiongozi": kiongozi, "wote": wote};
}

class Repetitions {
  int babaYetu;
  int salamuMaria;
  int atukuzweBaba;

  Repetitions({
    required this.babaYetu,
    required this.salamuMaria,
    required this.atukuzweBaba,
  });

  factory Repetitions.fromMap(Map<String, dynamic> json) => Repetitions(
    babaYetu: json["baba_yetu"] ?? 3,
    salamuMaria: json["salamu_maria"] ?? 3,
    atukuzweBaba: json["atukuzwe_baba"] ?? 3,
  );

  Map<String, dynamic> toMap() => {
    "baba_yetu": babaYetu,
    "salamu_maria": salamuMaria,
    "atukuzwe_baba": atukuzweBaba,
  };
}

Novena getTodayDayObject(NovenaDailyPrayer data, int day) {
  if (day < 1) day = 1;
  if (day > data.novena.length) day = data.novena.length;
  return data.novena[day - 1]; // index 0–8 kwa sababu list ina 9 items
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
