import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:osmanbaba/helpers/globals.dart';
class SwearPage extends StatefulWidget {
  SwearPage({Key  key}) : super(key: key);

  @override
  _SwearPageState createState() => _SwearPageState();
}
class _SwearPageState extends State<SwearPage> {

  File _file;//kimlik ön
  File _file1;//kimlik arka
  File _file2;//foto
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _adresController = TextEditingController();
  List<int> valueLanguage=[1,2,3];
  List<int> valueTranslate=[1,2,3];
  bool basildi = false;
  int index=0;
  int price = 0;
  int buttonSecimi;
  String sendType="0";
  bool v1=false;
  bool v2=false;

  int valueRadioButton = 0;
  int valueRadioButton1 = 1;
  //
  // we initialize the list with same elements
  List<Map<String, dynamic>> variables  = List.generate(10, (index) =>
  {
    "rdValue": [0, 0, 0],
    "cbValue": [false, false, false],
  });

  List<Map<String, dynamic>> kindList=[];
  //{"id":[1,2,3,4]},{"description":["IN","TR","AR","FR"]},{"price":[23,34,45,54]}
  List<bool> dosyaDili=List.generate(10, (index) => false);
  List<bool> ekle=List.generate(10, (index) => true);
  List<bool> dosyadiliSec=List.generate(10, (index) => false);
  List<bool> tercumeDili=List.generate(10, (index) => false);
  List<String> dropdownValue=List.generate(10, (index) => null);


  final List<String> dropdownNameItems=[];
  // void  deger(){
  //   dosyaDili=List.generate(index, (index) => false);
  //   ekle=List.generate(index, (index) => true);
  //   dosyadiliSec=List.generate(index, (index) => false);
  //   tercumeDili=List.generate(index, (index) => false);
  //   dropdownValue=List.generate(index, (index) => null);
  //    for(index=0;index>=-1;index++){
  //
  //      dosyaDili=List.generate(index, (index) => false);
  //      ekle=List.generate(index, (index) => true);
  //      dosyadiliSec=List.generate(index, (index) => false);
  //      tercumeDili=List.generate(index, (index) => false);
  //      dropdownValue=List.generate(index, (index) => null);
  //    }
  //  }

  Future<void> galeridenSec() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file = File(image.path);
    });
  }
  Future<void> galeridenSec1() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file1 = File(image.path);
    });
  }
  Future<void> galeridenSec2() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file2 = File(image.path);
    });
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


        // price=kindList[i]['price'];
        //return response;
      }
    }
  }

     Future<void> fetchDrop(String sendTypee,String fromLanguageID,String toLanguageID,String user,
      String email,String phone,String note,String kind,String iSNoter, String isVerfication,
      // String fromLanguageID1,String toLanguageID1,String note1, String kind1,
      // bool iSNoter1,bool isVerfication1,String state,String fileState,String fileState1
      ) async {
    final url = Uri.parse(webURL + "api/AddTranslateFile");
    var request = http.MultipartRequest(
        'POST', url
    );
    request.headers['Content-type'] ='multipart/form-data';
    request.headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiSG90aGVmYSIsIlJvbGUiOlsiVXNlciIsIlVzZXIiLCJVc2VyIiwiVXNlciJdLCJleHAiOjE2Mzg2MDU5NDEsImlzcyI6IkludmVudG9yeUF1dGhlbnRpY2F0aW9uU2VydmVyIiwiYXVkIjoiSW52ZW50b3J5U2VydmljZVBvdG1hbkNsaWVudCJ9.BAwEXBYK-A1aq7V-ErgkPw3L9WDra2o7pxkd9LNNG7w";
    request.fields['SendType'] = sendTypee;
    request.fields['fromLanguageID'] = "251e1834-a2b3-4a11-8f3e-452a90a63b82";
    request.fields['ToLanguageID'] = "aad22fa3-8c85-45ac-9c6f-f229053dc5b0";
    // request.fields['user'] = user;
    request.fields['Email'] = email;
    request.fields['phone'] = phone;
    request.fields['Note'] = note;
    request.fields['Kind'] = kind;
    request.fields['ISNoter'] =iSNoter;//"True";
    request.fields['IsVerfication'] = isVerfication;
    // request.fields['fromLanguageID'] = fromLanguageID1;
    // request.fields['ToLanguageID1'] = toLanguageID1;
    // request.fields['Note'] = note1;
    // request.fields['Kind'] = kind1;
    // request.fields['ISNoter'] = iSNoter1.toString();
    // request.fields['IsVerfication'] = isVerfication1.toString();
    // request.fields['state'] = state;
    request.fields['FileState'] = "0";
    // request.fields['FileState']=fileState1;
    request.files.add(
      http.MultipartFile('file',
          File(_file.path).readAsBytes().asStream(),File(_file.path).lengthSync(),
          filename: _file.path.split("/").last),
    );
    request.files.add(
      http.MultipartFile('file1',
          File(_file1.path).readAsBytes().asStream(),File(_file1.path).lengthSync(),
          filename: _file1.path.split("/").last),
    );
    request.files.add(
      http.MultipartFile(
          'PersonID',
          File(_file2.path).readAsBytes().asStream(),
          File(_file2.path).lengthSync(),
          filename: _file2.path.split("/").last),
    );
    // var multipart = [];
    // multipart.add(MultipartFile.fromBytes(
    //     "file",
    //    _file.readAsBytesSync())
    // Iterable<MultipartFile> iterable = [multipart[0], multipart[1], multipart[2]];
    // request.files.addAll(iterable);
    try{
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      print("tryyy try try: " + res.body.toString());
      Map<String, dynamic> dep = jsonDecode(utf8.decode(res.bodyBytes));
      if(dep["message"] == "Seccess") {
        print("stonksssss");
      }
    }
    catch(error) {
      print("ccccatch errrrrrrrrrrrror " + error.toString());
    }
  }

  dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {

      getKind();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Yeminli Tercüme", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.orange,),
        body: ListView(
            children: <Widget>[
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: 30,),
                  Text("Email",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),),
                  Container(
                      width: 200,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.orange,
                              width: 2
                          )
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                        ),))
                ],),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Text("Telefon",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),),
                  Container(
                      width: 200,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.orange,
                              width: 2
                          )
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                        ),))
                ],),
              SizedBox(height: 20,),

              adDocument(),


              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index++;
                    if (index == 0) {
                      dosyaDili[0] = true;
                    }
                    else if (index == 1) {
                      dosyaDili[1] = true;
                    }
                    else if (index == 2) {
                      dosyaDili[2] = true;
                    }
                    else if (index == 3) {
                      dosyaDili[3] = true;
                    }
                    else if (index == 4) {
                      dosyaDili[4] = true;
                    }
                    else if (index == 5) {
                      dosyaDili[5] = true;
                    }
                    else if (index == 6) {
                      dosyaDili[6] = true;
                    }
                    else if (index == 7) {
                      dosyaDili[7] = true;
                    }
                    else if (index == 8) {
                      dosyaDili[8] = true;
                    }
                    else if (index == 9) {
                      dosyaDili[9] = true;
                    }
                    else if (index == 10) {
                      dosyaDili[10] = true;
                    }
                  });
                },
                child: Container(
                  // margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange,
                  ),
                  width: 100,
                  height: 40,
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      SizedBox(width: 20,),
                      Icon(Icons.add_circle, color: Colors.black, size: 30,),
                      SizedBox(width: 70,),
                      Text("Yeni Dosya Ekle", style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),)
                    ],),),
              ),
              Container(
                  margin: EdgeInsets.only(left: 10), child: Text("Teslimat Yöntemi",
                  style: TextStyle(fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Radio(value: 1, groupValue: valueRadioButton, onChanged: (value) {
                    setState(() {
                      valueRadioButton = value;
                      sendType=0.toString();
                    });
                  },
                  ),
                  Text("Kargo Teslimat"),
                  Radio(value: 2, groupValue: valueRadioButton, onChanged: (value) {
                    setState(() {
                      valueRadioButton = value;
                      sendType=1.toString();
                    });
                  },),
                  Text("Kapıda Ödeme"),
                ],),
              Container(margin: EdgeInsets.all(10), child: Text("Adres",
                  style: TextStyle(fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
              SizedBox(height: 10,),
              Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  width: 200,
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.orange,
                          width: 2
                      )
                  ),
                  child: TextField(
                    controller: _adresController,
                    //keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                    ),)),
              Container(margin: EdgeInsets.all(2), child: Text("Toplam:",
                  style: TextStyle(fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(price.toString(), style: TextStyle(color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                    Container(
                        width: 100,
                        height: 30,
                        //margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(15),),
                        child: TextButton(
                            onPressed: () async{
                          String phone=_phoneController.text;
                          String email=_emailController.text;
                          String note=_adresController.text;
                          bool dosyadili=dosyaDili[index];
                          bool tercumedili=tercumeDili[index];
                          bool noter= v1;
                          bool verication=v2;
                          //bool cbox=variables[index][];
                          String item = kindList[index]["id"];
                          print("presssssssssssssssed " + item);
                          print("basıldı mı"+noter.toString());
                          print("basıldı mı"+verication.toString());
                          await fetchDrop(sendType,dosyadili.toString(),tercumedili.toString(),"ss",email,phone,note,item,noter.toString(), verication.toString());
                        },
                            child: Text("Onayla", style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),)))
                  ],),
              )
            ]
        )

    );

  }
  Widget addContainer(int indx) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 300,
      width: MediaQuery
          .of(context)
          .size
          .width - 10,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(30)
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10,),
          Container(margin: EdgeInsets.all(10), child: Text("Dosya Bilgileri",
            style: TextStyle(fontSize: 20,
                color: Colors.orange,
                fontWeight: FontWeight.bold),)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 5,),
              Text("Dosya Dili",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(width: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Radio(value: valueLanguage[0],
                    groupValue: variables[indx]["rdValue"][0],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][0] = value;
                        dosyadiliSec[indx] = true;
                      });
                    },),
                  Text("Türkçe"),
                  Radio(value: valueLanguage[1],
                    groupValue: variables[indx]["rdValue"][0],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][0] = value;
                        dosyadiliSec[indx] = true;
                      });
                    },),
                  Text("İngilizce"),
                  Radio(value: valueLanguage[2],
                    groupValue: variables[indx]["rdValue"][0],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][0] = value;
                        dosyadiliSec[indx] = true;
                      });
                    },),
                  SizedBox(width: 10,), Text("Arapça")
                ],),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Tercüme Dili",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Radio(value: valueTranslate[0],
                    groupValue: variables[indx]["rdValue"][1],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][1] = value;
                        tercumeDili[indx] = true;
                      });
                    },),
                  Text("Türkçe"),
                  Radio(value: valueTranslate[1],
                    groupValue: variables[indx]["rdValue"][1],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][1] = value;
                        tercumeDili[indx] = true;
                      });
                    },),
                  Text("İngilizce"),
                  Radio(value: valueTranslate[2],
                    groupValue: variables[indx]["rdValue"][1],
                    onChanged: (value) {
                      setState(() {
                        variables[indx]["rdValue"][1] = value;
                        tercumeDili[indx] = true;
                      });
                    },),
                  SizedBox(width: 10,), Text("Arapça")
                ],),
            ],
          ),
          adddropDown(indx),
          Container(
            margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Checkbox(value: variables[indx]["cbValue"][0],
                    onChanged: (value1) {
                      if (dosyadiliSec[indx] && tercumeDili[indx]) {
                        setState(() {
                          variables[indx]["cbValue"][0] = value1;
                          v1=value1;
                          print("chexbook degerim"+value1.toString());
                          if (variables[indx]["cbValue"][0]) {
                            price = price + 50;
                          }
                          else if (!variables[indx]["cbValue"][0]) {
                            price = price - 50;
                          }
                        });
                      }
                      else {
                        Fluttertoast.showToast(msg: "Lütfen dil seçiniz");
                      }
                    }),
                Text("Noter "),
                SizedBox(width: 120,),
                Checkbox(
                    value: variables[indx]["cbValue"][1], onChanged: (value2) {
                  if (dosyadiliSec[indx] && tercumeDili[indx]) {
                    setState(() {
                      variables[indx]["cbValue"][1] = value2;
                      v2=value2;
                      print("chexbook degerim"+value2.toString());
                      if (variables[indx]["cbValue"][1]) {
                        price = price + 10;
                      }
                      else if (!variables[indx]["cbValue"][1]) {
                        price = price - 10;
                      }
                    });
                  }
                  else {
                    Fluttertoast.showToast(msg: "Lütfen dil seçiniz");
                  }
                }),
                Text("Onay"),
              ],),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // SizedBox(width: 5,),
              GestureDetector(
                onTap:galeridenSec,
                child: Container(
                  width: 120,
                  height: 40,
                  color: Colors.orange,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.file_upload, color: Colors.black, size: 30,),
                      SizedBox(width: 10,),
                      Text("Dosya Sec", style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),)
                    ],),
                ),
              ),
              //SizedBox(height: 40,),
              GestureDetector(
                onTap:galeridenSec1,
                child: Container(
                  width: 120,
                  height: 40,
                  color: Colors.orange,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.file_upload, color: Colors.black, size: 30,),
                      SizedBox(width: 10,),
                      Text("Dosya Sec", style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),)
                    ],),
                ),
              ),
              GestureDetector(
                onTap: galeridenSec2,
                child: Container(
                  width: 120,
                  height: 40,
                  color: Colors.orange,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.file_upload, color: Colors.black, size: 30,),
                      SizedBox(width: 10,),
                      Text("Dosya Sec", style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),)
                    ],),
                ),
              ),
              Row(children: <Widget>[
              ],)
            ],),
        ],
      ),
    );
  }
  Row adddropDown(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(width: 5,),
        Text("Belge Türü",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        SizedBox(width: 20,),
        Container(
          width: 270,
          height: 45,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 2)
          ),
          child: DropdownButton<String>(
            iconSize: 30,
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            isExpanded: true,
            value: dropdownValue[i],
            items: dropdownNameItems.map((String item) {
              return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 20),));
            }).toList(),
            onTap: () {},
            onChanged: (value) {
              if (dosyadiliSec[i] && tercumeDili[i]) {
                setState(() {
                  this.dropdownValue[i] = value;
                  int selected = dropdownNameItems.indexOf(value);
                  if(ekle[index]) {
                    setState(() {
                      price = price + kindList[selected]["price"];
                    });
                    ekle[index]=false;
                  }
                  // if (items[0] == value&&ekle[0]) {
                  //   ekle[0]=false;
                  //   price = price + 40;
                  // }
                });
              }
              else {
                Fluttertoast.showToast(msg: "Lütfen dil seçiniz");
              }
            },
          ),
        )
      ],);
  }

  Widget adDocument() {

    addContainer(0);
    dosyaDili[0] == true ? addContainer(1) : SizedBox();
    dosyaDili[1] == true ? addContainer(2) : SizedBox();
    dosyaDili[2] == true ? addContainer(3) : SizedBox();
    dosyaDili[3] == true ? addContainer(4) : SizedBox();
    dosyaDili[4] == true ? addContainer(5) : SizedBox();
    dosyaDili[5] == true ? addContainer(6) : SizedBox();
    dosyaDili[6] == true ? addContainer(7) : SizedBox();
    dosyaDili[7] == true ? addContainer(8) : SizedBox();
    dosyaDili[8] == true ? addContainer(9) : SizedBox();
    dosyaDili[9] == true ? addContainer(10) :SizedBox();

  }
}