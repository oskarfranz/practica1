// import 'package:p11/match_song.dart';

import './home_page.dart';
import 'package:flutter/material.dart';
import './myprovider.dart';
import 'package:provider/provider.dart';




void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicMatch',
      theme: ThemeData.dark(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MyProvider>(create: (_) => MyProvider()),
        ],
        child: HomePage(),
)
      
    );
  }
}