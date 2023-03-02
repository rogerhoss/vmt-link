import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/constants.dart';
import 'package:link/main.dart';
import 'package:link/model/User.dart';
import 'package:link/services/FirebaseHelper.dart';
import 'package:link/services/helper.dart';
import 'package:link/ui/allFriends/AllFriendsScreen.dart';
import 'package:link/ui/notifications/NotificationsScreen.dart';
import 'package:link/ui/profileSettings/ProfileSettingsScreen.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collection/collection.dart';
// import 'package:flutter_reaction_button/flutter_reaction_button.dart';
// import 'package:link/ui/socialComments/SocialCommentsScreen.dart';
// import 'package:link/ui/createPost/CreatePostScreen.dart';
// import 'package:link/ui/detailedPost/DetailedPostScreen.dart';
// import 'package:link/model/MessageData.dart';
// import 'package:link/model/PostModel.dart';
// import 'package:link/model/SocialReactionModel.dart';
// import 'package:link/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
// import 'package:link/ui/fullScreenVideoViewer/FullScreenVideoViewer.dart';
//import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final bool fromContainer;

  ProfileScreen({Key? key, required this.user, required this.fromContainer})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late Future<List<User>> _friendsFuture;
  // late Stream<List<PostModel>> _userPosts;
  // late Future<List<SocialReactionModel>> _myReactions;
  // List<SocialReactionModel?> _reactionsList = [];
  Future<String>? _profileRelationFuture;
  String? _profileRelation;
  List<User> _friends = [];

  @override
  void initState() {
    user = widget.user;
    _friendsFuture = _fireStoreUtils.getUserContactsForProfile(user.userID);
    if (user.userID != MyAppState.currentUser!.userID)
      _profileRelationFuture =
          _fireStoreUtils.getUserSocialRelation(user.userID);
    _fireStoreUtils.getBlocks().listen((shouldRefresh) {
      if (shouldRefresh) {
        if (mounted) setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _fireStoreUtils.disposeProfilePostsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromContainer
          ? null
          : AppBar(
              title: Text('My Profile').tr(),
              actions: [
                if (user.userID == MyAppState.currentUser!.userID)
                  IconButton(
                    tooltip: 'notifications'.tr(),
                    icon: Icon(
                      CupertinoIcons.bell_fill,
                      color: Color(COLOR_PRIMARY),
                    ),
                    onPressed: () => push(context, NotificationsScreen()),
                  ),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 32, right: 32),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                      child: displayCircleImage(
                          user.profilePictureURL, 130, false)),
                  Visibility(
                    visible: user.userID == MyAppState.currentUser!.userID,
                    child: Positioned.directional(
                      textDirection: Directionality.of(context),
                      start: 80,
                      end: 0,
                      child: FloatingActionButton(
                          backgroundColor: Color(COLOR_ACCENT),
                          child: Icon(
                            CupertinoIcons.camera,
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                          ),
                          mini: true,
                          onPressed: _onCameraClick),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  user.fullName(),
                  style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade200
                          : Colors.black,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: TextButton(
                  onPressed: () async {
                    if (user.userID == MyAppState.currentUser!.userID) {
                      push(context, ProfileSettingsScreen());
                    } else {
                      if (_profileRelation != null) {
                        showProgress(context, 'loading'.tr(), false);
                        await _fireStoreUtils.profileRelationButtonClick(
                            _profileRelation!, user);
                        hideProgress();
                        _profileRelationFuture =
                            _fireStoreUtils.getUserSocialRelation(user.userID);
                        setState(() {});
                      }
                    }
                  },
                  child: user.userID == MyAppState.currentUser!.userID
                      ? Text('profileSettings').tr()
                      : FutureBuilder<String>(
                          future: _profileRelationFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return CircularProgressIndicator.adaptive();
                            _profileRelation = snapshot.data;
                            return Text(snapshot.data!);
                          },
                        ),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(COLOR_PRIMARY),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Color(COLOR_PRIMARY).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'contacts',
                style: TextStyle(
                    color: isDarkMode(context)
                        ? Colors.grey.shade200
                        : Colors.black,
                    fontSize: 20),
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FutureBuilder<List<User>>(
                future: _friendsFuture,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator.adaptive());
                  if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true))
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: showEmptyState('noContactsFound'.tr(), '')),
                    );
                  _friends = snapshot.data!;
                  Future.delayed(Duration(milliseconds: 300), () {
                    if (mounted) setState(() {});
                  });
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: .8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemBuilder: (context, index) =>
                        _buildFriendCard(snapshot.data![index]),
                    itemCount: snapshot.data!.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  );
                },
              ),
            ),
            Visibility(
              visible: _friends.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  child: TextButton(
                    onPressed: () => push(
                        context,
                        AllFriendsScreen(
                          user: user,
                        )),
                    child: Text('seeAllFriends').tr(),
                    style: TextButton.styleFrom(
                      foregroundColor: isDarkMode(context)
                          ? Colors.grey.shade200
                          : Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isDarkMode(context)
                          ? Colors.grey.shade200.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // StreamBuilder<List<PostModel>>(
            //   stream: _userPosts,
            //   initialData: [],
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting)
            //       return Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Center(child: CircularProgressIndicator.adaptive()),
            //       );
            //     if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true))
            //       return Padding(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 32.0, vertical: 30),
            //           child: Center(
            //             child: showEmptyState(
            //                 'noPostsFound'.tr(),
            //                 widget.user.userID == MyAppState.currentUser!.userID
            //                     ? 'allYourPostsWillShowUpHere'.tr()
            //                     : 'haveNotPublishedAnyPosts'
            //                         .tr(args: ['${widget.user.firstName}']),
            //                 buttonTitle: 'createPost'.tr(),
            //                 isDarkMode: isDarkMode(context),
            //                 action: widget.user.userID ==
            //                         MyAppState.currentUser!.userID
            //                     ? () => push(context, CreatePostScreen())
            //                     : null),
            //           ));

            //     return ListView.builder(
            //         shrinkWrap: true,
            //         padding: EdgeInsets.symmetric(vertical: 4),
            //         physics: NeverScrollableScrollPhysics(),
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (context, index) =>
            //             _buildPostWidget(snapshot.data![index]));
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'addProfilePicture',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: [
        CupertinoActionSheetAction(
          child: Text('removePicture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, 'removingPicture'.tr(), false);
            if (user.profilePictureURL.isNotEmpty)
              await _fireStoreUtils.deleteImage(user.profilePictureURL);
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('chooseFromGallery').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('takeAPicture').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
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

  Future<void> _imagePicked(File image) async {
    showProgress(context, 'uploadingImage'.tr(), false);
    user.profilePictureURL =
        await FireStoreUtils.uploadUserImageToFireStorage(image, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
  }

  Widget _buildFriendCard(User friend) {
    return GestureDetector(
      onTap: () =>
          push(context, ProfileScreen(user: friend, fromContainer: false)),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(6), topLeft: Radius.circular(6)),
                child: CachedNetworkImage(
                  imageUrl: friend.profilePictureURL,
                  fit: BoxFit.cover,
                  placeholder: (context, imageUrl) {
                    return Icon(
                      CupertinoIcons.hourglass,
                      size: 75,
                      color: Color(COLOR_PRIMARY),
                    );
                  },
                  errorWidget: (context, imageUrl, error) {
                    return Icon(
                      Icons.error_outline,
                      size: 75,
                      color: Color(COLOR_PRIMARY),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 4, 4, 16),
              child: Text(friend.firstName),
            )
          ],
        ),
      ),
    );
  }
}
