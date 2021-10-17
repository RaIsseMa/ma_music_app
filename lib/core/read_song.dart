import 'package:http/http.dart' as http;
import 'package:ma_music_app/custom_objects/song.dart';
import 'dart:convert';

class ReadSong{

  Future<String> getSongSource(Song track) async{
    var url = "https://en.fetchfile.net/fetch/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D${track.id}";

    var resp = await http.post(Uri.parse(url));
    print("request sent ");
    if(resp.statusCode == 200){
      var results = jsonDecode(resp.body);

      if(results["status"] != null){
        if(results["status"]=="error"){
          return "error";
        }
        await Future.delayed(const Duration(milliseconds: 2000));
        print("request wait");
        return getSongSource(track);
      }

      Map data = results;
      List<dynamic> formats = data["formats"];
      String url = "";

      for(var format in formats){
        Map trackInfo = format;
        if(trackInfo["format"].toString().split("-")[1]==" audio only (tiny)" && trackInfo["ext"]=="webm"){
          url = trackInfo["url"];
        }

      }

      return url;
    }else{
      return "error";
    }
  }



}