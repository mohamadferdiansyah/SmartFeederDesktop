import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:media_kit/media_kit.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'app/routes/app_pages.dart';
import 'app/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // <-- Tambahkan baris ini sebelum apapun yang pakai media_kit

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await initializeDateFormatting('id_ID', null);

  await DBHelper.database;
  // await DBHelper.injectDummyData(); // Panggil seperti ini // <-- panggil di sini, lalu hapus setelah selesai tes

  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setFullScreen(true);
    await windowManager.center();
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });
  Get.put(DataController());
  runApp(SmartFeederApp());
}

class SmartFeederApp extends StatelessWidget {
  const SmartFeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartFeeder Desktop',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: AppPages.pages,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: const Color.fromARGB(255, 213, 79, 79),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
    );
  }
}
