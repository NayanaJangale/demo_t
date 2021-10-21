import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/period.dart';
import 'package:teachers/pages/teacher/homework_documents_page.dart';
import 'package:teachers/pages/teacher/hw_submitted_student.dart';

class CustomHomeworkItem extends StatefulWidget {
  final String networkPath;
  final List<Period> periods;
  final Function onItemTap;
  final Homework homework;
  final String approvalStatus;
  final bool isVisibility;

  CustomHomeworkItem(
      {this.networkPath, this.periods, this.onItemTap, this.homework,this.approvalStatus,this.isVisibility});

  @override
  _CustomHomeworkItemState createState() => _CustomHomeworkItemState();
}

class _CustomHomeworkItemState extends State<CustomHomeworkItem> {
  String hwDate, submissionDate;
  List<Homework> _homeworks = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _homeworks.add(widget.homework);
    hwDate = widget.homework.hw_date != null
        ? DateFormat('dd MMM').format(widget.homework.hw_date)
        : "";
    submissionDate = widget.homework.submission_dt != null
        ? DateFormat('dd MMM').format(widget.homework.submission_dt)
        : "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress:widget.onItemTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          /*  Visibility(
              visible: widget.networkPath != null && widget.networkPath != '',
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImagePage(
                        dynamicObjects: _homeworks,
                        imageType: 'HomeWork',
                        photoIndex: 0,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: widget.networkPath,
                  imageBuilder: (context, imageProvider) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        widget.networkPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(),
                ),
              ),
            ),*/
            widget.periods != null && widget.periods.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Wrap(
                      spacing: 5.0, // gap between adjacent chips,
                      runSpacing: 0.0,
                      children: List<Widget>.generate(
                        widget.periods.length,
                        (i) => Chip(
                          backgroundColor: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                              topLeft: Radius.circular(3),
                              bottomLeft: Radius.circular(3),
                            ),
                          ),
                          avatar: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 12,
                            height: 12,
                          ),
                          label: Text(
                            widget.periods[i].subject_name +
                                ' - ' +
                                widget.periods[i].class_name +
                                ' ' +
                                widget.periods[i].division_name,
                          ),
                          labelStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppTranslations.of(context).text("key_date") + ':' + hwDate,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    AppTranslations.of(context).text("key_submission_date") +
                        ':' +
                        submissionDate,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: LinkWell(
                widget.homework.hw_desc,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 10.0,
                  bottom: 5.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Visibility(
                      child: Text(
                        "Status : " + widget.approvalStatus,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                      visible: widget.isVisibility,
                    ),
                    Visibility(
                      visible: widget.homework.docstatus,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeworkDocumentsPage(
                              hw_no: widget.homework.hw_no,
                            )),
                          );
                        },
                        child: Text(
                          'View Document',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                              fontSize: 14
                          ),
                        ),
                      ),
                    )
                  ],)
            ),
            Align(
              alignment: Alignment.topRight,
              child:  Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 10.0,
                  bottom: 8.0,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    if ( widget.periods!= null && widget.periods.length > 0 ){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HWSubmittedStudPage(
                          periods: widget.periods,
                          hw_no: widget.homework.hw_no,
                        )),
                      );
                    }

                  },
                  child: Text(
                    'View Submitted H/w',
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
