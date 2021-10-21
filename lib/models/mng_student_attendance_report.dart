class StudentAttendanceReport {
  int STUD_NO;
  String STUD_FULLNAME;
  int TOT_PDAYS;
  int TOT_WDAYS;
  int TOT_ADAYS;
  int ROLL_NO;

  StudentAttendanceReport({
    this.STUD_NO,
    this.STUD_FULLNAME,
    this.TOT_PDAYS,
    this.TOT_WDAYS,
    this.TOT_ADAYS,
    this.ROLL_NO,
  });

  StudentAttendanceReport.fromMap(Map<String, dynamic> map) {
    STUD_NO = map[StudentAttendanceReportConst.STUD_NOConst] ?? 0;
    STUD_FULLNAME = map[StudentAttendanceReportConst.STUD_FULLNAMEConst] ?? '';
    TOT_PDAYS = map[StudentAttendanceReportConst.TOT_PDAYSConst] ?? 0;
    TOT_WDAYS = map[StudentAttendanceReportConst.TOT_WDAYSConst] ?? 0;
    TOT_ADAYS = map[StudentAttendanceReportConst.TOT_ADAYSConst] ?? 0;
    ROLL_NO = map[StudentAttendanceReportConst.ROLL_NO] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StudentAttendanceReportConst.STUD_NOConst: STUD_NO,
        StudentAttendanceReportConst.STUD_FULLNAMEConst: STUD_FULLNAME,
        StudentAttendanceReportConst.TOT_PDAYSConst: TOT_PDAYS,
        StudentAttendanceReportConst.TOT_WDAYSConst: TOT_WDAYS,
        StudentAttendanceReportConst.TOT_ADAYSConst: TOT_ADAYS,
        StudentAttendanceReportConst.ROLL_NO: ROLL_NO,
      };
}

class StudentAttendanceReportConst {
  static const String STUD_NOConst = "STUD_NO";
  static const String STUD_FULLNAMEConst = "STUD_FULLNAME";
  static const String TOT_PDAYSConst = "TOT_PDAYS";
  static const String TOT_WDAYSConst = "TOT_WDAYS";
  static const String TOT_ADAYSConst = "TOT_ADAYS";
  static const String ROLL_NO = "ROLL_NO";
}

class StudentAttendanceReportUrls {
  static String GET_STUDENT_ATTENDANCE_REPORT =
      "Attendance/GetStudentAttendanceReport";
}
