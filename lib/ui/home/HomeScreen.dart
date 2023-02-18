import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:link/constants.dart';
import 'package:link/main.dart';
import 'package:link/model/MessageData.dart';
import 'package:link/model/PostModel.dart';
import 'package:link/model/SocialReactionModel.dart';
import 'package:link/model/StoryModel.dart';
import 'package:link/model/User.dart';
import 'package:link/services/FirebaseHelper.dart';
import 'package:link/services/helper.dart';
import 'package:link/ui/createPost/CreatePostScreen.dart';
import 'package:link/ui/detailedPost/DetailedPostScreen.dart';
import 'package:link/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:link/ui/fullScreenVideoViewer/FullScreenVideoViewer.dart';
import 'package:link/ui/postStory/PostStoryScreen.dart';
import 'package:link/ui/profile/ProfileScreen.dart';
import 'package:link/ui/socialComments/SocialCommentsScreen.dart';
import 'package:link/ui/storyPage/StoryPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Stream<List<StoryModel>> _storiesStream;
  late Stream<List<PostModel>> _postsStream;
  late Future<List<SocialReactionModel>> _myReactions;
  late List<SocialReactionModel?> _reactionsList = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    _storiesStream =
        fireStoreUtils.getUserStories(MyAppState.currentUser!.userID);
    _myReactions = fireStoreUtils.getMyReactions()
      ..then((value) {
        _reactionsList.addAll(value);
      });
    _postsStream = fireStoreUtils.getUserPosts(MyAppState.currentUser!.userID);
    fireStoreUtils.getBlocks().listen((shouldRefresh) {
      if (shouldRefresh) {
        if (mounted) setState(() {});
      }
    });

    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    fireStoreUtils.disposeUserPostsStream();
    fireStoreUtils.disposeUserStoriesStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<StoryModel>>(
              stream: _storiesStream,
              initialData: [],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  );

                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true))
                  return SizedBox(
                      height: 100,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                        child: InkWell(
                          onTap: () => _showStoryMenu(),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(COLOR_PRIMARY), width: 2)),
                                child: displayCircleImage(
                                    MyAppState.currentUser!.profilePictureURL,
                                    50,
                                    false),
                              ),
                              Expanded(
                                child: Container(
                                  width: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8, right: 8),
                                    child: Text(
                                      'My Story',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));

                Map<String, List<StoryModel>> stories = groupBy(
                    snapshot.data!, (StoryModel story) => story.author.userID);
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: snapshot.hasData ? stories.length : 0,
                    itemBuilder: (context, index) {
                      List<StoryModel> userStories =
                          stories.values.toList()[index];
                      User friend = stories.values.toList()[index].first.author;
                      if (friend.userID == MyAppState.currentUser!.userID)
                        userStories
                            .sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                        child: InkWell(
                          onTap: () {
                            push(context, StoryPage(stories: userStories));
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(COLOR_PRIMARY), width: 2)),
                                child: displayCircleImage(
                                    friend.profilePictureURL, 50, false),
                              ),
                              Expanded(
                                child: Container(
                                  width: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8, right: 8),
                                    child: Text(
                                      friend.userID ==
                                              MyAppState.currentUser!.userID
                                          ? 'My Story'.tr()
                                          : '${friend.firstName}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                  ),
                );
              },
            ),
            StreamBuilder<List<PostModel>>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 150),
                      child: Center(
                        child: showEmptyState('noPostsFound'.tr(),
                            'allYourFeedPostsWillShowUpHere'.tr(),
                            buttonTitle: 'createPost'.tr(),
                            isDarkMode: isDarkMode(context),
                            action: () => push(context, CreatePostScreen())),
                      ));
                } else {
                  return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          _buildPostWidget(snapshot.data![index]));
                }
              },
              initialData: [],
            )
          ],
        ),
      ),
    );
  }

  _buildPostWidget(PostModel post) {
    PageController _controller = PageController(
      initialPage: 0,
    );
    return GestureDetector(
      onTap: () {
        _showDetailedPost(post, post.myReaction);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
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
                        onTap: () => push(
                            context,
                            ProfileScreen(
                                user: post.author, fromContainer: false)),
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
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
                              controller: _controller,
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
                                                  post
                                                      .postMedia[index]
                                                      .videoThumbnail!
                                                      .isNotEmpty
                                              ? DecorationImage(
                                                  image: Image.network(post
                                                          .postMedia[index]
                                                          .videoThumbnail!)
                                                      .image)
                                              : null),
                                      child: Center(
                                        child: FloatingActionButton(
                                          child: Icon(
                                              CupertinoIcons.play_arrow_solid),
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
                                  controller: _controller,
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
                  Row(
                    children: [
                      SizedBox(width: 6),
                      FutureBuilder<List<SocialReactionModel>>(
                        future: _myReactions,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            SocialReactionModel? _postReaction;
                            if (snapshot.data!.isNotEmpty) {
                              _postReaction = _reactionsList.firstWhereOrNull(
                                  (element) => element?.postID == post.id);
                              if (_postReaction != null) {
                                post.myReaction = getReaction(_postReaction.reaction);
                              }
                            }
                            return FlutterReactionButton(
                              onReactionChanged: (reaction, isChecked) {
                                setState(() {
                                  post.myReaction = reaction;
                                });
                                if (isChecked) {
                                  bool isNewReaction = false;
                                  SocialReactionModel? postReaction =
                                      _reactionsList.firstWhere(
                                          (element) => element?.postID == post.id,
                                          orElse: () {
                                    isNewReaction = true;
                                    String reactionString = reactionStringFromId(reaction!.id!);
                                    SocialReactionModel newReaction = SocialReactionModel(
                                        postID: post.id,
                                        createdAt: Timestamp.now(),
                                        reactionAuthorID: MyAppState.currentUser!.userID,
                                        reaction: reactionString);
                                    _reactionsList.add(newReaction);
                                    return newReaction;
                                  });
                                  if (isNewReaction) {
                                    setState(() {
                                      post.reactionsCount++;
                                    });
                                    fireStoreUtils.postReaction(postReaction!, post);
                                  } else {
                                    postReaction!.reaction = reactionStringFromId(reaction!.id!);
                                    postReaction.createdAt = Timestamp.now();
                                    fireStoreUtils.updateReaction(postReaction, post);
                                  }
                                } else {
                                  _reactionsList.removeWhere(
                                      (element) => element?.postID == post.id);
                                  setState(() {
                                    post.reactionsCount--;
                                  });
                                  fireStoreUtils.removeReaction(post);
                                }
                              },
                              reactions: facebookReactions,
                              initialReaction: Reaction(
                                  id: 0,
                                  icon: Container(
                                    color: Colors.transparent,
                                    child: Icon(Icons.thumb_up_outlined,
                                        color: isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : null),
                                  )),
                              selectedReaction: post.myReaction,
                              boxColor: Colors.grey.shade100,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      if (post.reactionsCount.round() != 0)
                        Text('${post.reactionsCount.round()}'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            child: Icon(
                              CupertinoIcons.conversation_bubble,
                              size: 20,
                              color: isDarkMode(context) ? Colors.grey.shade200 : null,
                            ),
                            onTap: () => _showCommentsSheet(post)),
                      ),
                      if (post.commentCount.round() != 0) Text('${post.commentCount.round()}'),
                    ],
                  );
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
        ),
      ),
    );
  }

  _showCommentsSheet(PostModel post) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SocialCommentsScreen(post: post);
      },
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

  _showStoryMenu() {
    final action = CupertinoActionSheet(
      message: Text(
        'addToYourStory',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: [
        CupertinoActionSheetAction(
          child: Text('chooseImageFromGallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              push(
                  context,
                  PostStoryScreen(
                      storyFile: File(image.path), storyType: 'image'));
          },
        ),
        CupertinoActionSheetAction(
          child: Text('takeAPicture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              push(
                  context,
                  PostStoryScreen(
                      storyFile: File(image.path), storyType: 'image'));
          },
        ),
        CupertinoActionSheetAction(
          child: Text('chooseVideoFromGallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? video =
                await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (video != null)
              push(
                  context,
                  PostStoryScreen(
                      storyFile: File(video.path), storyType: 'video'));
          },
        ),
        CupertinoActionSheetAction(
          child: Text('recordVideo').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? video =
                await _imagePicker.pickVideo(source: ImageSource.camera);
            if (video != null)
              push(
                  context,
                  PostStoryScreen(
                      storyFile: File(video.path), storyType: 'video'));
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

  void _showDetailedPost(PostModel post, Reaction defaultInitialReaction) {
    push(
        context,
        DetailedPostScreen(
          post: post,
          postReaction: defaultInitialReaction,
          reactions: _reactionsList,
        ));
  }
}
