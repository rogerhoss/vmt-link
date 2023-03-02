import 'package:cloud_firestore/cloud_firestore.dart';

// Recursive function to add a visibility and its subcategories to Firestore
Future<void> addVisibility(
    CollectionReference<Map<String, dynamic>> countriesCollectionRef,
    Map<String, dynamic> visibility) async {
  final docRef = countriesCollectionRef.doc(visibility['name'].toString());
  final subNationals = visibility['subnationals'] as List<dynamic>;

  await docRef.set({'name': visibility['name'].toString()});

  for (final subNational in subNationals) {
    await addSubNational(docRef.collection('subnationals'), subNational);
  }
}

// Recursive function to add a subnational and its locals to Firestore
Future<void> addSubNational(
    CollectionReference<Map<String, dynamic>> parentDocRef,
    Map<String, dynamic> subNational) async {
  final docRef = parentDocRef.doc(subNational['name'].toString());
  final locals = subNational['locals'] as List<dynamic>;

  await docRef.set({'name': subNational['name'].toString()});

  for (final local in locals) {
    await addLocal(docRef.collection('locals'), local);
  }
}

// Recursive function to add a local and its chapters to Firestore
Future<void> addLocal(CollectionReference<Map<String, dynamic>> parentDocRef,
    Map<String, dynamic> local) async {
  final docRef = parentDocRef.doc(local['name'].toString());
  final chapters = local['chapters'] as List<dynamic>;

  await docRef.set({'name': local['name'].toString()});

  for (final chapter in chapters) {
    await addChapter(docRef.collection('chapters'), chapter);
  }
}

// Function to add a chapter to Firestore
Future<void> addChapter(CollectionReference<Map<String, dynamic>> parentDocRef,
    Map<String, dynamic> chapter) async {
  final docRef = parentDocRef.doc(chapter['name'].toString());

  await docRef.set({'name': chapter['name'].toString()});
}

// Add the visibility hierarchy to Firestore
Future<void> addVisibilityHierarchy() async {
// Define the visibility hierarchy
  final visbilityArray = {
    'name': 'United States',
    'subnationals': [
      {
        'name': 'California',
        'locals': [
          {
            'name': 'San Jose',
            'chapters': [
              {'name': 'SJSU'},
            ],
          },
        ],
      },
      {
        'name': 'Florida',
        'locals': [
          {
            'name': 'Tallahassee',
            'chapters': [
              {'name': 'Tallahassee'},
            ],
          },
          {
            'name': 'Palm Beach',
            'chapters': [
              {'name': 'FAU'},
              {'name': '1909'},
            ],
          },
          {
            'name': 'Broward',
            'chapters': [
              {'name': 'NSU'},
            ],
          },
          {
            'name': 'Miami',
            'chapters': [
              {'name': 'Miami'},
            ],
          },
        ],
      },
      {
        'name': 'Tennessee',
        'locals': [
          {
            'name': 'Nashville',
            'chapters': [
              {'name': 'Vanderbilt'},
            ],
          },
        ],
      },
    ],
  };
  // final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final visibilityCollectionRef =
      FirebaseFirestore.instance.collection('visibility');
  final CollectionReference<Map<String, dynamic>> countriesCollectionRef =
      visibilityCollectionRef.doc('earth').collection('countries');

  await addVisibility(
    countriesCollectionRef,
    visbilityArray,
  );
  print('Visibility hierarchy added to Firestore');
}
