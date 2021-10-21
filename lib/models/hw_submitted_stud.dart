class HWSubmittedStud {
  int class_id;
  int division_id;
  int stud_no;
  String stud_full_name;
  int seq_no;

  HWSubmittedStud({
    this.class_id,
    this.division_id,
    this.stud_no,
    this.stud_full_name,
    this.seq_no,
  });

  HWSubmittedStud.fromMap(Map<String, dynamic> map) {
    class_id = map[HWSubmittedStudConst.class_id]?? 0;
    division_id = map[HWSubmittedStudConst.division_id]?? 0;
    stud_no = map[HWSubmittedStudConst.stud_no]?? 0;
    stud_full_name = map[HWSubmittedStudConst.stud_full_name];
    seq_no = map[HWSubmittedStudConst.seq_no]?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    HWSubmittedStudConst.class_id: class_id,
    HWSubmittedStudConst.division_id: division_id,
    HWSubmittedStudConst.stud_no: stud_no,
    HWSubmittedStudConst.stud_full_name: stud_full_name,
    HWSubmittedStudConst.seq_no: seq_no,
  };
}

class HWSubmittedStudConst {
  static const String class_id = "class_id";
  static const String division_id = "division_id";
  static const String stud_no = "stud_no";
  static const String stud_full_name = "stud_full_name";
  static const String seq_no = "seq_no";
}

class HWSubmittedStudUrls {
  static const String GET_HW_Submitted_Stud = 'Homework/GetHomeworkSubmittedStudList';
}
