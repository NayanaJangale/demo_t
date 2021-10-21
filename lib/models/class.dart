import 'package:teachers/handlers/string_handlers.dart';

class Class {
  int class_id;
  String class_name;
  int class_no;

  Class({
    this.class_id,
    this.class_name,
    this.class_no,
  });

  Class.fromMap(Map<String, dynamic> map) {
    class_id = map[ClassConst.class_idConst];
    class_name = map[ClassConst.class_nameConst];
    class_no = map[ClassConst.class_noConst];
  }

  Class.fromJson(Map<dynamic, dynamic> map)
      : class_id = map[ClassConst.class_idConst] ?? 0,
        class_name =
            map[ClassConst.class_nameConst] ?? StringHandlers.NotAvailable,
        class_no = map[ClassConst.class_noConst] ?? 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ClassConst.class_idConst: class_id,
        ClassConst.class_nameConst: class_name,
        ClassConst.class_noConst: class_no,
      };
}

class ClassConst {
  static const String class_idConst = "class_id";
  static const String class_nameConst = "class_name";
  static const String class_noConst = "class_no";
}

class ClassUrls {
  static const String GET_CLASSES = "Management/GetClasses";
  static const String GET_CLASSES_BY_SUBJECT = "Teacher/GetTeacherPeriodwiseClasses";
}
