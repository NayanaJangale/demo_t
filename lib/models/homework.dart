import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/period.dart';

class Homework {
  int hw_no;
  String hw_desc;
  String hw_image;
  DateTime submission_dt;
  int emp_no;
  DateTime hw_date;
  String brcode;
  int yr_no;
  String divisions;
  String ApproveStatus;
  bool docstatus;
  List<Period> periods;

  Homework({
    this.hw_no,
    this.hw_desc,
    this.hw_image,
    this.submission_dt,
    this.emp_no,
    this.hw_date,
    this.brcode,
    this.yr_no,
    this.divisions,
    this.ApproveStatus,
    this.periods,
    this.docstatus,
  });

  factory Homework.fromJson(Map<String, dynamic> parsedJson) {
    return Homework(
      hw_no: parsedJson['hw_no'] ?? 0,
      hw_desc: parsedJson['hw_desc'] ?? StringHandlers.NotAvailable,
      hw_image: parsedJson['hw_image'] ?? '',
      submission_dt:
          parsedJson[HomeworkFieldNames.Homework_submissionConst] != null
              ? DateTime.parse(
                  parsedJson[HomeworkFieldNames.Homework_submissionConst])
              : null,
      hw_date: parsedJson[HomeworkFieldNames.Hw_dateConst] != null
          ? DateTime.parse(parsedJson[HomeworkFieldNames.Hw_dateConst])
          : null,
      emp_no: parsedJson['emp_no'] ?? 0,
      brcode: parsedJson['brcode'] ?? StringHandlers.NotAvailable,
      yr_no: parsedJson['yr_no'] ?? 0,
      ApproveStatus: parsedJson['ApproveStatus'] ?? "P",
      periods: (parsedJson[HomeworkFieldNames.periods] as List)
          .map((item) => Period.fromMap(item))
          .toList(),
      docstatus: parsedJson['docstatus'] ?? false,
    );
  }


  Map<String, dynamic> toJson() => <String, dynamic>{
        HomeworkFieldNames.Homework_noConst: hw_no,
        HomeworkFieldNames.Homework_descConst: hw_desc,
        HomeworkFieldNames.Homework_imageConst: hw_image,
        HomeworkFieldNames.Homework_submissionConst:
            submission_dt == null ? null : submission_dt.toIso8601String(),
        HomeworkFieldNames.Hw_dateConst:
            hw_date == null ? null : hw_date.toIso8601String(),
        HomeworkFieldNames.Emp_noConst: emp_no,
        HomeworkFieldNames.Brcodes_Const: brcode,
        HomeworkFieldNames.Yrno_Const: yr_no,
        HomeworkFieldNames.period_Const: divisions,
        HomeworkFieldNames.ApproveStatus: ApproveStatus,
        HomeworkFieldNames.periods: periods,
        HomeworkFieldNames.docstatus: docstatus,
      };
}

class HomeworkFieldNames {
  static const String Homework_noConst = "hw_no";
  static const String Homework_descConst = "hw_desc";
  static const String Homework_imageConst = "hw_image";
  static const String Homework_stringConst = "hw_String";
  static const String Homework_submissionConst = "submission_dt";
  static const String Class_idConst = "class_id";
  static const String Division_idConst = "division_id";
  static const String Subject_idConst = "subject_id";
  static const String Emp_noConst = "emp_no";
  static const String Hw_dateConst = "hw_date";
  static const String Brcodes_Const = "brcode";
  static const String Yrno_Const = "yr_no";
  static const String Class_nameConst = "class_name";
  static const String Division_nameConst = "division_name";
  static const String Subject_nameConst = "subject_name";
  static const String period_Const = "divisions";
  static const String ApproveStatus = "ApproveStatus";
  static const String periods = "periods";
  static const String docstatus = "docstatus";
}

class HomeworkUrls {
  static const String GET_TEACHER_HOMEWORK = "Homework/GetTeacherHomework";
  static const String POST_TEACHER_HOMEWORK = "Homework/PostHomework";
  static const String DELETE_TEACHER_HOMEWORK = "Homework/PostDeleteHomework";
  static const String GetHomeworkDocuments = "Homework/GetHomeworkDocuments";
  static const String GetHomeworkDocument = "Homework/GetHomeworkDocument";
}
