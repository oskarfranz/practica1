import 'dart:convert';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:p1/favs.dart';
import 'package:p1/songFound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import './myprovider.dart'; 



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum SingingCharacter { amazing, good, okay }
late Map lastMatch;
var match = {'title':'No previous matches', 'artist':''};
class _HomePageState extends State<HomePage> {
  List<Song> favs = [];
  bool cancelled = false;
  final recorder = FlutterSoundRecorder();

  @override 
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose(){
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    // final mediaPermit = await Permission.mediaLibrary.request();

    if(status != PermissionStatus.granted /*|| mediaPermit != PermissionStatus.granted*/){
      print('No permissions aviable');
    }

    await recorder.openRecorder();
  }

  Future record() async{
    await recorder.startRecorder(
      toFile: 'test',
      );
  }

  Future stop() async{
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: '+ path);
    return audioFile;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text("Find a song", 
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600
              
              )
            ),
          ),
          SizedBox(height: 70,),
          Center(
            child: AvatarGlow(
              
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,  
                iconSize: 210,
                icon: CircleAvatar(
                  radius: 900,
                  backgroundColor: Colors.white,
                  child: Text((recorder.isRecording)? 'Listening...': 'Listen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                ),
                onPressed: () async {
                    var matchorg = {'title': match['title'], 'artist':match['artist']};
                    match['artist'] = '';
                    setState(() {});
                    
                    if(!recorder.isRecording){
                      context.read<MyProvider>().tfRecord();
                      await record();
                      setState(() {});

                      //POST REQUEST ANIMTION
                      var forward = true;
                      for(int i=0;i<16;i++){
                        
                        if(i==0){
                          match['title'] = '';
                        }
                        if(match['title'] == '...'){
                          forward = false;
                        }
                        if(match['title'] == ''){
                          forward = true;
                        }
                        if(forward == true){
                          match['title'] = match['title']! + '.';
                        }
                        else if(forward == false){
                          match['title'] = match['title']!.replaceFirst('.', '');
                        }
                        if(i==15){
                          match['title'] = '...';
                        }
                        setState(() {});
                        await Future.delayed(Duration(milliseconds: 300));

                      }

                      // await Future.delayed(Duration(milliseconds: 4800));
                      context.read<MyProvider>().tfRecord();
                      if(!cancelled){
                        final File recording = await stop();
                        await postAudd(recording, matchorg);
                        cancelled = false;
                        context.read<MyProvider>().startStop();
                      }
                      setState(() {});
                    }
                    else {
                      
                    }

                }
              ),
              startDelay: Duration(milliseconds: -10),
              duration: Duration(milliseconds: 1500),
              repeatPauseDuration: Duration(milliseconds: 0),
              repeat: true,
              animate: context.watch<MyProvider>().isRecording,
              endRadius: 150,
              glowColor: Colors.white,
            ),
          ),
          SizedBox(height: 10,),
          GestureDetector(
            onTap: () => {
              if(match['sample']!= null){
                postAuddBase64(match['sample']!),
              }
            },
            child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Color.fromARGB(97, 158, 158, 158),
                  borderRadius: BorderRadius.circular(13),

                ),
                child: Column(
                  children: [
                    SizedBox(height: 12,),
                    Text('Last match', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                    SizedBox(height: 5,),
                    Text('${match['title']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    SizedBox(height: 5,),
                    Text('${match['artist']}', style: TextStyle(fontSize: 15),),
                    
                    SizedBox(height: 15,),
                  ],
                ),
              ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 0.0, top:50),
                child: IconButton(
                  iconSize: 50,
                  icon: CircleAvatar(                  
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite, color: Colors.red,)
                  ),
                  onPressed: () =>{
                    // print(match['sample']),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Favs(favs: favs)),
                    )
                  }
                ),
              ),
            ],
          )
      ],)
    );
  }

  
  postAudd(File audio, Map matchbk) async {
    var fileContent;
    try{
      fileContent = audio.readAsBytesSync();
    }
    catch(e){
      print('Error recording audio: '+ e.toString())  ;  
    }
    var fileContentBase64 = base64.encode(fileContent); 

    Uri url = Uri.parse('https://api.audd.io/');
    Object data = {
      'api_token': '3fd10d34f9bb0282753ac4846f6f58a3',
      // 'url': 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview118/v4/65/07/f5/6507f5c5-dba8-f2d5-d56b-39dbb62a5f60/mzaf_1124211745011045566.plus.aac.p.m4a',
      'audio': fileContentBase64,
      'return': 'spotify,apple_music',
    };

    var response = await http.post(url, body: data);
    final Map parsed = json.decode(response.body);
    match['artist'] = '';
    setState(() {});

    print('Status: '+parsed.toString());

    if(parsed['status'] != 'error' && parsed['result'] != null){
      parsed['sample'] = fileContentBase64;
      match['sample'] = fileContentBase64;
      // print(parsed);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  SongFound(response: parsed, favs: this.favs)),
      );
      match['title'] = (parsed['result']['title'].length > 14)?'${parsed['result']['title']}'.substring(0,15): '${parsed['result']['title']}';
      match['artist'] = parsed['result']['artist'];
      
    }
    else {
      match['title'] = 'Didn´t found matches';
      match['artist'] = 'Ty again with higher volume';
      await Future.delayed(Duration(milliseconds: 3000));
      // print(match);
      match = {'title': matchbk['title'].toString(), 'artist': matchbk['artist'].toString()};
      setState(() {});
    }
  }

  postAuddBase64(String base64Sample) async{
    Uri url = Uri.parse('https://api.audd.io/');
    Object data = {
      'api_token': '3fd10d34f9bb0282753ac4846f6f58a3',
      // 'url': 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview118/v4/65/07/f5/6507f5c5-dba8-f2d5-d56b-39dbb62a5f60/mzaf_1124211745011045566.plus.aac.p.m4a',
      'audio': base64Sample,
      'return': 'spotify,apple_music',
    };

    var response = await http.post(url, body: data);
    final Map parsed = json.decode(response.body);
    parsed['from'] = 'home';

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  SongFound(response: parsed, favs: this.favs)),
      );
  }
}
