import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ma_music_app/core/search_for_song.dart';
import 'package:ma_music_app/custom_objects/song.dart';
import 'package:ma_music_app/core/read_song.dart';
import 'package:async/async.dart';
import 'package:ma_music_app/resources/custom_colors.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ma_music_app/custom_objects/track_player_status.dart';
import 'package:get_it/get_it.dart';
import 'package:ma_music_app/services/service_locator.dart';
import 'package:ma_music_app/view_models/search_page_vm.dart';


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

  var viewModel = getIt<SearchPageViewModel>();
  var searchClass = Search();

  var searchQueryController = TextEditingController();

  List<Song> listOfSongs = [];

  Song? currentPlayingSong;

  var isRefreshLoadNeeded = false;
  var storeSearchQuery = "";
  var isLoading = false;
  var isTrackReady = false;
  var isTrackUrlLoading = false;

  var panelOpacity = 0.0;

  String? changingPosition;

  double? _slider;

  //Audio settings


  void getTrackUrl(Song track) async{
    var url = await ReadSong().getSongSource(track);
    isTrackUrlLoading = false;
    if(url == ""){
      return;
    }

    print("song url = $url");

    currentPlayingSong = track;
    panelOpacity = 1.0;
    _slider = 0;
    setState((){});

    var trackInfo = {
      "id":url,
      "title":currentPlayingSong!.title,
      "thumbnail":Uri.parse(currentPlayingSong!.thumbnail360P),
      "duration":Duration(
        minutes: int.parse(currentPlayingSong!.duration.split(":")[0]),
        seconds: int.parse(currentPlayingSong!.duration.split(":")[1])
      )
    };

    viewModel.setAudioUrl(url,trackInfo);

    /*setState(() {
      playerStatus = PlayerStatus.buffering;
    });
    currentPlayingSong!.setUrl(url);
    await audioPlayer.setUrl(url);
    setState((){});
    isTrackPlaying = true;
    await audioPlayer.play();*/
  }

  loadData() async{
    if(searchQueryController.text.isEmpty){
      return;
    }
    setState(() {
      isLoading = true;
    });
    listOfSongs = await searchClass.searchForSong(searchQueryController.text);
    setState(() {
      isLoading = false;
    });

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
                loadData();
              },
              controller: searchQueryController,
              style: const TextStyle(
                color: Colors.white
              ),
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search,color: Colors.white,),
                  onPressed: (){
                    isRefreshLoadNeeded = true;
                    setState(() {

                    });
                  },
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
          isTrackUrlLoading? horizontalProgress() : Container(),
          loadSearchResult(), //Search results
          bottomPanel(),
        ],
      ),
    );
  }

  Widget horizontalProgress(){
    return const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Color(0xffff2851)),
      backgroundColor: Color(0xff272435),
    );
  }

  Widget loadSearchResult(){

    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: Color(0xff272435),
          valueColor: AlwaysStoppedAnimation(Color(0xffff2851)),
        ),
      );
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
          decoration: const BoxDecoration(
              color: Color(0xff272435)
          ),
        ):
        listItem(index);
      },
    );

  }

  String _formatDuration(Duration? d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }
  
  Widget bottomPanel(){
    return AnimatedOpacity(
      opacity: panelOpacity,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInToLinear,
      child: ValueListenableBuilder<bool>(
        valueListenable: viewModel.isTrackPlaying,
        builder: (context,isTrackPlaying,_){
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
                        child: songProgress(context,isTrackPlaying),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
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
                            actionPlay(isTrackPlaying),
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
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
      ),
    );
  }

  Widget songProgress(BuildContext context,bool isTrackPlaying){
    var durationTextStyle = const TextStyle(color: Colors.white,fontFamily: 'Roboto');
    var trackDuration = viewModel.getTrackDuration();
    return ValueListenableBuilder(
      valueListenable: viewModel.trackPosition,
      builder: (context,position,_) {
        if(viewModel.getTrackDuration() != null){
          _slider =
              (position as Duration).inMilliseconds / viewModel.getTrackDuration()!.inMilliseconds;
          if (_slider! > 1.0) {
            _slider = 1.0;
          }
        }
        return Row(
          children: [
            Text(
              changingPosition != null ? changingPosition! :_formatDuration(position as Duration),
              style: durationTextStyle,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbColor: accentColor,
                      overlayColor: accentColor,
                      thumbShape: const RoundSliderThumbShape(
                          disabledThumbRadius: 5,
                          enabledThumbRadius: 5
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: Colors.grey[500]
                  ),
                  child: Slider(
                    value: _slider??0,
                    onChanged: (value){
                      setState(() {
                        _slider = value;

                        if(trackDuration != null){
                          var msec = Duration(
                              milliseconds: (trackDuration.inMilliseconds * value).round()
                          );
                          changingPosition = _formatDuration(msec);
                        }
                      });
                    },
                    onChangeEnd: (value){
                      if(trackDuration != null){
                        changingPosition = null;
                        var msec = Duration(
                            milliseconds: (trackDuration.inMilliseconds * value).round()
                        );
                        viewModel.seek(msec);
                        if(isTrackPlaying) {
                        viewModel.playTrack();
                        }
                      }
                    },
                    onChangeStart: (value){
                      viewModel.tempPause();
                    },
                  ),
                ),
              ),
            ),
            Text(
              currentPlayingSong == null ? "--:--":currentPlayingSong!.duration,
              style: durationTextStyle,
            )
          ],
        );
      }
    );
  }

  Widget listItem(int index){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 4.0),
      child: Card(
        elevation: 0,
        color: backgroundColor,
        child: Material(
          color: backgroundColor,
          child: InkWell(
            onTap: () {
              setState(() {
                isTrackUrlLoading = true;
                viewModel.pauseTrack();
              });
              getTrackUrl(listOfSongs[index]);
            },
            splashColor: darkBackgroundColor.withAlpha(60),
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

  Widget actionPlay(bool isTrackPlaying){

    return ValueListenableBuilder<PlayerStatus>(
      valueListenable: viewModel.playerStatus,
      builder: (context,playerStatus,_){
        if(playerStatus == PlayerStatus.buffering){
          return const Padding(
            padding: EdgeInsets.all(14.0),
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xff272435),
                valueColor: AlwaysStoppedAnimation(Color(0xffff2851)),
              ),
            ),
          );
        }

        return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              primary: accentColor,
            ),
            onPressed: (){
              print("             button play tap");
              viewModel.toggleTrack();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isTrackPlaying? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ));
      }
    );


  }

}

