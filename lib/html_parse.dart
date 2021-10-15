import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomParser{

  void getResponse(String url) async{
    var resp = await http.Client().get(Uri.parse(url));
    print("request sent");

    if(resp.statusCode == 200){
      var document = html.parse(resp.body);
      var headElement = document.getElementsByTagName("body");
      var scriptElement = headElement[0].getElementsByTagName("script");
      var data = jsonDecode(scriptElement[13].innerHtml.substring(20,scriptElement[13].innerHtml.length-1));

      Map contents = data["contents"];
      Map twoColumnSearchResultsRenderer = contents["twoColumnSearchResultsRenderer"];
      Map primaryContents = twoColumnSearchResultsRenderer["primaryContents"];
      Map sectionListRenderer = primaryContents["sectionListRenderer"];
      List<dynamic> listContents = sectionListRenderer["contents"];
      Map itemSectionRenderer = listContents[0];
      Map _itemSectionRenderer = itemSectionRenderer["itemSectionRenderer"];
      List<dynamic> actualContents = _itemSectionRenderer["contents"];
      Map videoRenderer = actualContents[0];
      Map videoData = videoRenderer["videoRenderer"];
      //print("vid_ren = $videoData");
      print("videoId = ${videoData["videoId"]} // video duration = ${videoData["lengthText"]["simpleText"]}");
    }else{
      print("error");
    }
  }



}