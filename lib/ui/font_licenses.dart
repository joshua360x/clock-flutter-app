import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the OFL texts of the bundled fonts to Flutter's licences page, as
/// the SIL Open Font License requires when the fonts are distributed.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, asset) in const [
      ('Lora', 'assets/fonts/Lora-OFL.txt'),
      ('Inter', 'assets/fonts/Inter-OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString(asset));
    }
  });
}
