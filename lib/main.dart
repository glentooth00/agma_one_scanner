import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts from downloading fonts at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const AgmaScannerApp());
}