import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:teachers/models/mng_student_attendance_report.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFMaker {
  static Future<bool> createPdf(
    String className,
    String reportName,
    List<StudentAttendanceReport> studentAttendance,
  ) async {
    try {
      List<List<String>> res = [
        <String>['No', 'Student Name', 'Present', 'Absent', 'Week'],
      ];

      int cnt = 0;
      for (var r in studentAttendance) {
        cnt++;
        res.add(<String>[
          cnt.toString(),
          r.STUD_FULLNAME,
          r.TOT_PDAYS.toString(),
          r.TOT_ADAYS.toString(),
          r.TOT_WDAYS.toString(),
        ]);
      }

      final Document pdf = Document();
      Printing.layoutPdf(
        onLayout: (format) {
          final doc = pw.Document();
          doc.addPage(
            pw.MultiPage(
                header: (Context context) {
                  return Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(
                      bottom: 3.0 * PdfPageFormat.mm,
                    ),
                    padding: const EdgeInsets.only(
                      bottom: 3.0 * PdfPageFormat.mm,
                    ),
                    /*decoration: const BoxDecoration(
                border: BoxBorder(
                  bottom: true,
                  width: 0.5,
                  color: PdfColors.grey,
                ),
              ),*/
                    child: Text(
                      'Report',
                      style: Theme.of(context)
                          .defaultTextStyle
                          .copyWith(color: PdfColors.grey),
                    ),
                  );
                },
                footer: (Context context) {
                  return Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                    child: Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: Theme.of(context)
                          .defaultTextStyle
                          .copyWith(color: PdfColors.grey),
                    ),
                  );
                },
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                build: (pw.Context context) => <pw.Widget>[
                  Header(
                    level: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          reportName,
                          textScaleFactor: 2,
                        ),
                      ],
                    ),
                  ),
                  Header(
                    level: 1,
                    text: 'Class : $className',
                  ),
                  /* Paragraph(
              text:
                  'The PDF file format has changed several times, and continues to evolve, along with the release of new versions of Adobe Acrobat. There have been nine versions of PDF and the corresponding version of the software:'),*/
                  Table.fromTextArray(
                    context: context,
                    data: res,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                  ),
                  Paragraph(
                    text: 'Software generated report.',
                    textAlign: TextAlign.right,
                  ),
                ]),
          );
          return doc.save();
        },
        name: 'order_id_#',
      );

      //Share
      /* await Printing.sharePdf(
        bytes: pdf.save(),
        filename: '${DateTime.now().toUtc().toIso8601String()}.pdf');*/
      return true;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }
}
