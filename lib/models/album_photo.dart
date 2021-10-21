
class AlbumPhoto {
  int album_id, photo_id;
  String photo_desc;

  AlbumPhoto({
    this.album_id,
    this.photo_id,
    this.photo_desc,
  });

  AlbumPhoto.fromJson(Map<String, dynamic> map) {
    album_id = map["album_id"] ?? 0;
    photo_id = map["photo_id"] ?? 0;
    photo_desc =map["photo_desc"] ?? "";
  }
  

  Map<String, dynamic> toJson() => <String, dynamic>{
        "album_id": album_id,
        "photo_id": photo_id,
        "photo_desc": photo_desc,
      };
}

