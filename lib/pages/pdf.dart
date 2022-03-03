import 'package:flutter/material.dart';
import 'package:osmanbaba/pages/pdf_preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class Pdf extends StatefulWidget {
  @override
  _PdfState createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  final pdf = pw.Document();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async{
          writeOnPdf();
          await savePdf();

          Directory documentDirectory = await getApplicationDocumentsDirectory();

          String documentPath = documentDirectory.path;

          String fullPath = "$documentPath/example.pdf";

          Navigator.push(context, MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(fullPath)
          ));
        },
        child: Container(
          height: 100,
          width: 100,
          color: Colors.red,
        ),
      ),
    );
  }

  writeOnPdf() async{
    pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),

          build: (pw.Context context){
            return <pw.Widget> [
              pw.Header(
                level: 0,
                child: pw.Text("PDF Header")
              )
            ];
          }
        )
    );
  }

  Future savePdf() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/example.pdf");

    file.writeAsBytesSync(pdf.save());
  }
}
