import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../../model/User.dart';
import '../../model/VisibilityModel.dart';
import '../../model/ChaptersModel.dart';

class TestScreen extends StatefulWidget {
  final User user;

  const TestScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late User user;

  Object? get myVisibilityMap => null;
  // late Future<List<User>> _friendsFuture;

  Future<void> _showListDialog() async {
    user = widget.user;

    List<VisibilityObject> myVisibilityMap =
        await getFilterOptions(user.chapter, user.visibilityCeiling);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  contentPadding: EdgeInsets.all(8.0),
                  title: Text('Set Filter'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var data in myVisibilityMap)
                        GFCheckboxListTile(
                          titleText: data.name,
                          subTitleText: data.subtitle,
                          avatar: GFAvatar(
                            backgroundImage: NetworkImage(data.icon),
                            shape: GFAvatarShape.square,
                            backgroundColor: Colors.white,
                          ),
                          size: 25,
                          activeBgColor: Colors.green,
                          type: GFCheckboxType.circle,
                          activeIcon: Icon(
                            Icons.check,
                            size: 15,
                            color: Colors.white,
                          ),
                          value: data.value,
                          onChanged: (bool newValue) {
                            setState(() {
                              data.value = newValue;
                            });
                          },
                          inactiveIcon: null,
                        ),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// New test code here
  Future<void> _chapterGet() async {
    user = widget.user;

    var chapter = await getChapterInfo('dn5Kp6XUlYWzPa1JyC7N');
    // print(user.userID);

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print('Ready to Run');
            _chapterGet();
            // _showListDialog();
          },
          child: Text('Show List'),
        ),
      ),
    );
  }
}


// class _TestScreenState extends State<TestScreen> {
//   bool value1 = false;
//   bool value2 = false;
//   bool value3 = false;
//   bool value4 = false;
//   bool value5 = false;
//   late User user;

//   Future<void> _showListDialog() async {
//     user = widget.user;
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Center(
//               child: SingleChildScrollView(
//                 child: AlertDialog(
//                   contentPadding: EdgeInsets.all(8.0),
//                   title: Text('Set Filter'),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       GFCheckboxListTile(
//                         titleText: 'Arthur Shelby',
//                         subTitleText: user.lastName,
//                         avatar: GFAvatar(
//                           backgroundImage: NetworkImage(
//                               'https://one.fsu.edu/alumni/image/FSU-Seal-full-color-lo-res1.jpg'),
//                         ),
//                         size: 25,
//                         activeBgColor: Colors.green,
//                         type: GFCheckboxType.circle,
//                         activeIcon: Icon(
//                           Icons.check,
//                           size: 15,
//                           color: Colors.white,
//                         ),
//                         value: value1,
//                         onChanged: (bool newValue) {
//                           setState(() {
//                             value1 = newValue;
//                           });
//                         },
//                         inactiveIcon: null,
//                       ),
//                       GFCheckboxListTile(
//                         titleText: "Option 2",
//                         subTitleText: "Select option 2",
//                         value: value2,
//                         onChanged: (newValue) {
//                           setState(() {
//                             value2 = newValue;
//                           });
//                         },
//                       ),
//                       GFCheckboxListTile(
//                         titleText: "Option 3",
//                         subTitleText: "Select option 3",
//                         value: value3,
//                         onChanged: (newValue) {
//                           setState(() {
//                             value3 = newValue;
//                           });
//                         },
//                       ),
//                       GFCheckboxListTile(
//                         titleText: "Option 4",
//                         subTitleText: "Select option 4",
//                         value: value4,
//                         onChanged: (newValue) {
//                           setState(() {
//                             value4 = newValue;
//                           });
//                         },
//                       ),
//                       GFCheckboxListTile(
//                         titleText: "Option 5",
//                         subTitleText: "Select option 5",
//                         value: value5,
//                         onChanged: (newValue) {
//                           setState(() {
//                             value5 = newValue;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   actions: <Widget>[
//                     ElevatedButton(
//                       child: Text('Cancel'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     ElevatedButton(
//                       child: Text('Ok'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _showListDialog();
//           },
//           child: Text('Show List'),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:getwidget/getwidget.dart';

// class TestScreen extends StatefulWidget {
//   const TestScreen({Key? key}) : super(key: key);

//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   bool value1 = false;
//   bool value2 = false;
//   bool value3 = false;
//   bool value4 = false;
//   bool value5 = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               GFCheckboxListTile(
//                 titleText: 'Arthur Shelby',
//                 subTitleText: 'By order of the peaky blinders',
//                 avatar: GFAvatar(
//                   backgroundImage: NetworkImage(
//                       'https://one.fsu.edu/alumni/image/FSU-Seal-full-color-lo-res1.jpg'),
//                 ),
//                 size: 25,
//                 activeBgColor: Colors.green,
//                 type: GFCheckboxType.circle,
//                 activeIcon: Icon(
//                   Icons.check,
//                   size: 15,
//                   color: Colors.white,
//                 ),
//                 value: value1,
//                 onChanged: (newValue) {
//                   setState(() {
//                     value1 = newValue;
//                   });
//                 },
//                 inactiveIcon: null,
//               ),
//               CheckboxListTile(
//                 title: Text('Option 2'),
//                 subtitle: Text('Select option 2'),
//                 value: value2,
//                 onChanged: (newValue) {
//                   setState(() {
//                     value2 = newValue!;
//                   });
//                 },
//               ),
//               CheckboxListTile(
//                 title: Text('Option 3'),
//                 subtitle: Text('Select option 3'),
//                 value: value3,
//                 onChanged: (newValue) {
//                   setState(() {
//                     value3 = newValue!;
//                   });
//                 },
//               ),
//               CheckboxListTile(
//                 title: Text('Option 4'),
//                 subtitle: Text('Select option 4'),
//                 value: value4,
//                 onChanged: (newValue) {
//                   setState(() {
//                     value4 = newValue!;
//                   });
//                 },
//               ),
//               CheckboxListTile(
//                 title: Text('Option 5'),
//                 subtitle: Text('Select option 5'),
//                 value: value5,
//                 onChanged: (newValue) {
//                   setState(() {
//                     value5 = newValue!;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }