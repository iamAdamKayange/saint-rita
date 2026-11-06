import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';

class MtakatifuRitaSikuPage extends StatelessWidget {
  const MtakatifuRitaSikuPage({super.key});

  final String ritaStory = """
Mtakatifu Rita alizaliwa mwaka 1381 huko Kashia (Italia). Alibatizwa akaitwa Margarita, tangu utoto wake aliazimia kumtumikia Mungu katika Konventi ya Mt. Austino huko Kashia, lakini alipokuwa na umri wa miaka Kumi na miwili, alilazimishwa na Wazazi wake na kuolewa na Kijana mmoja tajiri. Mume wake alikuwa mtu katili sana. Alikaa naye kwa miaka Kumi na minane, alimvumilia mumewe na daima hakuchoka kumwombea yeye na wanawe. Katika mwaka wa Kumi na Nane wa ndoa yake Mume wake aliuawa katika ugomvi. Watoto wake wawili wa kiume walipokua walinuia kulipiza kisasi kwa kifo cha Baba yao, jambo hilo liliuongeza uchungu wa Rita, mama yao. Aliomba sana ili wasilifanye hilo jambo waliloliazimia. Sala yake ilisikilizwa na Mungu, wanawe hao waliugua kiasi cha kutoweza kulipa kisasi. Baadaye walikufa katika hali ya neema, tena walimsamehe aliyemwua Baba yao. Baada kifo cha wanawe wawili, Rita alibaki peke yake basi aliamua kuingia katika Konventi ya Mt Augustino Kashia, akaanza maisha ya Kitawa kama ilivyokuwa amenuia tangu awali. Katika Konventi aliwatii wakuu wake kama ilivyozoea alipokuwa bado msichana na mama wa nyumbani. Alionyesha huruma na wema kwa jirani hasa kwa Watawa wenzake waliokuwa wagonjwa. Kwa sala zake aliwaongoa Wakristu wazembe, na wengi walitubu kwa kuona mifano yake. Tangu utoto wake alikuwa na Ibada maalumu kwa mateso ya Bwana wetu Yesu Kristu. Pengine akiyatafakari Roho yake ulishikwa kabisa na mambo ya mbinguni, kiasi kwamba viongo vyake vililegea, na fahamu ikampotea. Siku moja aliposikia hotuba kuhusu taji la miiba la Yesu, alijiona kana kwamba alikuwa amelivaa taji hilo. Kweli baadaye alipata donda kubwa kwenye paji la uso. Kwa sababu ya donda hilo alitengwa na wenzake. Inasemakana kwamba lilipona mwaka 1450 alipona kwenda kuhiji Roma, lakini baada ya kuhiji lilimrudia tena. Mwisho Rita aliugua sana, na alifariki Tarehe 22 mei, mwaka 1457. Na akatangwa kuwa Mtakatifu mwaka 1900. Watu wengi wanaomba msaada wake hasa katika shida kubwa sana. Haya ndio maisha ya Mtakatifu Rita wa Kashia.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maisha ya Mt. Rita"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        //padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mtakatifu Rita wa Kashia",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                ritaStory,
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
