import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/period.dart';

class Circular {
  int circular_no;
  DateTime circular_date;
  String circular_for;
  String circular_title;
  String circular_desc;
  int section_id;
  String section_name;
  String from_class;
  int class_idupto;
  String to_class;
  String division_name;
  int emp_no;
  String emp_name;
  String brcode;
  String circular_image;
  int class_id;
  int division_id;
  int subject_id;
  String divisions;
  String ApproveStatus;
  bool docstatus;
  List<Period> periods;

  Circular(
      {this.circular_no,
      this.circular_date,
      this.circular_for,
      this.circular_title,
      this.circular_desc,
      this.section_id,
      this.section_name,
      this.class_id,
      this.from_class,
      this.class_idupto,
      this.to_class,
      this.division_id,
      this.division_name,
      this.emp_no,
      this.emp_name,
      this.brcode,
      this.subject_id,
      this.divisions,
      this.ApproveStatus,
      this.docstatus,
      this.periods});


  factory Circular.fromJson(Map<String, dynamic> parsedJson) {
    return Circular(
      circular_no: parsedJson['circular_no'] ?? 0,
      circular_date:
          DateTime.parse(parsedJson[CircularFieldNames.Circular_date]) !=
                      null &&
                  parsedJson[CircularFieldNames.Circular_date]
                          .toString()
                          .trim() !=
                      ''
              ? DateTime.parse(parsedJson[CircularFieldNames.Circular_date])
              : null,
      circular_for: parsedJson['circular_for'] ?? StringHandlers.NotAvailable,
      circular_title:
          parsedJson['circular_title'] ?? StringHandlers.NotAvailable,
      circular_desc: parsedJson['circular_desc'] ?? StringHandlers.NotAvailable,
      section_id: parsedJson['section_id'] ?? 0,
      section_name: parsedJson['section_name'] ?? StringHandlers.NotAvailable,
      class_id: parsedJson['class_id'] ?? 0,
      from_class: parsedJson['from_class'] ?? StringHandlers.NotAvailable,
      class_idupto: parsedJson['class_idupto'] ?? 0,
      to_class: parsedJson['to_class'] ?? StringHandlers.NotAvailable,
      division_id: parsedJson['division_id'] ?? 0,
      division_name: parsedJson['division_name'] ?? StringHandlers.NotAvailable,
      emp_no: parsedJson['emp_no'] ?? 0,
      emp_name: parsedJson['emp_name'] ?? StringHandlers.NotAvailable,
      brcode: parsedJson['brcode'] ?? StringHandlers.NotAvailable,
      subject_id: parsedJson['subject_id'] ?? 0,
      ApproveStatus: parsedJson['ApproveStatus'] ?? "P",
      docstatus: parsedJson['docstatus'] ?? false,
      periods: (parsedJson[CircularFieldNames.periods] as List)
          .map((item) => Period.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        CircularFieldNames.Circular_no: circular_no,
        CircularFieldNames.Circular_date:
            circular_date == null ? null : circular_date.toIso8601String(),
        CircularFieldNames.Circular_for: circular_for,
        CircularFieldNames.Circular_title: circular_title,
        CircularFieldNames.Circular_desc: circular_desc,
        CircularFieldNames.Section_id: section_id,
        CircularFieldNames.Section_name: section_name,
        CircularFieldNames.Class_id: class_id,
        CircularFieldNames.From_class: from_class,
        CircularFieldNames.Class_idupto: class_idupto,
        CircularFieldNames.To_class: to_class,
        CircularFieldNames.Division_id: division_id,
        CircularFieldNames.Division_name: division_name,
        CircularFieldNames.Emp_no: emp_no,
        CircularFieldNames.Emp_name: emp_name,
        CircularFieldNames.Brcode: brcode,
        CircularFieldNames.Subject_id: subject_id,
        CircularFieldNames.ApproveStatus: ApproveStatus,
        CircularFieldNames.divisions: divisions,
        CircularFieldNames.docstatus: docstatus,
      };
}

class CircularFieldNames {
  static const String Circular_no = "circular_no";
  static const String Circular_date = "circular_date";
  static const String Circular_for = "circular_for";
  static const String Circular_title = "circular_title";
  static const String Circular_desc = "circular_desc";
  static const String Section_id = "section_id";
  static const String Section_name = "section_name";
  static const String Class_id = "class_id";
  static const String From_class = "from_class";
  static const String Class_idupto = "class_idupto";
  static const String To_class = "to_class";
  static const String Division_id = "division_id";
  static const String Division_name = "division_name";
  static const String Emp_no = "emp_no";
  static const String Emp_name = "emp_name";
  static const String Brcode = "brcode";
  static const String Subject_id = "subject_id";
  static const String divisions = "divisions";
  static const String periods = "periods";
  static const String ApproveStatus = "ApproveStatus";
  static const String docstatus = "docstatus";
}

class CircularUrls {
  static const String POST_TEACHER_CIRCULAR = "Circular/PostCircular";
  static const String DELETE_TEACHER_CIRCULAR= "Circular/PostDeleteCircular";
  static const String GET_TEACHER_CIRCULARS = 'Circular/GetTeacherCirculars';
  static const String GET_CIRCULAR_IMAGE = 'Circular/GetCircularImage';
  static const String GET_MANAGEMENT_CIRCULARS = 'Circular/GetManagementCirculars';
  static const String GetCircularDocuments = "Circular/GetCircularDocuments";
  static const String GetCircularDocument = "Circular/GetCircularDocument";
}
