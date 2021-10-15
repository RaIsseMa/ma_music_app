import 'package:flutter/material.dart';
import 'package:ma_music_app/core/search_for_song.dart';
import 'package:ma_music_app/custom_objects/song.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var searchQueryController = TextEditingController();

  List<Song> listOfSongs = [];

  void searchSong() async{
    var results = await Search().searchForSong(searchQueryController.text);
    setState(() {
      listOfSongs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff272435),
        elevation: 0,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xff0e0b1e),
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: Center(
            child: TextField(
              controller: searchQueryController,
              style: const TextStyle(
                color: Colors.white
              ),
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search,color: Colors.white,),
                  onPressed: searchSong,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear,color: Colors.white,),
                  onPressed: (){
                  },
                ),
                  hintText: 'Search...',
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Roboto"
                ),
                border: InputBorder.none,

              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xff272435)
            ),
          ),
          ListView.builder(
            itemCount: listOfSongs.length,
            itemExtent: 80.0,
            itemBuilder: (context,index){
              return  Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 4.0),
                child: Card(
                  elevation: 0,
                  color: const Color(0xff272435),
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    onTap: (){},
                    splashColor: Colors.black.withAlpha(30),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xff272435)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 5,),
                                Image.network(
                                  listOfSongs[index].thumbnail360P,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 5,),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            listOfSongs[index].title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            )
                                        ),
                                        const SizedBox(height: 5,),
                                        Text(
                                          listOfSongs[index].duration,
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontFamily: 'Roboto',
                                              fontSize: 10
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
