import 'package:teachers/handlers/string_handlers.dart';

class School {
  String clientName;
  int clientCode;

  School({this.clientCode, this.clientName});

  School.fromJson(Map<dynamic, dynamic> map)
      : clientCode = map[SchoolFieldNames.clientCode] ?? '0',
        clientName =
            map[SchoolFieldNames.clientName] ?? StringHandlers.NotAvailable;

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        SchoolFieldNames.clientCode: clientCode,
        SchoolFieldNames.clientName: clientName,
      };
}

class SchoolFieldNames {
  static const String clientCode = 'ClientCode';
  //static const String clientCode = 'clientCode';
  static const String clientName = 'clientName';
}

class SchoolUrls {
  static const String GET_SCHOOLS = 'MIS/GetClientDetails';
}
