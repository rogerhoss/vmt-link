import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/model/PostModel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../model/MessageData.dart';
import '../../model/SocialReactionModel.dart';
import '../../services/helper.dart';
import '../fullScreenImageViewer/FullScreenImageViewer.dart';
import '../fullScreenVideoViewer/FullScreenVideoViewer.dart';
import '../profile/ProfileScreen.dart';

class StandardPostTemplate extends StatelessWidget {
  final PostModel post;
  final PageController currentController;
  final BuildContext context;

  StandardPostTemplate(
      {required this.post,
      required this.currentController,
      required this.context});

  get fireStoreUtils => null;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => push(context,
                        ProfileScreen(user: post.author, fromContainer: false)),
                    child: displayCircleImage(
                        post.author.profilePictureURL, 55, false),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author.fullName(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            setLastSeen(post.createdAt.seconds),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (post.location.isNotEmpty ||
                              post.location != 'Unknown Location')
                            Text(post.location),
                        ]),
                  ),
                ],
              ),
              post.postText.isEmpty
                  ? SizedBox(height: 8)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.postText,
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Colors.grey.shade200
                                : Colors.grey.shade900),
                      ),
                    ),
              if (post.postMedia.isNotEmpty)
                Container(
                  height: 250,
                  child: Stack(
                    children: [
                      PageView.builder(
                          controller: currentController,
                          itemCount: post.postMedia.length,
                          itemBuilder: (context, index) {
                            Url postMedia = post.postMedia[index];
                            if (postMedia.mime.contains('video')) {
                              return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      image: post.postMedia[index]
                                                      .videoThumbnail !=
                                                  null &&
                                              post.postMedia[index]
                                                  .videoThumbnail!.isNotEmpty
                                          ? DecorationImage(
                                              image: Image.network(post
                                                      .postMedia[index]
                                                      .videoThumbnail!)
                                                  .image)
                                          : null),
                                  child: Center(
                                    child: FloatingActionButton(
                                      child:
                                          Icon(CupertinoIcons.play_arrow_solid),
                                      backgroundColor: Colors.white54,
                                      heroTag: post.id,
                                      onPressed: () => push(
                                          context,
                                          FullScreenVideoViewer(
                                              videoUrl: postMedia.url,
                                              heroTag: post.id)),
                                    ),
                                  ));
                            } else if (postMedia.mime.contains('image')) {
                              return GestureDetector(
                                  onTap: () => push(
                                      context,
                                      FullScreenImageViewer(
                                          imageUrl: postMedia.url)),
                                  child: displayImage(postMedia.url, 150));
                            } else {
                              return Container();
                            }
                          }),
                      if (post.postMedia.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SmoothPageIndicator(
                              controller: currentController,
                              count: post.postMedia.length,
                              effect: ScrollingDotsEffect(
                                  dotWidth: 6,
                                  dotHeight: 6,
                                  dotColor: isDarkMode(context)
                                      ? Colors.white54
                                      : Colors.black54,
                                  activeDotColor: Color(COLOR_PRIMARY)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Row(
              //   children: [
              //     SizedBox(width: 6),
              //     FutureBuilder<List<SocialReactionModel>>(
              //       future: _myReactions,
              //       builder: (context, snapshot) {
              //         if (snapshot.hasData) {
              //           SocialReactionModel? _postReaction;

              //           if (snapshot.data!.isNotEmpty) {
              //             _postReaction = _reactionsList.firstWhereOrNull(
              //                 (element) => element?.postID == post.id);
              //             if (_postReaction != null) {
              //               // your existing code here
              //               switch (_postReaction.reaction) {
              //                 case 'like':
              //                   post.myReaction = Reaction(
              //                     value: 1,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/like.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/like_fill.png'),
              //                   );
              //                   break;
              //                 case 'love':
              //                   post.myReaction = Reaction(
              //                     value: 2,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/love.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/love.png'),
              //                   );
              //                   break;
              //                 case 'surprised':
              //                   post.myReaction = Reaction(
              //                     value: 3,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/wow.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/wow.png'),
              //                   );
              //                   break;
              //                 case 'laugh':
              //                   post.myReaction = Reaction(
              //                     value: 4,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/haha.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/haha.png'),
              //                   );
              //                   break;
              //                 case 'sad':
              //                   post.myReaction = Reaction(
              //                     value: 5,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/sad.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/sad.png'),
              //                   );
              //                   break;
              //                 case 'angry':
              //                   post.myReaction = Reaction(
              //                     value: 6,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/angry.gif'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/angry.png'),
              //                   );
              //                   break;
              //                 default:
              //                   post.myReaction = Reaction(
              //                     value: 0,
              //                     previewIcon: buildPreviewIconFacebook(
              //                         'assets/images/like.png'),
              //                     icon: buildIconFacebook(
              //                         'assets/images/like.png'),
              //                   );
              //                   break;
              //               }
              //             }
              //           }
              //         }
              //         // Add a return statement at the end
              //         return Container(); // or SizedBox(width: 0, height: 0);
              //       },
              //     ),
              //     SizedBox(width: 8),
              //     if (post.reactionsCount.round() != 0)
              //       Text('${post.reactionsCount.round()}'),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: InkWell(
              //           child: Icon(
              //             CupertinoIcons.conversation_bubble,
              //             size: 20,
              //             color:
              //                 isDarkMode(context) ? Colors.grey.shade200 : null,
              //           ),
              //           onTap: () => _showCommentsSheet(post)),
              //     ),
              //     if (post.commentCount.round() != 0)
              //       Text('${post.commentCount.round()}'),
              //   ],
              // ),
            ],
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: 0,
            end: 0,
            child: IconButton(
                icon: Icon(
                  CupertinoIcons.ellipsis,
                  color: Colors.grey,
                ),
                onPressed: () => _postSettingsMenu(post)),
          )
        ],
      ),
    );
  }

  _postSettingsMenu(PostModel post) {
    final action = CupertinoActionSheet(
      message: Text(
        'postSettings',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: [
        if (MyAppState.currentUser!.userID != post.authorID)
          CupertinoActionSheetAction(
            child: Text('block').tr(),
            onPressed: () async {
              Navigator.pop(context);
              showProgress(context, 'blockingUser'.tr(), false);
              bool isSuccessful =
                  await fireStoreUtils.blockUser(post.author, 'block');
              hideProgress();
              if (isSuccessful) {
                showAlertDialog(
                    context,
                    'block'.tr(),
                    'hasBeenBlocked'.tr(args: ['${post.author.fullName()}']),
                    true);
              } else {
                showAlertDialog(
                    context,
                    'block'.tr(),
                    'couldNotBlock'.tr(args: ['${post.author.fullName()}']),
                    true);
              }
            },
          ),
        if (MyAppState.currentUser!.userID != post.authorID)
          CupertinoActionSheetAction(
            child: Text('reportPost').tr(),
            onPressed: () async {
              Navigator.pop(context);
              showProgress(context, 'reportingPost'.tr(), false);
              bool isSuccessful =
                  await fireStoreUtils.blockUser(post.author, 'report');
              hideProgress();
              if (isSuccessful) {
                showAlertDialog(
                    context,
                    'report'.tr(),
                    'postHasBeenReported'
                        .tr(args: ['${post.author.fullName()}']),
                    true);
              } else {
                showAlertDialog(
                    context,
                    'report'.tr(),
                    'couldnNotReportPost'
                        .tr(args: ['${post.author.fullName()}']),
                    true);
              }
            },
          ),
        CupertinoActionSheetAction(
          child: Text('sharePost').tr(),
          onPressed: () async {
            Navigator.pop(context);
            sharePost(post);
          },
        ),
        if (MyAppState.currentUser!.userID == post.authorID)
          CupertinoActionSheetAction(
            child: Text('deletePost').tr(),
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              showProgress(context, 'deletingPost'.tr(), false);
              await fireStoreUtils.deletePost(post);
              hideProgress();
            },
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}




// class StandardPostTemplate extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String image;

//   StandardPostTemplate({this.title, this.subtitle, this.image});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 8),
//           Image.network(
//             image,
//             width: double.infinity,
//             height: 200,
//             fit: BoxFit.cover,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class EventTemplate extends StatelessWidget {
//   final String title;
//   final String location;
//   final String date;
//   final String image;

//   EventTemplate({this.title, this.location, this.date, this.image});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Date: $date | Location: $location',
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 8),
//           Image.network(
//             image,
//             width: double.infinity,
//             height: 200,
//             fit: BoxFit.cover,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class NewApplicantTemplate extends StatelessWidget {
//   final String name;
//   final String position;
//   final String resume;

//   NewApplicantTemplate({this.name, this.position, this.resume});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'New Applicant: $name',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Position: $position',
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 8),
//           ElevatedButton(
//             child: Text('View Resume'),
//             onPressed: () {
//               // TODO: Implement view resume functionality
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Social Media App'),
//       ),
//       body: ListView(
//         children: [
//           StandardPostTemplate(
//             title: 'My awesome post',
//             subtitle: 'Check out this cool thing I did!',
//             image: 'https://example.com/images/awesome-post.jpg',
//           ),
//           StandardPostTemplate(
//             title: 'My second post',
//             subtitle: 'Here\'s another cool thing I did!',
//             image: 'https://example.com/images/second-post.jpg',
//           ),
//           // Add more standard posts here...
//         ],
//       ),
//     );
//   }
// }
