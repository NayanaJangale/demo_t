import 'package:teachers/handlers/string_handlers.dart';

class AcademicYear {
  int yr_no;
  String yr_desc;

  AcademicYear({
    this.yr_no,
    this.yr_desc,
  });

  AcademicYear.fromJson(Map<String, dynamic> map) {
    yr_no = map["yr_no"] ?? 0;
    yr_desc = map["yr_desc"] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    "yr_no": yr_no,
    "yr_desc": yr_desc,
  };
}

