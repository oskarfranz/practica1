import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:p1/songFound.dart';

class Favs extends StatefulWidget {
  final List<Song> favs;
  Favs({Key? key, required this.favs}) : super(key: key);
  @override
  _Favs createState() => _Favs();
}

enum SingingCharacter { amazing, good, okay }

class _Favs extends State<Favs> {

  @override 
  void initState() {
    super.initState();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(top:60, left: 40),
                  icon: Icon(Icons.arrow_back_ios), 
                  onPressed: () =>{
                     Navigator.pop(context)
                  },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 62, left: 65),
                child: Text(
                  'Liked Songs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (widget.favs.length == 0)? 110: 20,),
          Text('${(widget.favs.length == 0)? 'No liked songs ':''}'),
          Expanded(
            child: 
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: widget.favs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                  padding: EdgeInsets.only(bottom:30, left: 30, right: 30), 
                  child: GestureDetector(
                    onTap: () => {
                      // print("Opensong"),
                      postAuddBase64(widget.favs.elementAt(index).sample)
                    },
                    child: Container(
                      height: 290,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              image: DecorationImage(
                                image: NetworkImage(widget.favs.elementAt(index).image),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(children: [
                                   IconButton(
                                    splashColor: Colors.transparent,
                                    onPressed: () => {
                                      // print('Unfav'),
                                      _showMyDialog(context, index)
                                    }, 
                                    icon: Icon(Icons.favorite, color: Colors.red,),
                                   ),

                                  ],
                                ),
                                SizedBox(height: 164,),
                                Container(
                                  width: 250,
                                  decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.only(topLeft:Radius.circular(10.0), topRight:Radius.circular(10.0), bottomRight:Radius.circular(10.0), bottomLeft:Radius.circular(10.0)),
                                    borderRadius: BorderRadius.all(Radius.circular(13)),
                                    color: Color.fromARGB(243, 100, 100, 100),
                                  ),                                
                                  child:
                                  Column(
                                    children: [
                                      SizedBox(height: 14,),
                                      Center(
                                        child: 
                                          Text(
                                            (widget.favs.elementAt(index).title.length > 14)? widget.favs.elementAt(index).title.substring(0,15): widget.favs.elementAt(index).title,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800
                                            ),
                                            )
                                        ),
                                      SizedBox(height: 3,),
                                      Center(child: Text(widget.favs.elementAt(index).artist)),
                                      SizedBox(height: 14,),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                              ],
                            ),
                          ), 
                        ],
                      ),
                    ),
                  )
                );
                }
              ),
          )
        ])
    );
  }
Widget _buildCupertinoAlertDialog(BuildContext context, int index) {
    return CupertinoAlertDialog(
      title: Text('Remove from favorites'),
      content:
          Text('¿Remove \'${widget.favs.elementAt(index).title}\' from your Liked Songs?'),
      actions: <Widget>[
        TextButton(
            child: Text("Aceptar"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Text Color
            ),
            onPressed: () {
              widget.favs.removeAt(index);
              setState(() {});

              Navigator.of(context).pop();
              if(widget.favs.length == 0){
                // print('sero');
                Navigator.of(context).pop();
              }
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

postAuddBase64(String base64Sample) async{
    // print(base64Sample);
    Uri url = Uri.parse('https://api.audd.io/');
    Object data = {
      'api_token': '3fd10d34f9bb0282753ac4846f6f58a3',
      // 'url': 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview118/v4/65/07/f5/6507f5c5-dba8-f2d5-d56b-39dbb62a5f60/mzaf_1124211745011045566.plus.aac.p.m4a',
      'audio': base64Sample,
      'return': 'spotify,apple_music',
    };

    var response = await http.post(url, body: data);
    final Map parsed = json.decode(response.body);
    parsed['from'] = 'favs';
    print(widget.favs);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  SongFound(response: parsed, favs: widget.favs)),
      ).then((value) => {
        setState(() => {}),
      });
  }
}
