class PrayerTimeData {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunset;
  final String imsak;
  final String gregorianDate;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;

  PrayerTimeData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunset,
    required this.imsak,
    required this.gregorianDate,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
  });

  factory PrayerTimeData.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    
    return PrayerTimeData(
      fajr: timings['Fajr'] as String,
      sunrise: timings['Sunrise'] as String,
      dhuhr: timings['Dhuhr'] as String,
      asr: timings['Asr'] as String,
      maghrib: timings['Maghrib'] as String,
      isha: timings['Isha'] as String,
      sunset: timings['Sunset'] as String,
      imsak: timings['Imsak'] as String,
      gregorianDate: date['readable'] as String,
      hijriDate: "${hijri['day']} ${hijri['month']['en']} ${hijri['year']}",
      hijriMonth: hijri['month']['en'] as String,
      hijriYear: hijri['year'] as String,
    );
  }
}
