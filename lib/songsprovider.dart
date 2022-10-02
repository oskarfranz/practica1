import 'package:flutter/foundation.dart';

class SongProvider with ChangeNotifier {

  final List<String> _songs = <String>['After Hours', 'Neverita', 'La que se fue'];
  final List<String> _artists = <String>['The weekend', 'Bad Bunny', 'Elefante'];
  final List<String> _images = <String>['https://img.europapress.es/fotoweb/fotonoticia_20200320173804_1200.jpg', 'https://i.scdn.co/image/ab67706f0000000395c94a38840f54b062b8739d', 'https://i.scdn.co/image/ab6761610000e5eba40f5812b577a0528b459e70'];
  final List<int> _favs = <int>[];

  List<String> get songs => _songs;
  List<String> get artists => _artists;
  List<String> get images => _images;
  List<int> get favs => _favs;
  
}