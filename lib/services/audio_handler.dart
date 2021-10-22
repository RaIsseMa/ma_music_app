import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mamusicapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
    ),
  );
}
class MyAudioHandler extends BaseAudioHandler {
  final audioPlayer = AudioPlayer();

  MyAudioHandler(){
    notifyAudioHandlerAboutPlaybackEvents();
  }

  @override
  Future<void> play() {
    return audioPlayer.play();
  }

  @override
  Future<void> pause() {
    return audioPlayer.pause();
  }

  @override
  Future<void> stop() {
    return audioPlayer.stop();
  }

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) {
    mediaItem.add(
      MediaItem(id: extras!["id"].toString(), title: extras["title"]
        ,duration: extras["duration"],artUri: extras["thumbnail"])
    );
    return audioPlayer.setUrl(uri.toString());
  }

  @override
  Future<void> seek(Duration position) {
    return audioPlayer.seek(position);
  }

  void notifyAudioHandlerAboutPlaybackEvents(){
    audioPlayer.playbackEventStream.listen((event) {
      final playing = audioPlayer.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext
        ],
        systemActions: const{
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0,1,3],
        processingState: const{
          ProcessingState.completed: AudioProcessingState.completed,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.idle : AudioProcessingState.idle,
          ProcessingState.loading : AudioProcessingState.loading,
          ProcessingState.ready : AudioProcessingState.ready,
        }[audioPlayer.processingState]!,
        playing: playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
      ));
    });
  }

  Duration position(){
    return audioPlayer.position;
  }

  Duration? duration(){
    return audioPlayer.duration;
  }


}