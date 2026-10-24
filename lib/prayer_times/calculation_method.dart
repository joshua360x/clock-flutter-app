/// An AlAdhan calculation method (the `method` query parameter).
class CalculationMethod {
  const CalculationMethod(this.id, this.name);

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is CalculationMethod && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($id)';
}

/// How Asr is calculated (AlAdhan `school`): shadow length 1x or 2x.
enum AsrSchool {
  standard(0),
  hanafi(1);

  const AsrSchool(this.apiValue);
  final int apiValue;
}

/// Methods AlAdhan offers, by id (https://aladhan.com/calculation-methods).
abstract final class CalculationMethods {
  static const karachi = CalculationMethod(
    1,
    'University of Islamic Sciences, Karachi',
  );
  static const isna = CalculationMethod(2, 'Islamic Society of North America');
  static const muslimWorldLeague = CalculationMethod(3, 'Muslim World League');
  static const ummAlQura = CalculationMethod(
    4,
    'Umm Al-Qura University, Makkah',
  );
  static const egypt = CalculationMethod(
    5,
    'Egyptian General Authority of Survey',
  );
  static const tehran = CalculationMethod(
    7,
    'Institute of Geophysics, University of Tehran',
  );
  static const gulf = CalculationMethod(8, 'Gulf Region');
  static const kuwait = CalculationMethod(9, 'Kuwait');
  static const qatar = CalculationMethod(10, 'Qatar');
  static const singapore = CalculationMethod(
    11,
    'Majlis Ugama Islam Singapura, Singapore',
  );
  static const france = CalculationMethod(
    12,
    'Union Organization Islamic de France',
  );
  static const turkey = CalculationMethod(
    13,
    'Diyanet İşleri Başkanlığı, Turkey',
  );
  static const russia = CalculationMethod(
    14,
    'Spiritual Administration of Muslims of Russia',
  );
  static const dubai = CalculationMethod(16, 'Dubai');
  static const malaysia = CalculationMethod(
    17,
    'Jabatan Kemajuan Islam Malaysia (JAKIM)',
  );
  static const tunisia = CalculationMethod(18, 'Tunisia');
  static const algeria = CalculationMethod(19, 'Algeria');
  static const indonesia = CalculationMethod(
    20,
    'Kementerian Agama Republik Indonesia',
  );
  static const morocco = CalculationMethod(21, 'Morocco');
  static const portugal = CalculationMethod(
    22,
    'Comunidade Islamica de Lisboa',
  );
  static const jordan = CalculationMethod(
    23,
    'Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan',
  );

  /// Used where a country has no authority of its own in AlAdhan.
  static const fallback = muslimWorldLeague;

  static const _byCountry = <String, CalculationMethod>{
    'US': isna,
    'CA': isna,
    'PK': karachi,
    'IN': karachi,
    'BD': karachi,
    'AF': karachi,
    'SA': ummAlQura,
    'EG': egypt,
    'IR': tehran,
    'BH': gulf,
    'OM': gulf,
    'KW': kuwait,
    'QA': qatar,
    'SG': singapore,
    'FR': france,
    'TR': turkey,
    'RU': russia,
    'AE': dubai,
    'MY': malaysia,
    'TN': tunisia,
    'DZ': algeria,
    'ID': indonesia,
    'MA': morocco,
    'PT': portugal,
    'JO': jordan,
  };

  /// The authority for [isoCountryCode] (ISO 3166-1 alpha-2, any case),
  /// or [fallback] when the country is unknown or has no authority listed.
  static CalculationMethod forCountry(String? isoCountryCode) =>
      _byCountry[isoCountryCode?.trim().toUpperCase()] ?? fallback;
}
