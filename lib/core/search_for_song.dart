import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ma_music_app/custom_objects/song.dart';

class Search {

  Future<List<Song>> searchForSong(String value) async {

    if(value.isEmpty) {
      return [];
    }

    String url = "https://www.youtube.com/results?search_query=$value";
    var resp = await http.Client().get(Uri.parse(url));

    print("request sent");

    if (resp.statusCode == 200) {
      return parseResponse(resp);
    } else {
      return [];
    }
  }

  List<Song> parseResponse(http.Response resp) {
    var document = html.parse(resp.body);
    var headElement = document.getElementsByTagName("body");
    var scriptElement = headElement[0].getElementsByTagName("script");
    var data = jsonDecode(scriptElement[13]
        .innerHtml
        .substring(20, scriptElement[13].innerHtml.length - 1));

    Map contents = data["contents"];
    Map twoColumnSearchResultsRenderer =
        contents["twoColumnSearchResultsRenderer"];
    Map primaryContents = twoColumnSearchResultsRenderer["primaryContents"];
    Map sectionListRenderer = primaryContents["sectionListRenderer"];
    List<dynamic> listContents = sectionListRenderer["contents"];
    Map itemSectionRenderer = listContents[0];
    Map _itemSectionRenderer = itemSectionRenderer["itemSectionRenderer"];
    List<dynamic> actualContents = _itemSectionRenderer["contents"];

    List<Song> results = [];

    for (var element in actualContents) {
      Map videoRenderer = element;

      if (element["videoRenderer"] == null) {
        continue;
      }
      Map videoData = videoRenderer["videoRenderer"];

      List<dynamic> videoThumbnails = videoData["thumbnail"]["thumbnails"];

      results.add(Song(
          id: videoData["videoId"],
          thumbnail360P: videoThumbnails[0]["url"],
          thumbnail720P: videoThumbnails.length>1 ? videoThumbnails[1]["url"] : "",
          title: videoData["title"]["runs"][0]["text"],
          duration: videoData["lengthText"]["simpleText"]));


    }

    return results;
  }
}
