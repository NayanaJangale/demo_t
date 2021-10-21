import 'package:teachers/handlers/string_handlers.dart';

class User {
  int user_no;
  String user_id;
  String user_password;
  int emp_no;
  String emp_name;
  String brcode;
  String interbr_report;
  int yr_no;
  String academic_year;
  String client_code;
  int class_id;
  String class_name;
  int division_id;
  String division_name;
  int section_id;
  String section_name;
  String clientName;
  int is_logged_in;
  int remember_me;

  User({
    this.user_no,
    this.user_id,
    this.user_password,
    this.emp_no,
    this.emp_name,
    this.brcode,
    this.interbr_report,
    this.yr_no,
    this.academic_year,
    this.client_code,
    this.class_id,
    this.class_name,
    this.division_id,
    this.division_name,
    this.is_logged_in,
    this.section_id,
    this.section_name,
    this.clientName,
    this.remember_me
  });

  User.fromJson(Map<String, dynamic> map) {
    user_no = map[UserFieldNames.user_no] ?? 0;
    user_id = map[UserFieldNames.user_id] ?? '';
    user_password = map[UserFieldNames.user_password] ?? '';
    emp_no = map[UserFieldNames.emp_no] ?? 0;
    emp_name = map[UserFieldNames.emp_name] ?? StringHandlers.NotAvailable;
    brcode = map[UserFieldNames.brcode] ?? StringHandlers.NotAvailable;
    interbr_report = map[UserFieldNames.interbr_report] ?? 'N';
    yr_no = map[UserFieldNames.yr_no] ?? 0;
    academic_year = map[UserFieldNames.academic_year] ?? 0;
    client_code = map[UserFieldNames.client_code] ?? '0';
    class_id = map[UserFieldNames.class_id] ?? 0;
    class_name = map[UserFieldNames.class_name] ?? StringHandlers.NotAvailable;
    division_id = map[UserFieldNames.division_id] ?? 0;
    division_name =
        map[UserFieldNames.division_name] ?? StringHandlers.NotAvailable;
    is_logged_in = map[UserFieldNames.is_logged_in] ?? 0;
    section_id = map[UserFieldNames.section_id] ?? 0;
    section_name =
        map[UserFieldNames.section_name] ?? StringHandlers.NotAvailable;
    clientName = map[UserFieldNames.clientName] ?? '';
    remember_me = map[UserFieldNames.remember_me] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        UserFieldNames.user_no: user_no,
        UserFieldNames.user_id: user_id,
        UserFieldNames.user_password: user_password,
        UserFieldNames.emp_no: emp_no,
        UserFieldNames.emp_name: emp_name,
        UserFieldNames.brcode: brcode,
        UserFieldNames.interbr_report: interbr_report,
        UserFieldNames.yr_no: yr_no,
        UserFieldNames.academic_year: academic_year,
        UserFieldNames.client_code: client_code,
        UserFieldNames.class_id: class_id,
        UserFieldNames.class_name: class_name,
        UserFieldNames.division_id: division_id,
        UserFieldNames.division_name: division_name,
        UserFieldNames.is_logged_in: is_logged_in,
        UserFieldNames.section_id: section_id,
        UserFieldNames.section_name: section_name,
        UserFieldNames.clientName: clientName,
        UserFieldNames.remember_me: remember_me,
      };
}

class UserFieldNames {
  static const String user_no = "user_no";
  static const String UserNo = "UserNo";
  static const String user_id = "user_id";
  static const String user_password = "user_password";
  static const String emp_no = "emp_no";
  static const String emp_name = "emp_name";
  static const String brcode = "brcode";
  static const String interbr_report = "interbr_report";
  static const String yr_no = "yr_no";
  static const String academic_year = "academic_year";
  static const String client_code = "client_code";
  static const String class_id = "class_id";
  static const String class_name = "class_name";
  static const String division_id = "division_id";
  static const String division_name = "division_name";
  static const String is_logged_in = 'is_logged_in';
  static const String section_id = "section_id";
  static const String section_name = "section_name";
  static const String clientName = "clientName";
  static const String remember_me = "remember_me";
}

class UserUrls {
  static const String GET_EMPLOYEE_DETAILS = 'Users/GetEmployeeDetails';
  static const String POST_RESET_TEACHER_PASSWORD =
      'Users/ResetEmployeePassword';
  static const String POST_CHANGE_TEACHER_PASSWORD =
      'Users/ChangeEmployeePassword';
  static const String POST_GENERATE_OTP = 'SMS/GenerateOTP';
  static const String POST_VALIDATE_OTP = 'SMS/ValidateOTP';
}
