class Song{

  late String id;
  late String title;
  late String thumbnail360P;
  late String thumbnail720P;
  late String duration;
  String url = "";

  Song({required this.id,required this.title,required this.thumbnail360P,required this.thumbnail720P,required this.duration});

  void setUrl(String url){
    this.url = url;
  }

}