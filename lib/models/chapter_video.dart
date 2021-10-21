import 'package:teachers/handlers/string_handlers.dart';
class ChapterVideo {
  int class_id;
  int subject_id;
  int division_id;
  int emp_no;
  String chapter_name;
  String videos;

  ChapterVideo({
    this.class_id,
    this.subject_id,
    this.division_id,
    this.chapter_name,
    this.emp_no,
    this.videos
  });

  ChapterVideo.fromJson(Map<String, dynamic> map) {
    class_id = map["class_id"] ?? 0;
    subject_id = map["subject_id"] ?? 0;
    division_id = map["division_id"] ?? 0;
    chapter_name = map["chapter_name"] ?? StringHandlers.NotAvailable;
    emp_no = map["emp_no"] ?? 0;
    videos = map["videos"] ?? StringHandlers.NotAvailable;
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    "class_id": class_id,
    "subject_id": subject_id,
    "division_id": division_id,
    "chapter_name": chapter_name,
    "emp_no": emp_no,
    "videos": videos,
  };
}

