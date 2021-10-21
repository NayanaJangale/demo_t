class AddDocument {
  int category_id;
  String caption;
  int section_id;
  int classfrom;
  int classupto;
  int div_id;
  String file_status;
String doc_link;
  AddDocument({
    this.category_id,
    this.caption,
    this.section_id,
    this.classfrom,
    this.classupto,
    this.div_id,
    this.file_status,
    this.doc_link,

  });

  AddDocument.fromMap(Map<String, dynamic> map) {
    category_id = map["category_id"];
    caption = map["caption"];
    section_id = map["section_id"];
    classfrom = map["classfrom"];
    classupto = map["classupto"];
    div_id = map["div_id"];
    file_status = map["file_status"];
    doc_link=map["doc_link"];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        "category_id": category_id,
        "caption": caption,
        "section_id": section_id,
        "classfrom": classfrom,
        "classupto": classupto,
        "div_id": div_id,
        "file_status": file_status,
        "doc_link": doc_link,
      };
}

class AddDocumentConst {
  static const String category_idConst = "category_id";
  static const String captionConst = "caption";
  static const String section_idConst = "section_id";
  static const String classfromConst = "classfrom";
  static const String classuptoConst = "classupto";
  static const String div_idConst = "div_id";
  static const String file_statusConst = "file_status";
}

