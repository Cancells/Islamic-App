class AzkarItem {
  final String id;
  final String arabic;
  final String transliteration;
  final String translation;
  final int count;
  final String reference;

  AzkarItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.count,
    required this.reference,
  });
}

class AzkarData {
  static final List<AzkarItem> morning = [
    AzkarItem(
      id: "m1",
      arabic: "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۚ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۚ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.",
      transliteration: "A'oodhu billaahi minash-Shaytaanir-Rajeem. Allaahu laa 'ilaaha 'illaa Huwal-Hayyul-Qayyoom, laa ta'khudhuhu sinatun wa laa nawm, lahu maa fis-samaawaati wa maa fil-'ardh, man dhal-ladhee yashfa'u 'indahu 'illaa bi'idhnih, ya'lamu maa bayna 'aydeehim wa maa khalfahum, wa laa yuheetoona bishay'im-min 'ilmihi 'illaa bimaa shaa'a, wasi'a kursiyyuhus-samaawaati wal-'ardh, wa laa ya'ooduhu hifdhuhumaa, wa Huwal-'Aliyyul-'Adheem.",
      translation: "Allahu! There is no deity but He, the Living, the Sustainer of all. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. (Ayat al-Kursi)",
      count: 1,
      reference: "Surah Al-Baqarah 2:255"
    ),
    AzkarItem(
      id: "m2",
      arabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ.",
      transliteration: "Allaahumma bika 'asbahnaa, wa bika 'amsaynaa, wa bika nahyaa, wa bika namootu wa 'ilaykan-nushoor.",
      translation: "O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening, by Your leave we live and by Your leave we die, and unto You is our resurrection.",
      count: 1,
      reference: "Al-Tirmidhi 3/142"
    ),
    AzkarItem(
      id: "m3",
      arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.",
      transliteration: "Allaahumma 'Anta Rabbee laa 'ilaaha 'illaa 'Anta, khalaqtanee wa 'anaa 'abduka, wa 'anaa 'alaa 'ahdika wa wa'dika mas-tata'tu, 'a'oodhu bika min sharri maa sana'tu, 'aboo'u laka bini'matika 'alayya, wa 'aboo'u bidhanbee faghfir lee fa'innahu laa yaghfirudh-dhunooba 'illaa 'Anta.",
      translation: "O Allah, You are my Lord, there is no deity but You. You created me and I am Your servant, and I am faithful to Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge before You Your favor upon me, and I acknowledge my sin, so forgive me, for indeed, no one forgives sins except You. (Sayyid al-Istighfar)",
      count: 1,
      reference: "Al-Bukhari 7/150 - Recited in the morning with conviction enters Paradise if dying before night."
    ),
    AzkarItem(
      id: "m4",
      arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.",
      transliteration: "Bismillaahil-ladhee laa yadhurru ma'as-mihi shay'un fil-'ardhi wa laa fis-samaa'i wa Huwas-Samee'ul-'Aleem.",
      translation: "In the Name of Allah, Who with His Name nothing can cause harm in the earth nor in the heavens, and He is the All-Hearing, the All-Knowing.",
      count: 3,
      reference: "Abu Dawud 4/323 - Nothing will harm whoever recites it 3 times."
    )
  ];

  static final List<AzkarItem> evening = [
    AzkarItem(
      id: "e1",
      arabic: "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۚ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۚ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.",
      transliteration: "A'oodhu billaahi minash-Shaytaanir-Rajeem. Allaahu laa 'ilaaha 'illaa Huwal-Hayyul-Qayyoom, laa ta'khudhuhu sinatun wa laa nawm, lahu maa fis-samaawaati wa maa fil-'ardh, man dhal-ladhee yashfa'u 'indahu 'illaa bi'idhnih, ya'lamu maa bayna 'aydeehim wa maa khalfahum, wa laa yuheetoona bishay'im-min 'ilmihi 'illaa bimaa shaa'a, wasi'a kursiyyuhus-samaawaati wal-'ardh, wa laa ya'ooduhu hifdhuhumaa, wa Huwal-'Aliyyul-'Adheem.",
      translation: "Allahu! There is no deity but He, the Living, the Sustainer of all. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. (Ayat al-Kursi)",
      count: 1,
      reference: "Surah Al-Baqarah 2:255"
    ),
    AzkarItem(
      id: "e2",
      arabic: "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ.",
      transliteration: "Allaahumma bika 'amsaynaa, wa bika 'asbahnaa, wa bika nahyaa, wa bika namootu wa 'ilaykal-maseer.",
      translation: "O Allah, by Your leave we have reached the evening and by Your leave we have reached the morning, by Your leave we live and by Your leave we die, and unto You is our return.",
      count: 1,
      reference: "Al-Tirmidhi 3/142"
    ),
    AzkarItem(
      id: "e3",
      arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.",
      transliteration: "A'oodhu bikalimaatillaahit-taammaati min sharri maa khalaq.",
      translation: "I seek refuge in the perfect words of Allah from the evil of what He has created.",
      count: 3,
      reference: "Al-Tirmidhi 3/187"
    )
  ];

  static final List<AzkarItem> postPrayer = [
    AzkarItem(
      id: "p1",
      arabic: "أَسْتَغْفِرُ اللهَ ، أَسْتَغْفِرُ اللهَ ، أَسْتَغْفِرُ اللهَ. اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.",
      transliteration: "Astaghfirullaah, Astaghfirullaah, Astaghfirullaah. Allaahumma 'Antas-Salaamu wa minkas-salaamu, tabaarakta yaa Dhal-Jalaali wal-'Ikraam.",
      translation: "I seek the forgiveness of Allah (three times). O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.",
      count: 1,
      reference: "Muslim 1/414"
    ),
    AzkarItem(
      id: "p2",
      arabic: "سُبْحَانَ اللهِ ، وَالْحَمْدُ للهِ ، وَاللهُ أَكْبَرُ.",
      transliteration: "Subhaanallaah, Walhamdulillaah, Wallaahu 'Akbar.",
      translation: "Glory be to Allah, Praise be to Allah, Allah is the Greatest. (Recited 33 times each, followed by: La ilaha illallahu wahdahu... to complete 100)",
      count: 33,
      reference: "Muslim 1/418"
    )
  ];

  static final List<AzkarItem> daily = [
    AzkarItem(
      id: "d1",
      arabic: "بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.",
      transliteration: "Bismillaahi, tawakkaltu 'alallaahi, wa laa hawla wa laa quwwata 'illaa billaah.",
      translation: "In the name of Allah, I place my trust in Allah, and there is no might or power except with Allah. (Dua when leaving home)",
      count: 1,
      reference: "Abu Dawud 4/325"
    ),
    AzkarItem(
      id: "d2",
      arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.",
      transliteration: "Rabbanaa 'aatinaa fid-dunyaa hasanatan wa fil-'Aakhirati hasanatan wa qinaa 'adhaaban-Naar.",
      translation: "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.",
      count: 1,
      reference: "Surah Al-Baqarah 2:201"
    )
  ];
}
