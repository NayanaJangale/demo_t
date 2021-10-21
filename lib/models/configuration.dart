class Configuration {
  String confGroup, confName, confValue;

  Configuration({this.confGroup, this.confName, this.confValue,});

  Configuration.fromJson(Map<String, dynamic> map) {
    confGroup = map[ConfigurationFieldNames.ConfigurationGroup];
    confName = map[ConfigurationFieldNames.ConfigurationName];
    confValue = map[ConfigurationFieldNames.ConfigurationValue];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    ConfigurationFieldNames.ConfigurationGroup: confGroup,
    ConfigurationFieldNames.ConfigurationName: confName,
    ConfigurationFieldNames.ConfigurationValue: confValue,
  };
}

class ConfigurationFieldNames {
  static const String ConfigurationGroup = "ConfigurationGroup";
  static const String ConfigurationName = "ConfigurationName";
  static const String ConfigurationValue = "ConfigurationValue";
}

class ConfigurationUrls {
  static const String GET_CONFIGURATION_BY_GROUP = 'Configurations/GetConfigurationByGroup';
  static const String GET_CONFIGURATION_BY_VALUE = 'Configurations/GetConfigurationByValue';
}

class ConfigurationGroups {
  static const String Attendance = 'STUD_ATTENDANCE';
  static const String Message = 'Communication Teacher To';
  static const String CircularFor = 'CircularFor';
  static const String PreviousDayAttendance = 'PreviousDayAttendance';
  static const String ApprovedByManagement = 'Approved by Management';
  static const String AddNewsfeed = 'Newsfeed';
}

class ConfigurationNames {
  static const String SUBJECTWISE = 'SUBJECT_WISE';
  static const String Approval = 'Approval';
  static const String Circular = 'Circular';
  static const String Homework = 'Homework';
  static const String Message = 'Message';
  static const String TeacherApp = 'TeacherApp';

}