import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';
import 'mobile.dart';


class Payment extends StatefulWidget {

  final String _firstName;
  final String _secondName;
  final String _tc;
  final String _phoneNum;
  final String price;
  final String name;



  Payment(this._firstName, this._secondName, this._tc, this._phoneNum, this.price, this.name);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  final _advancedDrawerController = AdvancedDrawerController();
  List<Map<String, dynamic>> languageList = [];
  List<Map<String, dynamic>> kindList = [];
  final List<String> dropdownNameItems=[""];
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  bool issend = false;


  String cardNumber = '';
  String expiryDate= '';
  String cardHolderName = '';
  String cvvCode= '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool cardInfo = false;


  void onCreditCardModelChange(CreditCardModel creditCardModel){
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  String lang(){

    switch(Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode){

      case "en": return "English";
      break;
      case "ar": return "Arabic";
      break;
      case "tr" : return "Turkish";
      break;
    }
    return "Turkish";

  }

  String langShort(val){

    switch(val){

      case "English": return "en";
      break;
      case "Arabic": return "ar";
      break;
      case "Turkish" : return "tr";
      break;
    }
    return "tr";

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
      'Adresi: ',
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
      "companyName",
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
      "companyAddress",
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
      widget._phoneNum,
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
      "companyEmail",
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
      "companyTaxNumber",
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
    row.cells[0].value = widget.name;
    row.cells[1].value = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    row.cells[2].value = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().add(Duration(days: 356)).year}";
    row.cells[3].value = widget.price;

    grid.draw(page: secondPage, bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height));
    currentTop += 100;


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

  Future<void> storeLanguagePreference(val) async {
    print(
        '___SECOND storeLanguagePreference: val: ' + val + ' ' + langMap[val]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);

    print('___SECOND storeLanguagePreference: Glocale: ' +
        globalLocale.languageCode.toString() +
        ' ' +
        globalLocale.countryCode.toString());

    await prefs.setString('languageCode', globalLocale.languageCode);
    await prefs.setString('countryCode', globalLocale.countryCode);
    await prefs.setBool('isLanguageSpecified', true);
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async{
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];
    final response = await http.get(Uri.parse(webURL + 'api/ListCategory')).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        isLoading = false;
        _fabState = 0;
        _state = 0;
      });


      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'),
          //                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      throw TimeoutException('The connection has timed out, Please try again!');
    });


    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      var currentRecord;
      setState(() {
        for(int i = 0; i < decoded.length; i++) {
          currentRecord = decoded[i];
          categoryNamesList.add(decoded[i]["name_" + currentLocale].trim());
          while(currentRecord["applicationCategory1"] != null ) {
            currentRecord = currentRecord["applicationCategory1"];
            categoryNamesList.add(currentRecord["name_" + currentLocale].trim());
          }
          if(currentRecord["applicationCategory1"] == null && !primaryCategoryNames.contains(currentRecord["name_" + currentLocale].trim())) {
            print("ffffffffffffffff " + currentRecord["name_" + currentLocale]);
            primaryCategoryNames.add(currentRecord["name_" + currentLocale].trim());
            primaryCategories.add({
              "name": currentRecord["name_" + currentLocale],
              "id": currentRecord["id"],
//              webURL + json.decode(decoded["result"][i]["productImage"])["1"].toString(),
              "image": webURL + json.decode(currentRecord["image"])["1"].toString()
            });
          }
        }
      });
      return primaryCategories;
    } else {
      throw Exception('Failed to load');
    }
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  Future<List<String>> getLanguage() async{
    final url = await http.get(Uri.parse(webURL + 'api/ListLanguage'));
    languageList=[];
    var response=jsonDecode(url.body);
    if(response['status']){
      for(int i = 0; i < response["description"].length; i++){
        languageList.add(
            {
              "id": response["description"][i]["id"],
              "name": response["description"][i]["name_" + globalLocale.toString().substring(0, 2)]
            }
        );
        print(languageList[i]);


        // price=kindList[i]['price'];
        //return response;
      }
    }
  }

  Future<List<String>> getKind() async{
    final url = await http.get(Uri.parse(webURL + 'api/ListKind'));
    kindList=[];
    var response=jsonDecode(url.body);
    if(response['status']){
      for(int i = 0; i < response.length; i++){
        kindList.add(
            {
              "id": response["description"][i]["id"],
              "name": response["description"][i]["name_" + globalLocale.toString().substring(0, 2)],
              "price": response["description"][i]["price"]
            }
        );
        print(kindList[i]);
        dropdownNameItems.add(kindList[i]["name"]);
        print(dropdownNameItems[i]);


        // price=kindList[i]['price'];
        //return response;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget._firstName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
        Locale('ar', 'SAR'),
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: isLanguageSpecified ? globalLocale : null,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.orange,
        ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),
          home:  AdvancedDrawer(
          backdropColor: Colors.orange,
          controller: _advancedDrawerController,
          animationCurve: Curves.easeInOut,
          openRatio: 0.5,
          animationDuration: const Duration(milliseconds: 300),
          animateChildDecoration: true,
          rtlOpening: Localizations.localeOf(context).toString() == 'ar_SAR' ? true : false ,
          disabledGestures: false,
          childDecoration: const BoxDecoration(

          borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: appbar(context,_advancedDrawerController),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(20), //padding of outer Container
                  child: DottedBorder(
                    color: Colors.orange,//color of dotted/dash line
                    strokeWidth: 3, //thickness of dash/dots
                    dashPattern: [10,6],
                    //dash patterns, 10 is dash width, 6 is space width
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                widget.price,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tcNo')),
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                widget._tc,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('FSName')),
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget._firstName,
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                  ),
                                  Text(" "),
                                  Text(
                                    widget._secondName,
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('phoneNo')),
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                widget._phoneNum,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('address')),
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Şanlıurfa",
                                style: TextStyle(fontSize: 12 , color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 30,),
                          Container(
                              margin: EdgeInsets.only(left: 50, right: 50),
                              child: Divider(color: Colors.orange,)),
                          SizedBox(height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total')),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              Text(
                                widget.price,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  )
              ),
              Column(
                children: [
                  Container(
                    height: 200,
                    margin: EdgeInsets.only(top: 20),
                    child: CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      cardBgColor: Color.fromRGBO(46, 96, 113, 1),
                    ),
                  ),
                  Column(
                    children: [
                      CreditCardForm(
                        themeColor: Colors.orange,
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        onCreditCardModelChange: onCreditCardModelChange,
                        formKey: formKey,
                        cardNumberDecoration: InputDecoration(
                          enabledBorder: new OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.orange ),

                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.orange ),

                          ),
                          labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cardNumber')),
                          labelStyle: TextStyle(color: Colors.black26, fontSize: 12),
                          hintText: 'xxxx xxxx xxxx xxxx',
                        ),
                        expiryDateDecoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ValidDate')),
                            labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                            hintText: 'xx/xx'
                        ),
                        cvvCodeDecoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cvv')),
                            labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                            hintText: 'xxx'
                        ),
                        cardHolderDecoration: InputDecoration(
                          enabledBorder: new OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.orange ),

                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.orange ),

                          ),
                          labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CardholderName')),
                          labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: issend,
                              onChanged: (bool value) {
                                setState(() {
                                  issend = value;
                                });
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: RichText(
                                  text:  TextSpan(
                                      text: 'I Read', style: TextStyle(
                                    color: Color.fromRGBO(46, 96, 113, 1) ,
                                  ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' Advertising Agreement ', style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _createPdf();
                                              }
                                        ),
                                        TextSpan(
                                            text: ' and ', style: TextStyle(
                                          color: Color.fromRGBO(46, 96, 113, 1) ,
                                        ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: ' Privacy Policy ', style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                  decoration: TextDecoration.underline
                                              ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      launch('https://osmanbaba.net/Privacy');
                                                    }
                                              ),
                                              TextSpan(
                                                text: ' and Accept it ', style: TextStyle(
                                                color: Color.fromRGBO(46, 96, 113, 1) ,
                                              ),
                                              )
                                            ]
                                        )
                                      ]
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30,),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.orange) ),
                          onPressed: (){},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18.0,
                                semanticLabel: 'Text to announce in accessibility modes',
                              ),
                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('next')),
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
       drawer: Drawers(),
    ),
    debugShowCheckedModeBanner: false,
    );
  }
}
