import 'package:cloud_firestore/cloud_firestore.dart';

//This is a complete test
class VisibilityObject {
  String type;
  String name;
  String subtitle;
  String icon;
  bool value;

  VisibilityObject(this.type, this.name, this.subtitle, this.icon, this.value);
}

Future<List<VisibilityObject>> getFilterOptions(
    String userChapter, String userVisibilityCeiling) async {
  List<VisibilityObject> visibilityMap = [];

  var visibilityCeilingName =
      await getVisibilityCeilingName(userChapter, userVisibilityCeiling);

  try {
    final visibilityDocs = await FirebaseFirestore.instance
        .collection('visibility')
        .doc('earth')
        .collection('countries')
        .get();

    for (final docCountry in visibilityDocs.docs) {
      final subnationalDocs = await getSubnationalDocs(docCountry.id);

      for (final docSubnational in subnationalDocs.docs) {
        final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

        for (final docLocal in localDocs.docs) {
          final chapterDocs = await getChapterDocs(
              docCountry.id, docSubnational.id, docLocal.id);

          for (final docChapter in chapterDocs.docs) {
            if (docChapter['name'] == userChapter) {
              if (userVisibilityCeiling == 'earth' &&
                  visibilityCeilingName == 'earth') {
                addDataToMap(
                    'country',
                    docCountry['name'],
                    docCountry['subtitle'],
                    docCountry['icon'],
                    visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'subnational',
                    docSubnational['name'],
                    docSubnational['subtitle'],
                    docSubnational['icon'],
                    visibilityMap.cast<VisibilityObject>());
                addDataToMap('local', docLocal['name'], docLocal['subtitle'],
                    docLocal['icon'], visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'chapter',
                    docChapter['name'],
                    docChapter['subtitle'],
                    docChapter['icon'],
                    visibilityMap.cast<VisibilityObject>());
              }
              if (userVisibilityCeiling == 'country' &&
                  visibilityCeilingName == docCountry['name']) {
                addDataToMap(
                    'country',
                    docCountry['name'],
                    docCountry['subtitle'],
                    docCountry['icon'],
                    visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'subnational',
                    docSubnational['name'],
                    docSubnational['subtitle'],
                    docSubnational['icon'],
                    visibilityMap.cast<VisibilityObject>());
                addDataToMap('local', docLocal['name'], docLocal['subtitle'],
                    docLocal['icon'], visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'chapter',
                    docChapter['name'],
                    docChapter['subtitle'],
                    docChapter['icon'],
                    visibilityMap.cast<VisibilityObject>());
              }
              if (userVisibilityCeiling == 'subnational' &&
                  visibilityCeilingName == docSubnational['name']) {
                addDataToMap(
                    'subnational',
                    docSubnational['name'],
                    docSubnational['subtitle'],
                    docSubnational['icon'],
                    visibilityMap.cast<VisibilityObject>());
                addDataToMap('local', docLocal['name'], docLocal['subtitle'],
                    docLocal['icon'], visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'chapter',
                    docChapter['name'],
                    docChapter['subtitle'],
                    docChapter['icon'],
                    visibilityMap.cast<VisibilityObject>());
              }
              if (userVisibilityCeiling == 'local' &&
                  visibilityCeilingName == docLocal['name']) {
                addDataToMap('local', docLocal['name'], docLocal['subtitle'],
                    docLocal['icon'], visibilityMap.cast<VisibilityObject>());
                addDataToMap(
                    'chapter',
                    docChapter['name'],
                    docChapter['subtitle'],
                    docChapter['icon'],
                    visibilityMap.cast<VisibilityObject>());
              }
              if (userVisibilityCeiling == 'chapter' &&
                  visibilityCeilingName == docChapter['name']) {
                addDataToMap(
                    'chapter',
                    docChapter['name'],
                    docChapter['subtitle'],
                    docChapter['icon'],
                    visibilityMap.cast<VisibilityObject>());
              }
            }
          }
        }
      }
    }

    return visibilityMap;
  } catch (e) {
    print('Error getting visibility: $e');
    return [];
  }
}

void addDataToMap(String type, String name, String subtitle, String icon,
    List<VisibilityObject> visibilityMap) {
  var data = VisibilityObject(type, name, subtitle, icon, false);

  visibilityMap.add(data);
}

// Below is good code

Future<List<Map<String, dynamic>>?> getAllVisibilityData() async {
  try {
    final visibilityDocs = await FirebaseFirestore.instance
        .collection('visibility')
        .doc('earth')
        .collection('countries')
        .get();

    List<Map<String, dynamic>> visibilityData = [];

    for (final docCountry in visibilityDocs.docs) {
      final subnationalDocs = await getSubnationalDocs(docCountry.id);

      for (final docSubnational in subnationalDocs.docs) {
        final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

        for (final docLocal in localDocs.docs) {
          final chapterDocs = await getChapterDocs(
              docCountry.id, docSubnational.id, docLocal.id);

          for (final docChapter in chapterDocs.docs) {
            final data = {
              'country': docCountry['name'],
              'subnational': docSubnational['name'],
              'local': docLocal['name'],
              'chapter': docChapter['name'],
            };
            visibilityData.add(data);
          }
        }
      }
    }

    return visibilityData;
  } catch (e) {
    print('Error getting visibility: $e');
    return null;
  }
}

// This may become obsolute
Future<List<Map<String, String>>> getVisibilityMap(
    String visibilityCeiling, String visibilityCeilingName) async {
  late List<Map<String, String>> visibilityData;

  try {
    final visibilityDocs = await FirebaseFirestore.instance
        .collection('visibility')
        .doc('earth')
        .collection('countries')
        .get();

    visibilityData = List.empty(growable: true);

    for (final docCountry in visibilityDocs.docs) {
      final subnationalDocs = await getSubnationalDocs(docCountry.id);

      for (final docSubnational in subnationalDocs.docs) {
        final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

        for (final docLocal in localDocs.docs) {
          final chapterDocs = await getChapterDocs(
              docCountry.id, docSubnational.id, docLocal.id);

          for (final docChapter in chapterDocs.docs) {
            switch (visibilityCeiling) {
              case 'earth':
                addDataToVisibilityData(
                    docCountry['name'],
                    docSubnational['name'],
                    docLocal['name'],
                    docChapter['name'],
                    visibilityData);
                break;
              case 'country':
                if (visibilityCeilingName == docCountry['name']) {
                  addDataToVisibilityData(
                      docCountry['name'],
                      docSubnational['name'],
                      docLocal['name'],
                      docChapter['name'],
                      visibilityData);
                }
                break;
              case 'subnational':
                if (visibilityCeilingName == docSubnational['name']) {
                  addDataToVisibilityData('', docSubnational['name'],
                      docLocal['name'], docChapter['name'], visibilityData);
                }
                break;
              case 'local':
                if (visibilityCeilingName == docLocal['name']) {
                  addDataToVisibilityData('', '', docLocal['name'],
                      docChapter['name'], visibilityData);
                }
                break;
              case 'chapter':
                if (visibilityCeilingName == docChapter['name']) {
                  addDataToVisibilityData(
                      '', '', '', docChapter['name'], visibilityData);
                }
                break;
              default:
                break;
            }
          }
        }
      }
    }

    return visibilityData;
  } catch (e) {
    print('Error getting visibility: $e');
    return [];
  }
}

void addDataToVisibilityData(String country, String subnational, String local,
    String chapter, List<Map<String, String>> visibilityData) {
  final data = {
    'country': country,
    'subnational': subnational,
    'local': local,
    'chapter': chapter,
  };
  visibilityData.add(data);
}

// Even Better
// Future<List<Map<String, String>>> getVisibilityMap(
//     String visibilityCeiling, String visibilityCeilingName) async {
//   late List<Map<String, String>> visibilityData;

//   try {
//     final visibilityDocs = await FirebaseFirestore.instance
//         .collection('visibility')
//         .doc('earth')
//         .collection('countries')
//         .get();

//     visibilityData = [];

//     for (final docCountry in visibilityDocs.docs) {
//       final subnationalDocs = await getSubnationalDocs(docCountry.id);

//       for (final docSubnational in subnationalDocs.docs) {
//         final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

//         for (final docLocal in localDocs.docs) {
//           final chapterDocs = await getChapterDocs(
//               docCountry.id, docSubnational.id, docLocal.id);

//           for (final docChapter in chapterDocs.docs) {
//             if (visibilityCeiling == 'earth') {
//               addDataToVisibilityData(
//                   docCountry['name'],
//                   docSubnational['name'],
//                   docLocal['name'],
//                   docChapter['name'],
//                   visibilityData);
//             } else if (visibilityCeiling == 'country' &&
//                 visibilityCeilingName == docCountry['name']) {
//               addDataToVisibilityData(
//                   docCountry['name'],
//                   docSubnational['name'],
//                   docLocal['name'],
//                   docChapter['name'],
//                   visibilityData);
//             } else if (visibilityCeiling == 'subnational' &&
//                 visibilityCeilingName == docSubnational['name']) {
//               addDataToVisibilityData(null, docSubnational['name'],
//                   docLocal['name'], docChapter['name'], visibilityData);
//             } else if (visibilityCeiling == 'local' &&
//                 visibilityCeilingName == docLocal['name']) {
//               addDataToVisibilityData(null, null, docLocal['name'],
//                   docChapter['name'], visibilityData);
//             } else if (visibilityCeiling == 'chapter' &&
//                 visibilityCeilingName == docChapter['name']) {
//               addDataToVisibilityData(
//                   null, null, null, docChapter['name'], visibilityData);
//             }
//           }
//         }
//       }
//     }

//     return visibilityData;
//   } catch (e) {
//     print('Error getting visibility: $e');
//     return [];
//   }
// }

// void addDataToVisibilityData(String? country, String? subnational,
//     String? local, String chapter, List<Map<String, String>> visibilityData) {
//   final data = {
//     'country': country ?? '',
//     'subnational': subnational ?? '',
//     'local': local ?? '',
//     'chapter': chapter,
//   };
//   visibilityData.add(data);
// }

// Best
// Future<List<Map<String, dynamic>>?> getVisibilityMap(
//     String visibilityCeiling, String visibilityCeilingName) async {
//   try {
//     final visibilityDocs = await FirebaseFirestore.instance
//         .collection('visibility')
//         .doc('earth')
//         .collection('countries')
//         .get();

//     List<Map<String, dynamic>> visibilityData = [];

//     for (final docCountry in visibilityDocs.docs) {
//       final subnationalDocs = await getSubnationalDocs(docCountry.id);

//       for (final docSubnational in subnationalDocs.docs) {
//         final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

//         for (final docLocal in localDocs.docs) {
//           final chapterDocs = await getChapterDocs(
//               docCountry.id, docSubnational.id, docLocal.id);

//           for (final docChapter in chapterDocs.docs) {
//             switch (visibilityCeiling) {
//               case 'earth':
//                 addDataToVisibilityData(
//                     docCountry['name'],
//                     docSubnational['name'],
//                     docLocal['name'],
//                     docChapter['name'],
//                     visibilityData);
//                 break;
//               case 'country':
//                 if (visibilityCeilingName == docCountry['name']) {
//                   addDataToVisibilityData(
//                       docCountry['name'],
//                       docSubnational['name'],
//                       docLocal['name'],
//                       docChapter['name'],
//                       visibilityData);
//                 }
//                 break;
//               case 'subnational':
//                 if (visibilityCeilingName == docSubnational['name']) {
//                   addDataToVisibilityData(null, docSubnational['name'],
//                       docLocal['name'], docChapter['name'], visibilityData);
//                 }
//                 break;
//               case 'local':
//                 if (visibilityCeilingName == docLocal['name']) {
//                   addDataToVisibilityData(null, null, docLocal['name'],
//                       docChapter['name'], visibilityData);
//                 }
//                 break;
//               case 'chapter':
//                 if (visibilityCeilingName == docChapter['name']) {
//                   addDataToVisibilityData(
//                       null, null, null, docChapter['name'], visibilityData);
//                 }
//                 break;
//             }
//           }
//         }
//       }
//     }

//     return visibilityData;
//   } catch (e) {
//     print('Error getting visibility: $e');
//     return null;
//   }
// }

// // This leaves a bunch of nulls.  I could use if statements to eliminate the nulls.
// void addDataToVisibilityData(String? country, String? subnational,
//     String? local, String chapter, List<Map<String, dynamic>> visibilityData) {
//   final data = {
//     'country': country,
//     'subnational': subnational,
//     'local': local,
//     'chapter': chapter,
//   };
//   visibilityData.add(data);
// }

// Good
// Future<List<Map<String, dynamic>>?> getVisibilityMap(
//     visibilityCeiling, visibilityCeilingName) async {
//   try {
//     final visibilityDocs = await FirebaseFirestore.instance
//         .collection('visibility')
//         .doc('earth')
//         .collection('countries')
//         .get();

//     List<Map<String, dynamic>> visibilityData = [];

//     for (final docCountry in visibilityDocs.docs) {
//       final subnationalDocs = await getSubnationalDocs(docCountry.id);

//       for (final docSubnational in subnationalDocs.docs) {
//         final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

//         for (final docLocal in localDocs.docs) {
//           final chapterDocs = await getChapterDocs(
//               docCountry.id, docSubnational.id, docLocal.id);

//           for (final docChapter in chapterDocs.docs) {
//             if (visibilityCeiling == 'earth') {
//               final data = {
//                 'country': docCountry['name'],
//                 'subnational': docSubnational['name'],
//                 'local': docLocal['name'],
//                 'chapter': docChapter['name'],
//               };
//               visibilityData.add(data);
//             }
//             if (visibilityCeiling == 'country' &&
//                 visibilityCeilingName == docCountry['name']) {
//               final data = {
//                 'country': docCountry['name'],
//                 'subnational': docSubnational['name'],
//                 'local': docLocal['name'],
//                 'chapter': docChapter['name'],
//               };
//               visibilityData.add(data);
//             }
//             if (visibilityCeiling == 'subnational' &&
//                 visibilityCeilingName == docSubnational['name']) {
//               final data = {
//                 'subnational': docSubnational['name'],
//                 'local': docLocal['name'],
//                 'chapter': docChapter['name'],
//               };
//               visibilityData.add(data);
//             }
//             if (visibilityCeiling == 'local' &&
//                 visibilityCeilingName == docLocal['name']) {
//               final data = {
//                 'local': docLocal['name'],
//                 'chapter': docChapter['name'],
//               };
//               visibilityData.add(data);
//             }
//             if (visibilityCeiling == 'chapter' &&
//                 visibilityCeilingName == docChapter['name']) {
//               final data = {
//                 'chapter': docChapter['name'],
//               };
//               visibilityData.add(data);
//             }
//           }
//         }
//       }
//     }

//     return visibilityData;
//   } catch (e) {
//     print('Error getting visibility: $e');
//     return null;
//   }
// }

Future<String?> getVisibilityCeilingName(myChapter, visbilityCeiling) async {
  try {
    final visibilityDocs = await FirebaseFirestore.instance
        .collection('visibility')
        .doc('earth')
        .collection('countries')
        .get();

    for (final docCountry in visibilityDocs.docs) {
      final subnationalDocs = await getSubnationalDocs(docCountry.id);

      for (final docSubnational in subnationalDocs.docs) {
        final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

        for (final docLocal in localDocs.docs) {
          final chapterDocs = await getChapterDocs(
              docCountry.id, docSubnational.id, docLocal.id);

          for (final docChapter in chapterDocs.docs) {
            if (docChapter['name'] == myChapter) {
              switch (visbilityCeiling) {
                case 'earth':
                  return ('Earth');
                case 'country':
                  return (docCountry['name']);
                case 'subnational':
                  return (docSubnational['name']);
                case 'local':
                  return (docLocal['name']);
                default:
                  return (docChapter['name']);
              }
            }
          }
        }
      }
    }

    return null;
  } catch (e) {
    print('Error getting visibility: $e');
    return null;
  }
}

Future<String?> getMychapter(myChapter) async {
  try {
    final visibilityDocs = await FirebaseFirestore.instance
        .collection('visibility')
        .doc('earth')
        .collection('countries')
        .get();

    for (final docCountry in visibilityDocs.docs) {
      final subnationalDocs = await getSubnationalDocs(docCountry.id);

      for (final docSubnational in subnationalDocs.docs) {
        final localDocs = await getLocalDocs(docCountry.id, docSubnational.id);

        for (final docLocal in localDocs.docs) {
          final chapterDocs = await getChapterDocs(
              docCountry.id, docSubnational.id, docLocal.id);

          for (final docChapter in chapterDocs.docs) {
            if (docChapter['name'] == myChapter) {
              return ('${docCountry['name']}/${docSubnational['name']}/${docLocal['name']}/${docChapter['name']}');
            }
          }
        }
      }
    }

    return null;
  } catch (e) {
    print('Error getting visibility: $e');
    return null;
  }
}

Future<QuerySnapshot> getSubnationalDocs(String docCountryId) async {
  return await FirebaseFirestore.instance
      .collection('visibility')
      .doc('earth')
      .collection('countries')
      .doc(docCountryId)
      .collection('subnationals')
      .get();
}

Future<QuerySnapshot> getLocalDocs(
    String docCountryId, String docSubnationalId) async {
  return await FirebaseFirestore.instance
      .collection('visibility')
      .doc('earth')
      .collection('countries')
      .doc(docCountryId)
      .collection('subnationals')
      .doc(docSubnationalId)
      .collection('locals')
      .get();
}

Future<QuerySnapshot> getChapterDocs(
    String docCountryId, String docSubnationalId, String docLocalId) async {
  return await FirebaseFirestore.instance
      .collection('visibility')
      .doc('earth')
      .collection('countries')
      .doc(docCountryId)
      .collection('subnationals')
      .doc(docSubnationalId)
      .collection('locals')
      .doc(docLocalId)
      .collection('chapters')
      .get();
}
