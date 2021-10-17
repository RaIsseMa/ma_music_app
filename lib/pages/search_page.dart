import 'dart:ui';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:ma_music_app/core/search_for_song.dart';
import 'package:ma_music_app/custom_objects/song.dart';
import 'package:ma_music_app/core/read_song.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var searchQueryController = TextEditingController();

  List<Song> listOfSongs = [];

  Song? currentPlayingSong;

  var audioManager = AudioManager.instance;

  double _slider = 0;

  void searchSong() async{

    setState(() {

    });
  }

  void getTrackUrl(Song track) async{
    var url = await ReadSong().getSongSource(track);
    if(url == ""){
      return;
    }

    currentPlayingSong = track;
    currentPlayingSong!.setUrl(url);

    audioManager.start(
        url,
        currentPlayingSong!.title,
        desc: "song",
        cover: currentPlayingSong!.thumbnail360P)
    .then((err) => print(err));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
              textInputAction: TextInputAction.search,
              onSubmitted: (value){
                setState(() {
                  //Search().searchForSong(value);
                });
              },
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
          loadSearchResult(), //Search results
          bottomPanel()
        ],
      ),
    );
  }

  Widget loadSearchResult(){
    return FutureBuilder(
      future: Search().searchForSong(searchQueryController.text),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xff272435),
                valueColor: AlwaysStoppedAnimation(Color(0xffff2851)),
              ),
            );
          }
          if(snapshot.hasError){
            return  Center(
              child:Text(
                "an error occurred while loading results",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Roboto',
                  fontSize: 10
                ),
              )
            );
          }
          if(snapshot.data != null){
            listOfSongs = snapshot.data as List<Song>;
          }
          if(listOfSongs.isEmpty){
            return Container();
          }
          return ListView.builder(
            itemCount: listOfSongs.length+2,
            itemExtent: 80.0,
            itemBuilder: (context,index){
              return index>=listOfSongs.length?
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff272435)
                    ),
                  ):
                  listItem(index);
            },
          );
        }
    );
  }

  Widget bottomPanel(){
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaY: 10.0,
            sigmaX: 10.0
          ),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: Colors.white
                            ),
                            onPressed: (){},
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        child: Center(
                          child: IconButton(
                            onPressed: (){
                              audioManager.playOrPause();
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                            padding: const EdgeInsets.all(0.0),
                          )
                        ),
                      ),
                      CircleAvatar(
                        child: Center(
                          child: IconButton(
                            onPressed: (){},
                            icon: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listItem(int index){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 4.0),
      child: Card(
        elevation: 0,
        color: const Color(0xff272435),
        child: Material(
          color: const Color(0xff272435),
          child: InkWell(
            onTap: () async{
              getTrackUrl(listOfSongs[index]);
            },
            splashColor: const Color(0xff0e0b1e).withAlpha(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 5,),
                      FadeInImage(
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          placeholder: const AssetImage('assets/music_placeholder.png'),
                          image: NetworkImage(
                            listOfSongs[index].thumbnail360P,
                          )),
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
  }

  void setupAudio(){

  }
}
