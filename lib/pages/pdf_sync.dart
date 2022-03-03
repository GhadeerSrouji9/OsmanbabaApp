
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'mobile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';


class PdfSync extends StatefulWidget {
  @override
  _PdfSyncState createState() => _PdfSyncState();
}

class _PdfSyncState extends State<PdfSync> {
  @override
  build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            child: ElevatedButton(
              onPressed: () {
                _createPdf();
              },
              child: Text("create PDF"),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPdf() async {
    PdfDocument document = PdfDocument();

    final firstPage = document.pages.add();
    final secondPage = document.pages.add();
    final thirdPage = document.pages.add();


    PdfFont normalFont = PdfTrueTypeFont(await _readFontData(), 10);
    PdfFont mediumFont = PdfTrueTypeFont(await _readFontData(), 15);
    PdfFont boldTitleFont = PdfTrueTypeFont(await _readBoldFontData(), 18);
    PdfFont normalBoldFont = PdfTrueTypeFont(await _readBoldFontData(), 10);



    writeOnPdfPage(firstPage, secondPage, thirdPage, normalFont, boldTitleFont, mediumFont);


    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  void writeOnPdfPage(firstPage, secondPage,thirdPage, normalFont, boldTitleFont, mediumFont) {
    final Size pageSize = firstPage.getClientSize();

    double currentTop = 0;

    firstPage.graphics.drawString(
      "REKLAM SÖZLEŞMESİ",
      boldTitleFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;

//    page.graphics.drawRectangle(
//        bounds: Rect.fromLTWH(0, 0, pageSize.width, 40),
//        pen: PdfPen(PdfColor(142, 170, 219, 255)));

    firstPage.graphics.drawString(
      "MADDE 1 - TARAFLAR:",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'İşbu Mesafeli Satış Sözleşmesi ("Sözleşme"); ("ALICI”) ile (“SATICI”) arasında aşağıda belirtilen hüküm ve şartlar çerçevesinde elektronik ortamda kurulmuştur.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 60;

    firstPage.graphics.drawString(
      '1.1. SATICI BİLGİLERİ :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 30;

    firstPage.graphics.drawString(
      'SATICI UNVANI:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'RUHARTE BİLİŞM TEKNOLOJİLERİ SANAYİ VE TİCARET LTD.ŞTİ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Mersis Numarası:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0735170808500001',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Adresi:  ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'İmam bakır Mah. Şutim cad. B blok no:21/1 Haliliye – Şanlıurfa ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Tel:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0542 207 22 47',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Şikayetler İçin İrtibat Bilgisi: ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0542 207 22 47',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Web Adresi:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'www.osmanbaba.net',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'E- mail:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'info@osmanbaba.net',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;


    firstPage.graphics.drawString(
      '1.2. ALICI BİLGİLERİ:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;


    firstPage.graphics.drawString(
      'Firma Ünvanı :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      'firma name babkdskgsf',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      ' Firma Adresi : ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      'firma name babkdskgsf',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      ' Firma Telefon: ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      'firma name babkdskgsf',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Firma E-posta : ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      'firma name babkdskgsf',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Firma Vergi Numarası :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      'firma name babkdskgsf',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;


    firstPage.graphics.drawString(
      'MADDE 2 - KONU VE KAPSAM',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Sözleşme, reklam verenin firmasının reklamı için verilecek hizmetlerin tanımlanması ve ne şekilde işletileceği ile çalışma şekil ve koşullarını kapsamaktadır.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    firstPage.graphics.drawString(
      'MADDE 3 - TARAFLARIN YÜKÜMLÜLÜKLERİ',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Osmanbaba.net, 1. maddedeki amaçlar doğrultusunda Reklam Veren ile tam bir işbirliği içinde çalışmayı, verdiği hizmetin kalitesini korumak ve yükseltmek için her türlü çabayı göstermeyi kabul ve taahhüt eder.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 30;

    firstPage.graphics.drawString(
      'Reklam Veren, anlaşma kapsamı doğrultusunda Osmanbaba.net\'e her alanda işbirliği yapmayı, özellikle doğru ve eksiksiz bilgi vermeyi, tanımlanan hizmetin yürütülmesinde Osmanbaba.net\'i tek sorumlu olarak görmeyi, kabul ve taahhüt eder.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 35;

    /////////////////// SECOND PAGE ////////////////////////////////

    currentTop = 0;
    secondPage.graphics.drawString(
      'MADDE 4 - OSMANBABA.NET REKLAM TÜRLERİ',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 40;


    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: normalFont,
      cellPadding: PdfPaddings(left: 20, right: 20, top: 5, bottom: 5)
    );
    grid.columns.add(count: 4);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = "Ürün Açıklaması";
    header.cells[1].value = "Sözleşme Başlangıç Tarihi";
    header.cells[2].value = "Sözleşme Bitiş Tarihi";
    header.cells[3].value = "Kdv Dahil Tutar";

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = "eedd rgerbgerg ergergg";
    row.cells[1].value = "ddd";
    row.cells[2].value = "dddd";
    row.cells[3].value = "dddd";

    grid.draw(page: secondPage, bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height));
    currentTop += 150;


    secondPage.graphics.drawString(
      'Listelenen ve sitede gösterilen hizmetler güncelleme yapılana ve değişene kadar üzerinde belirtilen fiyatlar geçerlidir. Listelenen ve sitede gösterilen hizmet/satış ve fiyatlar alıcı tarafından kabul ve beyan edilir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      'MADDE 5 - ÜCRET KAPSAMI VE UYGULAMASI',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "3. maddede tanımlanan iş adına belirlenen ücret ( reklamın sitede yayınlanma süresi ) geçerlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 6 – SÖZLEŞME BEDELİ VE ÖDEMELER',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "5.1. Malın /Ürün/Ürünlerin/ Hizmetin temel özelliklerini (türü, miktarı, marka/modeli, rengi, adedi) SATICI’ya ait internet sitesinde yayınlanmaktadır. Satıcı tarafından kampanya düzenlenmiş ise ilgili ürünün temel özelliklerini kampanya süresince inceleyebilirsiniz. Kampanya tarihine kadar geçerlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      "5.1. Malın /Ürün/Ürünlerin/ Hizmetin temel özelliklerini (türü, miktarı, marka/modeli, rengi, adedi) SATICI’ya ait internet sitesinde yayınlanmaktadır. Satıcı tarafından kampanya düzenlenmiş ise ilgili ürünün temel özelliklerini kampanya süresince inceleyebilirsiniz. Kampanya tarihine kadar geçerlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      "5.1. Malın /Ürün/Ürünlerin/ Hizmetin temel özelliklerini (türü, miktarı, marka/modeli, rengi, adedi) SATICI’ya ait internet sitesinde yayınlanmaktadır. Satıcı tarafından kampanya düzenlenmiş ise ilgili ürünün temel özelliklerini kampanya süresince inceleyebilirsiniz. Kampanya tarihine kadar geçerlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 7 - ANLAŞMANIN SONA ERDİRİLMESİ',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "5.1. Malın /Ürün/Ürünlerin/ Hizmetin temel özelliklerini (türü, miktarı, marka/modeli, rengi, adedi) SATICI’ya ait internet sitesinde yayınlanmaktadır. Satıcı tarafından kampanya düzenlenmiş ise ilgili ürünün temel özelliklerini kampanya süresince inceleyebilirsiniz. Kampanya tarihine kadar geçerlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 8 - GİZLİLİK',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      'Osmanbaba.net , Reklamveren\'in kendisine vermiş olduğu satış, reklam, ürün geliştirme ve araştırma faaliyetleri ve planlarını yansıtan rakamlar ve diğer bilgiler de dahil olmak üzere tüm yazılı veya sözlü bilgilerin gizli belgeler olduğunu kabul eder ve tüm bilgileri, dokümanları, veri ve know howı daima gizli tutar ve bunun için tüm tedbirleri alır.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 60;

    secondPage.graphics.drawString(
      'MADDE 9- UYUŞMAZLIKLARIN ÇÖZÜMÜ',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      'İşbu Sözleşme ile ilgili olarak çıkabilecek ihtilaflarda öncelikle bu sözleşmedeki hükümler uygulanacak olup, bu sözleşmede hüküm bulunmayan hallerde ise; ilgili mevzuat hükümleri uygulanır. Taraflar işbu sözleşmeden doğabilecek ihtilaflarda OSMANBABA.NET’in defter ve kayıtları ile bilgisayar kayıtlarının HMK 193. maddesi anlamında muteber, bağlayıcı, kesin ve münhasır delil teşkil edeceğini ve bu maddenin Delil Sözleşmesi niteliğinde olduğunu, belirtilen OSMANBABA.NET kayıtlarının usulüne uygun tutulduğunu kabul, beyan ve taahhüt ederler \n\nBu sözleşme, Türkiye Cumhuriyeti kanunlarına tabidir ve Türkiye Cumhuriyeti kanunlarına göre yorumlanacaktır. Bu sözleşmeden doğacak her türlü uyuşmazlıkta Şanlıurfa  Mahkemeleri ve İcra Müdürlükleri yetkilidir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    /////////////////// THIRD PAGE ////////////////////////////////

    currentTop = 0;

    thirdPage.graphics.drawString(
      'MADDE 10 - ELEKTRONİK TİCARİ İLETİLER',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    thirdPage.graphics.drawString(
      'İşbu Sözleşme ile ilgili olarak çıkabilecek ihtilaflarda öncelikle bu sözleşmedeki hükümler uygulanacak olup, bu sözleşmede hüküm bulunmayan hallerde ise; ilgili mevzuat hükümleri uygulanır. Taraflar işbu sözleşmeden doğabilecek ihtilaflarda OSMANBABA.NET’in defter ve kayıtları ile bilgisayar kayıtlarının HMK 193. maddesi anlamında muteber, bağlayıcı, kesin ve münhasır delil teşkil edeceğini ve bu maddenin Delil Sözleşmesi niteliğinde olduğunu, belirtilen OSMANBABA.NET kayıtlarının usulüne uygun tutulduğunu kabul, beyan ve taahhüt ederler \n\nBu sözleşme, Türkiye Cumhuriyeti kanunlarına tabidir ve Türkiye Cumhuriyeti kanunlarına göre yorumlanacaktır. Bu sözleşmeden doğacak her türlü uyuşmazlıkta Şanlıurfa  Mahkemeleri ve İcra Müdürlükleri yetkilidir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;




  }

  Future<List<int>> _readFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<List<int>> _readBoldFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<List<int>> _readItalicFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

}
