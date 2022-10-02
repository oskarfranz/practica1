import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'myprovider.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:provider/provider.dart';
// import '/myprovider.dart';

final List<String> songs = <String>['After Hours', 'Neverita', 'La que se fue'];
  // final List<int> favs = <int>[];

class SongFound extends StatefulWidget {
  const SongFound({super.key, required this.favs, required this.response});
  final Map response;
  final List<Song> favs;

  @override
  State<SongFound> createState() => _SongFoundState();
}

class _SongFoundState extends State<SongFound> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            Row(
            children: [
              // SizedBox(height: 60,),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,  
                alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(top:60, left: 40),
                  icon: Icon(Icons.arrow_back_ios), 
                  onPressed: () =>{
                     Navigator.pop(context)
                  },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 62, left: 62),
                child: Text(
                  (this.widget.response['from'] == 'home')? 'Last Match':(this.widget.response['from'] == 'favs')? 'Liked Song': 'Match Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,  
                alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(top:60, left: 77),
                  icon: Icon(
                    Icons.favorite,
                    color: (isLiked())? Colors.red: Colors.white,
                  ), 
                  onPressed: () =>{
                    // print('fav'),
                    _showMyDialog(context, 0),
                  },
              ),
            ],
          ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(image: NetworkImage('${this.widget.response['result']['spotify']['album']['images'][0]['url']}')),
              ),
            ),
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Color.fromARGB(97, 158, 158, 158),
                borderRadius: BorderRadius.circular(13),

              ),
              child: Column(
                children: [
                  SizedBox(height: 12,),
                  Text((this.widget.response['result']['title'].length > 14)?'${this.widget.response['result']['title']}'.substring(0,15): '${this.widget.response['result']['title']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(height: 5,),
                  Text('${this.widget.response['result']['artist']}'+' - '+ '${this.widget.response['result']['apple_music']['albumName']}'.substring(0,15)),
                  SizedBox(height: 15,),
                ],
              ),
            ),
            SizedBox(height: 50,),
            Text("Listen in"),
            Padding(
              padding: const EdgeInsets.only(left:8.0, right:8.0, top:15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.apple), 
                    iconSize: 70, 
                    onPressed: () {
                      
                      _launchUrl('${this.widget.response['result']['apple_music']['url']}');
                    }
                  ),
                  IconButton(
                    icon: Image.asset('assets/images/Spotify.png'), 
                    iconSize: 50, 
                    onPressed: () {
                      
                      _launchUrl('${this.widget.response['result']['spotify']['album']['external_urls']['spotify']}');
                    }
                  ),
                  // IconButton(icon: Icon(Icons.apple), iconSize: 70, onPressed: () {},),
                  // IconButton(icon: Icon(Icons.apple), iconSize: 70, onPressed: () {},),
                  // IconButton(icon: Image.asset('assets/images/spotifyIcon.png'), iconSize: 70, onPressed: () {},),

                ],
              ),
            )
          ],
        )
      );
      
  }

  Widget _buildCupertinoAlertDialog(BuildContext context, int index) {
    return CupertinoAlertDialog(
      title: Text(!isLiked()? 'Add to favorites':'Remove from favorites'),
      content:
          Text('¿${!isLiked()?'Add':'Remove'} \'${this.widget.response['result']['title']}\' ${!isLiked()?'to':'from'} your Liked Songs?'),
      actions: <Widget>[
        TextButton(
            child: Text("Aceptar"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Text Color
            ),
            onPressed: () {
              if(!isLiked()){
                Song newfav = Song('${this.widget.response['result']['title']}', '${this.widget.response['result']['apple_music']['albumName']}','${this.widget.response['result']['artist']}','${this.widget.response['result']['spotify']['album']['images'][0]['url']}', '${this.widget.response['sample']}'); 
                this.widget.favs.add(newfav);
              }
              else{
                removeFav();
              }
              setState(() {});
            //  print(this.favs.length);
             Navigator.of(context).pop();
            //  Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => Favs(favs: this.widget.favs)),
            //   );
            //  print(favs.elementAt(0).artist);

            }),

        TextButton(
            child: Text("Cancelar"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Text Color
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  Future<void> _showMyDialog(BuildContext context, int index) async {
      return showCupertinoDialog<void>(
        context: context,
        builder: (_) => _buildCupertinoAlertDialog(context, index),
      );
  }

  Future<void> _launchUrl(strUrl) async {
    final Uri url = Uri.parse(strUrl);
    if (!await launchUrl(url)) {
     throw 'Could not launch $url';
    }
  }

  isLiked() {
    var title = widget.response['result']['title'];

    for(int i=0;i<this.widget.favs.length;i++){
      if(this.widget.favs[i].title== title){
        return true;
      }
    }
    return false;

  }

  removeFav() {
    var title = widget.response['result']['title'];

    for(int i=0;i<this.widget.favs.length;i++){
      if(this.widget.favs[i].title== title){
        this.widget.favs.removeAt(i);
      }
    }
  }
}


class Song {
  String title = '';
  String album = '';
  String artist = '';
  String image = '';
  String sample = '';

  Song(String title, String album, String artist, String image, String sample) {
    this.title = title;
    this.album = album;
    this.artist = artist;
    this.image = image;
    this.sample = sample;
  }
}