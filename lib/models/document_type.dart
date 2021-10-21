class DocumentType {
  int category_id;
  String category_name;

  DocumentType({
    this.category_id,
    this.category_name,
  });

  DocumentType.fromMap(Map<String, dynamic> map) {
    category_id = map[DocumentTypeConst.category_idConst];
    category_name = map[DocumentTypeConst.category_nameConst];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        DocumentTypeConst.category_idConst: category_id,
        DocumentTypeConst.category_nameConst: category_name,
      };
}

class DocumentTypeConst {
  static const String category_idConst = "category_id";
  static const String category_nameConst = "category_name";
}

class DocumentTypeUrls {
  static const String GET_DOC_CATEGORIES = "Download/GetCategories";
}
