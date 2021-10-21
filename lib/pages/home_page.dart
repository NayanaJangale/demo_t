import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:launch_review/launch_review.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/auto_update_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/menu_constants.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/SoftCampusConfig.dart';
import 'package:teachers/models/menu.dart';
import 'package:teachers/pages/documents_page.dart';
import 'package:teachers/pages/teacher/change_topic_status_page.dart';
import 'package:teachers/pages/teacher/digital_chapter_page.dart';
import 'package:teachers/pages/teacher/employee_leaves_page.dart';
import 'package:teachers/pages/teacher/feedback_page.dart';
import 'package:teachers/pages/teacher/library_page.dart';
import 'package:teachers/pages/teacher/mark_attendance_page.dart';
import 'package:teachers/pages/teacher/student_attendance_report_page.dart';
import 'package:teachers/pages/teacher/student_fees_page.dart';
import 'package:teachers/pages/teacher/time_table_page.dart';
import 'teacher/albums_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading;
  String loadingText;
  String menuType;
  GlobalKey<ScaffoldState> _homePageGlobalKey;
  List<Menu> menus = [];
  DBHandler _dbHandler;
  List<SoftCampusConfig> _softCampusConfig = [];
  Random random = new Random();
  Uri uri;
  List menuColors = [
    Colors.brown[800],
    Colors.deepPurple[800],
    Colors.orange[800],
    Colors.lightBlue[800],
    Colors.amber[800],
    Colors.grey[800],
    Colors.lime[800],
    Colors.lightGreen[800],
    Colors.red[800],
    Colors.green[800],
    Colors.yellow[800],
    Colors.teal[800],
    Colors.deepOrange[800],
    Colors.cyan[800],
    Colors.blue[800],
    Colors.indigo[800],
    Colors.purple[800],
    Colors.pink[800],
    Colors.blueGrey[800],
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _homePageGlobalKey = GlobalKey<ScaffoldState>();
    fetchConfiguration().then((result) {
      _softCampusConfig = result;
      if (_softCampusConfig != null && _softCampusConfig.length > 0) {
        if (double.parse(_softCampusConfig[0].ConfigurationValue) >
                ProjectSettings.AppVersion &&
            _softCampusConfig[0].ConfigurationName == 'Teacher App Version') {
          showDialog(
              barrierDismissible: false,
              context: this.context,
              builder: (_) {
                return WillPopScope(
                  onWillPop: _onBackPressed,
                  child: AutoUpdateDialog(
                    message:
                    AppTranslations.of(context).text("key_auto_update_instruction"),
                    onOkayPressed: () {
                      LaunchReview.launch(
                        androidAppId: "com.demo.t",
                        iOSAppId: "",
                      );
                      exit(0);
                    },
                  ),
                );
              });
        }
      }
    });

    _dbHandler = new DBHandler();
    isLoading = false;
    loadingText = 'Loading . . .';

    fetchMenus('Teacher').then((result) {
      setState(() {
        menus = result != null ? result : [];
      });
    });
    NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
      if (connectionServerMsg != "key_check_internet") {
        setState(() {
          uri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Users/GetClientPhoto',
          ).replace(queryParameters: {
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    menuType = AppData.getCurrentInstance().preferences != null
        ? AppData.getCurrentInstance().preferences.getString('menuType')
        : "grid";

    this.loadingText = AppTranslations.of(context).text("key_loading");

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _homePageGlobalKey,
          appBar: AppBar(
            leading: Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 50,
                  height: 40,
                  child: Image.network(
                    uri.toString(),
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_hi") +
                  ' ' +
                  StringHandlers.capitalizeWords(
                    AppData.getCurrentInstance().user.emp_name,
                  ),
              subtitle:
              AppTranslations.of(context).text("key_welcometo") +" "+ AppData.getCurrentInstance().user.clientName,
            ),
          ),
          body: SafeArea(child: getTeacherMenu()),
        ),
      ),
    );
  }

  Widget getTeacherMenu() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.grey[300],
            Colors.white,
          ],
          radius: 0.75,
          focal: Alignment.center,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          fetchMenus('Teacher').then((result) {
            setState(() {
              menus = result != null ? result : [];
            });
          });
        },
        child: this.menuType == 'list' ? getListMenu() : getGridMenu(),
      ),
    );
  }

  Widget getGridMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.grey[200],
              Colors.white,
            ],
            radius: 0.75,
            focal: Alignment.center,
          ),
        ),
        child: GridView(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 3,
          ),
          // Generate 100 widgets that display their index in the List.
          children: getGridCells(),
        ),
      ),
    );
  }

  List<Widget> getGridCells() {
    var list = new List<int>.generate(
        menuColors.length, (int index) => index); // [0, 1, 4]
    list.shuffle();

    List<Widget> cells = List.generate(menus.length, (index) {
      int indx = random.nextInt(menuColors.length);
      Color mBg = menuColors[list[indx]];
      mBg = mBg.withOpacity(0.2);

      String str = menus[index].MenuName.replaceAll(' ', '_');

      return GestureDetector(
        onTap: () {
          openMenu(index);
        },
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: mBg,
                    child: Image.asset(
                      "assets/images/${getIconImage(menus[index].MenuName)}",
                      color: menuColors[list[indx]],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppTranslations.of(context).text(str),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    int exItems = 3 - (menus.length % 3);
    if (exItems != 0 && exItems != 3) {
      for (int i = 0; i < exItems; i++) {
        cells.add(
          Container(
            color: Colors.white,
          ),
        );
      }
    }

    return cells;
  }


  openMenu(int index) {

    if (menus[index].MenuName == MenuNameConst.Gallery) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlbumsPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.Add_Album) {
      Navigator.of(context).pushNamed('/album');
    } else if (menus[index].MenuName == MenuNameConst.AttendanceReport) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentAttendanceReportPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.TimeTable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimeTablePage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.Student_Fees) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentFeesPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.Library) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LibraryPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.Circular) {
      Navigator.of(context).pushNamed('/circular');
    } else if (menus[index].MenuName == MenuNameConst.HomeWork) {
      Navigator.of(context).pushNamed('/homework');
    } else if (menus[index].MenuName == MenuNameConst.Attendance) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MarkAttendancePage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.Messages) {
      Navigator.of(context).pushNamed('/message');
    } else if (menus[index].MenuName == MenuNameConst.Syllabus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeTopicStatusPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.EmployeeLeaves) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeLeavesPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.DocumentUpload) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentsPage(),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.DigitalChapter) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DigitalChapterPage(),
        ),
      );
    }else if (menus[index].MenuName == MenuNameConst.Feedback) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedbackPage(),
        ),
      );
    }
  }

  Widget getListMenu() {
    var list = new List<int>.generate(menuColors.length, (int i) => i);
    list.shuffle();
    return Container(
      padding: EdgeInsets.all(3.0),
      color: Colors.grey.withOpacity(0.1),
      child: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          int i = random.nextInt(menuColors.length);
          Color mBg = menuColors[list[i]];
          mBg = mBg.withOpacity(0.2);

          String str = menus[index].MenuName.replaceAll(' ', '_');

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(3.0),
                topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(3.0),
                bottomLeft: Radius.circular(30.0),
              ),
            ),
            elevation: 1.0,
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              onTap: () {
                openMenu(index);
              },
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ),
                child: CircleAvatar(
                  backgroundColor: mBg,
                  child: Image.asset(
                    "assets/images/${getIconImage(menus[index].MenuName)}",
                    color: menuColors[list[i]],
                  ),
                ),
              ),
              title: Text(
                AppTranslations.of(context).text(str),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
              ),
              trailing: Icon(
                Icons.navigate_next,
                color: Colors.black45,
              ),
            ),
          );
        },
      ),
    );
  }

  String getIconImage(String menu) {
    switch (menu) {
      case MenuNameConst.StudentAttendance:
        /* setState(() {
         page = StudentAttendance();
        }); */
        return MenuIconConst.StudentAttendanceIcon;
        break;
      case MenuNameConst.FrequentAbsentees:
        /*  setState(() {
         page = FrequentAbsentees();
        }); */
        return MenuIconConst.FrequentAbsenteesIcon;
        break;
      case MenuNameConst.HomeworkStatus:
        /*  setState(() {
         page = HomeworkStatus();
        }); */
        return MenuIconConst.HomeworkStatusIcon;
        break;
      case MenuNameConst.StaffAttendance:
        /* setState(() {
         page = StaffAttendance();
        }); */
        return MenuIconConst.StaffAttendanceIcon;
        break;
      case MenuNameConst.TeacherLoad:
        /* setState(() {
         page = TeacherLoad();
        }); */
        return MenuIconConst.TeacherLoadIcon;
        break;
      case MenuNameConst.TeacherTimeTable:
        /* setState(() {
         page = TeacherTimeTable();
        }); */
        return MenuIconConst.TeacherTimeTableIcon;
        break;
      case MenuNameConst.PendingFees:
        /*  setState(() {
         page = PendingFees();
        }); */
        return MenuIconConst.PendingFeesIcon;
        break;
      case MenuNameConst.ActivityLog:
        /* setState(() {
         page = ActivityLog();
        }); */
        return MenuIconConst.ActivityLogIcon;
        break;
      case MenuNameConst.AttendanceEntry:
        /*   setState(() {
         page = AttendanceEntry();
        }); */
        return MenuIconConst.AttendanceEntryIcon;
        break;
      case MenuNameConst.EmployeeLeaves:
        /*  setState(() {
         page = EmployeeLeaves();
        }); */
        return MenuIconConst.EmployeeLeavesIcon;
        break;
     /* case MenuNameConst.Leaves:
        *//*  setState(() {
         page = EmployeeLeaves();
        }); *//*
        return MenuIconConst.LeavesIcon;
        break;*/
      case MenuNameConst.Circulars:
        /* setState(() {
         page = Circulars();
        }); */
        return MenuIconConst.CircularsIcon;
        break;
      case MenuNameConst.Balances:
        /*  setState(() {
         page = Balances();
        }); */
        return MenuIconConst.BalancesIcon;
        break;
      case MenuNameConst.BalanceSheet:
        /*  setState(() {
         page = BalanceSheet();
        }); */
        return MenuIconConst.BalanceSheetIcon;
        break;
      case MenuNameConst.Feedback:
      /*  setState(() {
         page = BalanceSheet();
        }); */
        return MenuIconConst.FeedbackIcon;
        break;
      case MenuNameConst.StudentAlbums:
        /* setState(() {
         page = StudentAlbums();
        }); */
        return MenuIconConst.StudentAlbumsIcon;
        break;
      case MenuNameConst.AboutUs:
        /* setState(() {
         page = AboutUs();
        }); */
        return MenuIconConst.AboutUsIcon;
        break;
      case MenuNameConst.Home:
        /*setState(() {
          page = UserHomePage();
        });*/
        return MenuIconConst.HomeIcon;
        break;
      case MenuNameConst.Add_Album:
        /*  setState(() {
         page = Add_Album();
        }); */
        return MenuIconConst.Add_AlbumIcon;
        break;
      case MenuNameConst.Calendar:
        /* setState(() {
         page = Calendar();
        }); */
        return MenuIconConst.CalendarIcon;
        break;
      case MenuNameConst.Gallery:
        /*  setState(() {
         page = Gallery();
        }); */
        return MenuIconConst.GalleryIcon;
        break;
      case MenuNameConst.Attendance:
        /*  setState(() {
         page = Attendance();
        }); */
        return MenuIconConst.AttendanceIcon;
        break;
      case MenuNameConst.HomeWork:
        /* setState(() {
         page = HomeWork();
        }); */
        return MenuIconConst.HomeWorkIcon;
        break;
      case MenuNameConst.Result:
        /* setState(() {
         page = Result();
        }); */
        return MenuIconConst.ResultIcon;
        break;
      case MenuNameConst.Downloads:
        /* setState(() {
         page = Downloads();
        }); */
        return MenuIconConst.DownloadsIcon;
        break;
      case MenuNameConst.Messages:
        /* setState(() {
         page = Messages();
        }); */
        return MenuIconConst.MessagesIcon;
        break;
      case MenuNameConst.Syllabus:
        /* setState(() {
         page = Messages();
        }); */
        return MenuIconConst.SyllabusIcon;
        break;
      case MenuNameConst.ChangePassword:
        /* setState(() {
         page = ChangePassword();
        }); */
        return MenuIconConst.ChangePasswordIcon;
        break;
      case MenuNameConst.TimeTable:
        /* setState(() {
         page = TimeTable();
        }); */
        return MenuIconConst.TimeTableIcon;
        break;
      case MenuNameConst.StudentFess:
        /* setState(() {
         page = StudentFess();
        }); */
        return MenuIconConst.StudentFessIcon;
        break;
      case MenuNameConst.Circular:
        /*  setState(() {
         page = Circular();
        }); */
        return MenuIconConst.CircularIcon;
        break;
      case MenuNameConst.Confirm_Admission:
        /* setState(() {
         page = Confirm_Admission();
        }); */
        return MenuIconConst.Confirm_AdmissionIcon;
        break;
      case MenuNameConst.Student_Fees:
        /* setState(() {
         page = Student_Fees();
        }); */
        return MenuIconConst.Student_FeesIcon;
        break;
      case MenuNameConst.AcademicYear:
        /* setState(() {
         page = AcademicYear();
        }); */
        return MenuIconConst.AcademicYearIcon;
        break;
      case MenuNameConst.Library:
        /* setState(() {
         page = Library();
        }); */
        return MenuIconConst.LibraryIcon;
        break;
      case MenuNameConst.Feedback:
        /* setState(() {
         page = Feedback();
        }); */
        return MenuIconConst.FeedbackIcon;
        break;
      case MenuNameConst.EmployeeLeaves:
        /* setState(() {
         page = Feedback();
        }); */
        return MenuIconConst.EmployeeLeavesIcon;
        break;
      case MenuNameConst.Logout:
        /*  setState(() {
         page = Logout();
        }); */
        return MenuIconConst.LogoutIcon;
        break;
      case MenuNameConst.DigitalChapter:
        /*  setState(() {
         page = Logout();
        }); */
        return MenuIconConst.DigitalChapterIcon;
        break;
      case MenuNameConst.DocumentUpload:
      /*  setState(() {
         page = Logout();
        }); */
        return MenuIconConst.DocumentUploadIcon;
        break;
      case MenuNameConst.LiveStreaming:
      /*  setState(() {
         page = Logout();
        }); */
        return MenuIconConst.LiveStreamingIcon;
        break;
      default:
        /* setState(() {
          page = UserHomePage();
        });*/
        return MenuIconConst.DefaultIcon;
    }
  }

  Future<List<Menu>> fetchMenus(String menuFor) async {
    List<Menu> allMenus;
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading . . .';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          MenuFieldNames.MenuFor: menuFor,
        };

        Uri fetchSchoolsUri = NetworkHandler.getUri(
          connectionServerMsg + ProjectSettings.rootUrl + MenuUrls.GET_MENUS,
          params,
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            allMenus = responseData
                .map(
                  (item) => Menu.fromMap(item),
                )
                .toList();
          });
          _dbHandler.saveMenu(allMenus).then((v) {});
        }
      } else {
        _dbHandler.getMenus().then((val) {
          allMenus = val;
          print(allMenus);
        });

      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      allMenus = null;
    }

    setState(() {
      isLoading = false;
    });

    return allMenus;
  }

  Future<List<SoftCampusConfig>> fetchConfiguration() async {
    List<SoftCampusConfig> softCampusConfigList = [];
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading . . .';
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchSchoolsUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SoftCampusConfigUrls.GET_GetConfigration,
        ).replace(
          queryParameters: {
            'ConfigurationName': 'Teacher App Version',
            'ConfigurationGroup': 'Auto Update For Android',
          },
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
              context, null, response.body.toString(), MessageTypes.WARNING);
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            softCampusConfigList = responseData
                .map(
                  (item) => SoftCampusConfig.fromJson(item),
                )
                .toList();
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error") +
            e.toString(),
        MessageTypes.ERROR,
      );
    }
    setState(() {
      isLoading = false;
    });

    return softCampusConfigList;
  }
  Future<bool> _onBackPressed() {
    exit(1);
  }
}
