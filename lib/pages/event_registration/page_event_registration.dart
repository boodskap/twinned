// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:nocode_commons/core/user_session.dart';
// import 'package:twinned/pages/widgets/eventregistrationdialog.dart';
// import 'package:twinned_api/api/twinned.swagger.dart';
//
// class EvenstRegisterPage extends StatefulWidget {
//   const EvenstRegisterPage({Key? key}) : super(key: key);
//
//   @override
//   State<EvenstRegisterPage> createState() => _EvenstRegisterPageState();
// }
//
// class _EvenstRegisterPageState extends State<EvenstRegisterPage> {
//   late Image bannerImage;
//
//   List<Map<String, dynamic>> eventsData = [];
//   List<Map<String, dynamic>> _eventsList = [];
//
//   bool _notificationCheckbox = false;
//   bool _emailCheckbox = false;
//   bool _smsCheckbox = false;
//   bool _voiceCheckbox = false;
//   bool _fcmCheckbox = false;
//
//   get registrationType => "Email";
//
//   int _currentPage = 1;
//   int _selectedRowsPerPage = 10;
//   List<int> _rowsPerPageOptions = [10, 20, 50, 100];
//
//   void _onRowsPerPageChanged(int? newRowsPerPage) {
//     if (newRowsPerPage != null) {
//       setState(() {
//         _selectedRowsPerPage = newRowsPerPage;
//         _currentPage = 1;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     bannerImage = Image.asset(
//       'assets/images/ldashboard_banner.png',
//       fit: BoxFit.cover,
//     );
//     _loadEventRegistrations();
//   }
//
//   Future<void> _loadEventRegistrations() async {
//     List<EventRegistrationListRegistrationTypePostRegistrationType>
//         registrationTypes = [
//       EventRegistrationListRegistrationTypePostRegistrationType.notification,
//       EventRegistrationListRegistrationTypePostRegistrationType.email,
//       EventRegistrationListRegistrationTypePostRegistrationType.sms,
//       EventRegistrationListRegistrationTypePostRegistrationType.voice,
//       EventRegistrationListRegistrationTypePostRegistrationType.fcm,
//     ];
//
//     List<Map<String, dynamic>> allEventsData = [];
//
//     for (var registrationType in registrationTypes) {
//       try {
//         var res = await UserSession.twin.listEventRegistrations(
//           registrationType: registrationType,
//           apikey: UserSession().getAuthToken(),
//           body: ListReq(page: 0, size: 1000),
//         );
//
//         var uniqueEvents = res.body?.values?.where((event) =>
//             !allEventsData.any(
//                 (existingEvent) => existingEvent["id"] == event.id.toString()));
//
//         allEventsData.addAll(uniqueEvents?.map<Map<String, dynamic>>((event) {
//               return {
//                 "id": event.id,
//                 "name": event.name,
//                 "rtype": event.rtype,
//                 "eventId": event.eventId,
//                 "notification": event.notification,
//                 "email": event.email,
//                 "sms": event.sms,
//                 "voice": event.voice,
//                 "fcm": event.fcm,
//                 "emailId": event.emailId,
//                 "phoneNumber": event.phoneNumber,
//               };
//             })?.toList() ??
//             []);
//       } catch (e, x) {
//         debugPrint('$e');
//         debugPrint('$x');
//       }
//     }
//
//     setState(() {
//       eventsData = allEventsData;
//     });
//   }
//
//   void _updatePage(int newPage) {
//     setState(() {
//       _currentPage = newPage;
//     });
//     _loadEventRegistrations();
//   }
//
//   List<Map<String, dynamic>> _getPageData(int startIndex, int endIndex) {
//     int adjustedEndIndex =
//         endIndex < eventsData.length ? endIndex : eventsData.length;
//
//     return eventsData.sublist(startIndex, adjustedEndIndex);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int startIndex = (_currentPage - 1) * _selectedRowsPerPage;
//     int endIndex = startIndex + _selectedRowsPerPage;
//
//     List<Map<String, dynamic>> currentPageData =
//         _getPageData(startIndex, endIndex);
//
//     currentPageData = currentPageData.asMap().entries.map((entry) {
//       int index = entry.key;
//       Map<String, dynamic> eventData = entry.value;
//       eventData['serialNumber'] = index + 1;
//       return eventData;
//     }).toList();
//
//     return Material(
//       child: Column(
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: 150,
//             child: bannerImage,
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: DataTable(
//                   columns: const [
//                     DataColumn(label: Text('S.No')),
//                     DataColumn(label: Text('Event ID')),
//                     DataColumn(label: Text('Notification')),
//                     DataColumn(label: Text('Email')),
//                     DataColumn(label: Text('SMS')),
//                     DataColumn(label: Text('Voice')),
//                     DataColumn(label: Text('FCM')),
//                     DataColumn(label: Text('Email ID')),
//                     DataColumn(label: Text('Phone Number')),
//                     DataColumn(label: Text('')),
//                     DataColumn(label: Text('Clear')),
//                   ],
//                   rows: currentPageData.map((eventData) {
//                     int overallIndex = eventsData.indexOf(eventData);
//                     eventData['serialNumber'] = overallIndex + 1;
//                     TextEditingController emailController =
//                         TextEditingController(text: eventData["emailId"] ?? "");
//                     TextEditingController phoneNumberController =
//                         TextEditingController(
//                             text: eventData["phoneNumber"] ?? "");
//                     Future<void> updateeventreg(
//                         Map<String, dynamic> eventData) async {
//                       try {
//                         String eventRegistrationId = eventData["id"].toString();
//                         String eventId = eventData["eventId"].toString();
//                         bool notification = eventData["notification"] as bool;
//                         bool email = eventData["email"] as bool;
//                         bool sms = eventData["sms"] as bool;
//                         bool voice = eventData["voice"] as bool;
//                         bool fcm = eventData["fcm"] as bool;
//                         String emailId = emailController.text;
//                         String phoneNumber = phoneNumberController.text;
//                         String name = eventData["name"].toString();
//
//                         EventRegistrationInfo info = EventRegistrationInfo(
//                           eventId: eventId,
//                           notification: notification,
//                           email: email,
//                           sms: sms,
//                           voice: voice,
//                           fcm: fcm,
//                           emailId: email ? emailId : null,
//                           phoneNumber: (sms || voice) ? phoneNumber : null,
//                           name: name,
//                           targetDeviceIds: null,
//                           tags: null,
//                         );
//
//                         var res =
//                             await UserSession.twin.updateEventRegistration(
//                           eventRegistrationId: eventRegistrationId,
//                           apikey: UserSession().getAuthToken(),
//                           body: info,
//                         );
//                         if (res.body?.ok == true) {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: Text('Success'),
//                                 content: Text('Updated successfully.'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                           _loadEventRegistrations();
//                         } else {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: Text('Error'),
//                                 content: Text(res.body!.msg.toString()),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         }
//                       } catch (e, s) {
//                         debugPrint('$e');
//                         debugPrint('$s');
//                       }
//                     }
//
//                     return DataRow(
//                       cells: [
//                         DataCell(Text(eventData["serialNumber"].toString())),
//                         DataCell(Text(eventData["name"].toString())),
//                         DataCell(_buildCheckbox(
//                           eventData["notification"] as bool,
//                           (value) {
//                             setState(() {
//                               eventData["notification"] = value;
//                             });
//                             updateeventreg(eventData);
//                           },
//                         )),
//                         DataCell(_buildCheckbox(
//                           eventData["email"] as bool,
//                           (value) {
//                             setState(() {
//                               eventData["email"] = value;
//
//                               if (value == true) {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Required'),
//                                       content: Text('Please Enter Email ID'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               } else {
//                                 emailController.clear();
//                                 updateeventreg(eventData);
//                               }
//                             });
//                           },
//                         )),
//                         DataCell(_buildCheckbox(
//                           eventData["sms"] as bool,
//                           (value) {
//                             setState(() {
//                               eventData["sms"] = value;
//                               if (value == true) {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Required'),
//                                       content:
//                                           Text('Please Enter Mobile Number'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               } else {
//                                 emailController.clear();
//                                 updateeventreg(eventData);
//                               }
//                             });
//                           },
//                         )),
//                         DataCell(_buildCheckbox(
//                           eventData["voice"] as bool,
//                           (value) {
//                             setState(() {
//                               eventData["voice"] = value;
//                               if (value == true) {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Required'),
//                                       content:
//                                           Text('Please Enter Mobile Number'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               } else {
//                                 emailController.clear();
//                                 updateeventreg(eventData);
//                               }
//                             });
//                           },
//                         )),
//                         DataCell(_buildCheckbox(
//                           eventData["fcm"] as bool,
//                           (value) {
//                             setState(() {
//                               eventData["fcm"] = value;
//                             });
//                             updateeventreg(eventData);
//                           },
//                         )),
//                         DataCell(
//                           TextFormField(
//                             controller: emailController,
//                             enabled: eventData["email"] as bool,
//                           ),
//                         ),
//                         DataCell(
//                           TextFormField(
//                             controller: phoneNumberController,
//                             enabled: eventData["sms"] as bool ||
//                                 eventData["voice"] as bool,
//                           ),
//                         ),
//                         DataCell(
//                           ElevatedButton(
//                             onPressed: () {
//                               updateeventreg(eventData);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               primary: Colors.green,
//                             ),
//                             child: const Text(
//                               'Save',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataCell(
//                           ElevatedButton(
//                             onPressed: () async {
//                               setState(() {
//                                 eventData["notification"] = false;
//                                 eventData["email"] = false;
//                                 eventData["sms"] = false;
//                                 eventData["voice"] = false;
//                                 eventData["fcm"] = false;
//                                 eventData["emailId"] = '';
//                                 eventData["phoneNumber"] = '';
//                               });
//                               await updateeventreg(eventData);
//                             },
//                             child: Text('Clear'),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           CustomPagination(
//             total: eventsData.length,
//             rowsPerPage: _selectedRowsPerPage,
//             currentPage: _currentPage,
//             onPageChanged: _updatePage,
//             onRowsPerPageChanged: _onRowsPerPageChanged,
//             rowsPerPageOptions: _rowsPerPageOptions,
//             selectedRowsPerPage: _selectedRowsPerPage,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildCheckbox(bool value, void Function(bool?)? onChanged) {
//   return Checkbox(
//     value: value,
//     onChanged:
//         onChanged != null ? (bool? newValue) => onChanged(newValue) : null,
//   );
// }
//
// class CustomPagination extends StatelessWidget {
//   final int total;
//   final int rowsPerPage;
//   final int currentPage;
//   final ValueChanged<int> onPageChanged;
//   final ValueChanged<int?> onRowsPerPageChanged;
//   final List<int> rowsPerPageOptions;
//   final int selectedRowsPerPage;
//
//   CustomPagination({
//     required this.total,
//     required this.rowsPerPage,
//     required this.currentPage,
//     required this.onPageChanged,
//     required this.onRowsPerPageChanged,
//     required this.rowsPerPageOptions,
//     required this.selectedRowsPerPage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     int totalPages = (total / rowsPerPage).ceil();
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text('Total: $total'),
//           Row(
//             children: [
//               DropdownButton<int>(
//                 value: selectedRowsPerPage,
//                 items: rowsPerPageOptions.map((int value) {
//                   return DropdownMenuItem<int>(
//                     value: value,
//                     child: Text('$value'),
//                   );
//                 }).toList(),
//                 onChanged: onRowsPerPageChanged,
//               ),
//               SizedBox(width: 16.0),
//               Text('Page $currentPage of $totalPages'),
//               IconButton(
//                 icon: Icon(Icons.first_page),
//                 onPressed: () => onPageChanged(1),
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_left),
//                 onPressed: currentPage > 1
//                     ? () => onPageChanged(currentPage - 1)
//                     : null,
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right),
//                 onPressed: currentPage < totalPages
//                     ? () => onPageChanged(currentPage + 1)
//                     : null,
//               ),
//               IconButton(
//                 icon: Icon(Icons.last_page),
//                 onPressed: () => onPageChanged(totalPages),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
