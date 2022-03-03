import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async{
  print("11111");
  if(Platform.isAndroid){
    print("22222");
    final path =  (await getExternalStorageDirectory()).path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
  }else{
    print("33333");
    final path = await getApplicationSupportDirectory();
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
  }

}