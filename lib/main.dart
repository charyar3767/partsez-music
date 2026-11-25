import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/library_screen.dart';
import 'services/duzeltme_service.dart';
import 'services/favorit_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.partsez.music.channel.audio',
    androidNotificationChannelName: 'Partsez Music',
    androidNotificationOngoing: true,
  );
  await FavoritHyzmat.instance.yukle();
  await DuzeltmeHyzmat.instance.yukle();
  runApp(const PartsezMusicApp());
}

class PartsezMusicApp extends StatelessWidget {
  const PartsezMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Partsez Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Renkler.fon,
        colorScheme: const ColorScheme.dark(
          primary: Renkler.esasy,
          secondary: Renkler.goshmaca,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Renkler.esasy,
          thumbColor: Renkler.goshmaca,
          inactiveTrackColor: Color(0x33FFFFFF),
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}
