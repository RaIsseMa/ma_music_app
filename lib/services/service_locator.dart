import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import 'package:ma_music_app/services/audio_handler.dart';
import 'package:ma_music_app/view_models/search_page_vm.dart';


GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async{
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  getIt.registerLazySingleton(() => SearchPageViewModel());
}