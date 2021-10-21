import 'package:teachers/handlers/string_handlers.dart';

class Album {
  int album_id;
  String album_desc;

  Album({
    this.album_id,
    this.album_desc,
  });

  Album.fromJson(Map<String, dynamic> map) {
    album_id = map["album_id"] ?? 0;
    album_desc = map["album_desc"] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    "album_id": album_id,
    "album_desc": album_desc,
  };
}


