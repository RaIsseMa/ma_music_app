import 'package:get_it/get_it.dart';
import 'package:flutter/cupertino.dart';
import 'package:ma_music_app/custom_objects/track_player_status.dart';
import 'package:ma_music_app/services/audio_handler.dart';
import 'package:ma_music_app/services/service_locator.dart';
import 'package:audio_service/audio_service.dart';

class SearchPageViewModel{

  final isTrackPlaying = ValueNotifier(false);
  final isTrackReady = ValueNotifier(false);
  final playerStatus = ValueNotifier(PlayerStatus.none);
  final isTrackUrlLoading = ValueNotifier(false);

  final audioHandler = getIt<AudioHandler>();

  final trackPosition = ValueNotifier<Duration>(const Duration(milliseconds: 0));

  SearchPageViewModel(){
    _listenToCurrentPosition();
    listenToPlaybackState();
  }

  void _listenToCurrentPosition(){
    /*(audioHandler as MyAudioHandler).audioPlayer.positionStream.listen((position) {
      trackPosition.value = position;
    });*/

    AudioService.position.listen((position) {
      trackPosition.value = position;
    });
  }

  void setAudioUrl(String url,Map<String,dynamic> trackInfo) async{
    playerStatus.value = PlayerStatus.buffering;
    await audioHandler.prepareFromUri(Uri.parse(url),trackInfo);
    playerStatus.value = PlayerStatus.ready;
    isTrackPlaying.value = true;
    await audioHandler.play();
  }

  void playTrack(){
    if(!isTrackPlaying.value){
      isTrackPlaying.value = true;
      audioHandler.play();
    }
  }

  void pauseTrack(){
    if(isTrackPlaying.value){
      isTrackPlaying.value = false;
      audioHandler.pause();
    }
  }

  void tempPause(){
    audioHandler.pause();
  }

  void stopTrack(){
    audioHandler.stop();
  }

  void toggleTrack(){
    if(isTrackPlaying.value){
      pauseTrack();
      return;
    }
    playTrack();
  }

  void seek(Duration position){
    audioHandler.seek(position);
  }

  Duration getTrackPosition(){
    return trackPosition.value;
  }

  Duration? getTrackDuration(){
    return audioHandler.mediaItem.value?.duration;
  }

  void listenToPlaybackState(){
    audioHandler.playbackState.listen((event) {
      isTrackPlaying.value = event.playing;
      if(event.processingState == AudioProcessingState.loading || event.processingState == AudioProcessingState.buffering){
        playerStatus.value = PlayerStatus.buffering;
      }
      if(event.processingState == AudioProcessingState.ready){
        playerStatus.value = PlayerStatus.ready;
      }
    });
  }

}