import 'package:cloud_firestore/cloud_firestore.dart';

// import '../main.dart';
// import './ContactModel.dart';
// import '../ui/people/PeopleScreen.dart';
// import '../services/FirebaseHelper.dart';

Future<Map<String, dynamic>> getChapterInfo(String chapterId) async {
  final chapterDoc = await FirebaseFirestore.instance
      .collection('chapters')
      .doc(chapterId)
      .get();
  if (chapterDoc.exists) {
    final chapterData = chapterDoc.data();
    // print(chapterData);
    final membersSnapshot = await FirebaseFirestore.instance
        .collection('chapters')
        .doc(chapterId)
        .collection('users')
        .get();
    final memberIds = membersSnapshot.docs.map((doc) => doc.id).toList();
    // print(memberIds);
    return {
      'name': chapterData?['name'] ?? '',
      'subtitle': chapterData?['subtitle'] ?? '',
      'icon': chapterData?['icon'] ?? '',
      'members': memberIds,
    };
  } else {
    throw Exception('Chapter not found');
  }
}
