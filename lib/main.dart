import 'package:flutter/material.dart';
import 'package:storemate/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cirxkvdkubwrxbkoygwt.supabase.co',
    anonKey: 'sb_publishable_lLD1zRanLKX6eoKpfXO4Hg_fO26pT8u',
  );

  runApp(
    const StoreMateApp(),
  );
}