import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/recipient.dart';

class Message {
  int MessageNo;
  String MessageContent;
  String StudentNames;
  String SenderName;
  DateTime MessageDate;
  List<Recipient> recipients;
  String ApproveStatus;

  Message({
    this.MessageNo,
    this.MessageContent,
    this.StudentNames,
    this.SenderName,
    this.MessageDate,
    this.recipients,
    this.ApproveStatus,
  });

  Message.fromMap(Map<String, dynamic> map) {
    MessageNo = map[MessageFieldNames.MessageNo] ?? 0;
    MessageContent =
        map[MessageFieldNames.MessageContent] ?? StringHandlers.NotAvailable;
    MessageDate = map[MessageFieldNames.MessageDate] != null
        ? DateTime.parse(map[MessageFieldNames.MessageDate])
        : null;
    StudentNames =
        map[MessageFieldNames.StudentNames] ?? StringHandlers.NotAvailable;
    SenderName =
        map[MessageFieldNames.SenderName] ?? StringHandlers.NotAvailable;
    recipients = (map[MessageFieldNames.recipients] as List)
        .map((item) => Recipient.fromMap(item))
        .toList();
    ApproveStatus =
        map[MessageFieldNames.ApproveStatus] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        MessageFieldNames.MessageContent: MessageContent,
        MessageFieldNames.MessageDate: MessageDate,
        MessageFieldNames.MessageNo: MessageNo,
        MessageFieldNames.StudentNames: StudentNames,
        MessageFieldNames.SenderName: SenderName,
        MessageFieldNames.ApproveStatus: ApproveStatus,
      };
}

class MessageFieldNames {
  static String MessageContent = "MessageContent";
  static String MessageDate = "MessageDate";

  static String MessageNo = "MessageNo";
  static String StudentNames = "StudentNames";
  static String SenderName = "SenderName";
  static String recipients = "recipients";
  static String ApproveStatus = "ApproveStatus";
}

class MessageUrls {
  static const String GET_TEACHER_MESSAGES = 'Message/GetTeacherMessages';
  static const String GET_MESSAGE_COMMENTS = 'Message/GetMessageComments';
  static const String POST_MESSAGE_COMMENTS = 'Message/PostMessageComment';
  static const String POST_TEACHER_MESSAGE = 'Message/SendMessage';
  static const String POST_MEETING = 'Video/AddMeeting';
}
