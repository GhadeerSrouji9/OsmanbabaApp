// import 'package:flutter/material.dart';
//
//
// void main() => runApp(FacebookApp());
//
// class FacebookApp extends StatefulWidget {
//   const FacebookApp({Key key}) : super(key: key);
//
//   @override
//   _FacebookAppState createState() => _FacebookAppState();
// }
//
// class _FacebookAppState extends State<FacebookApp> {
//   Map _userData;
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//             title:  Text('Facebook (Logged ' + (_userData == null ? 'Out' : 'In') + ')')
//         ),
//         body: Center(
//           child: Column(
//             children: [
//               ElevatedButton(child: Text('Log In'), onPressed: () async {
//
//                 final result = await FacebookAuth.i.login(
//                     permissions: ["public_profile", "email"]
//                 );
//
//                 if (result.status == LoginStatus.success) {
//
//                   final userData = await FacebookAuth.i.getUserData(
//                     fields: "email,name",
//                   );
//
//                   setState(() {
//                     _userData = userData;
//                   });
//
//                 }
//
//               }),
//               ElevatedButton(child: Text('Log Out'), onPressed: ()async {
//                 await FacebookAuth.i.logOut();
//
//                 setState(() {
//                   _userData = null;
//                 });
//               }),
//             ],
//           ), // Column
//         ), // Center
//       ),
//     );
//   }
// }