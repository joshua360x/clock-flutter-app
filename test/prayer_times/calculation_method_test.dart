import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';

void main() {
  test('United States and Canada use ISNA', () {
    expect(CalculationMethods.forCountry('US'), CalculationMethods.isna);
    expect(CalculationMethods.forCountry('CA'), CalculationMethods.isna);
    expect(CalculationMethods.isna.id, 2);
  });

  test('country codes are matched case-insensitively', () {
    expect(CalculationMethods.forCountry(' us '), CalculationMethods.isna);
  });

  test('countries with their own authority get it', () {
    expect(CalculationMethods.forCountry('SA').id, 4);
    expect(CalculationMethods.forCountry('TR').id, 13);
    expect(CalculationMethods.forCountry('PK').id, 1);
  });

  test('unknown or missing country falls back to Muslim World League', () {
    expect(CalculationMethods.forCountry(null), CalculationMethods.muslimWorldLeague);
    expect(CalculationMethods.forCountry(''), CalculationMethods.muslimWorldLeague);
    expect(CalculationMethods.forCountry('GB'), CalculationMethods.muslimWorldLeague);
    expect(CalculationMethods.muslimWorldLeague.id, 3);
  });
}
