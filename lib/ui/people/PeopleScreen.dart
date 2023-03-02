import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/model/ContactModel.dart';
import 'package:link/model/ConversationModel.dart';
import 'package:link/model/HomeConversationModel.dart';
import 'package:link/model/User.dart';
import 'package:link/services/FirebaseHelper.dart';
import 'package:link/services/helper.dart';
import 'package:link/ui/chat/ChatScreen.dart';
import 'package:link/ui/profile/ProfileScreen.dart';
import 'package:link/ui/searchScreen/SearchScreen.dart';

List<ContactModel> _contacts = [];

class FriendsScreen extends StatefulWidget {
  final User user;

  const FriendsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<FriendsScreen> {
  late User user;
  final fireStoreUtils = FireStoreUtils();

  late Future<List<ContactModel>> _future;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    fireStoreUtils.getBlocks().listen((shouldRefresh) {
      if (shouldRefresh) {
        if (mounted) setState(() {});
      }
    });
    _future = fireStoreUtils.getPeople(user.userID, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
          child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchScreen(user: user)));
                    // I removed this because when you when from the friends screen to the seach page
                    // it would append the friends to the entire list.  There may be a better way to
                    // handle this.
                    _future = fireStoreUtils.getPeople(user.userID, false);
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode(context)
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    shape: StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                      ),
                      Text('search').tr(),
                    ],
                  ))),
        ),
        FutureBuilder<List<ContactModel>>(
          future: _future,
          initialData: [],
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return Expanded(
                child: Container(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              );
            if (!snap.hasData || (snap.data?.isEmpty ?? true))
              return Expanded(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: showEmptyState(
                      'noFriendsFound'.tr(), 'startAddingYourFriendsNow'.tr(),
                      isDarkMode: isDarkMode(context),
                      buttonTitle: 'addFriends'.tr(),
                      action: () => push(context, SearchScreen(user: user))),
                )),
              );

            return Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snap.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  _contacts = snap.data!;
                  ContactModel contact = snap.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: ListTile(
                      onTap: () async {
                        String channelID;
                        if (contact.user.userID.compareTo(user.userID) < 0) {
                          channelID = contact.user.userID + user.userID;
                        } else {
                          channelID = user.userID + contact.user.userID;
                        }
                        ConversationModel? conversationModel =
                            await fireStoreUtils
                                .getChannelByIdOrNull(channelID);
                        push(
                          context,
                          ChatScreen(
                            homeConversationModel: HomeConversationModel(
                                isGroupChat: false,
                                members: [contact.user],
                                conversationModel: conversationModel),
                          ),
                        );
                      },
                      leading: GestureDetector(
                        onTap: () => push(
                            context,
                            ProfileScreen(
                              user: contact.user,
                              fromContainer: false,
                            )),
                        child: displayCircleImage(
                            contact.user.profilePictureURL, 55, false),
                      ),
                      title: Text(
                        '${contact.user.fullName()}',
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      trailing: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isDarkMode(context)
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          await _onContactButtonClicked(contact, index, false);
                          setState(() {});
                        },
                        child: Icon(
                          getContactStatus(contact.type),
                          size: 30,
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }

  IconData? getContactStatus(ContactType type) {
    switch (type) {
      case ContactType.FRIEND:
        return CupertinoIcons.person_crop_square_fill;
      case ContactType.UNKNOWN:
        return CupertinoIcons.person_crop_square;
    }
  }

  _onContactButtonClicked(
      ContactModel contact, int index, bool fromSearch) async {
    ContactType newType = contact.type == ContactType.FRIEND
        ? ContactType.UNKNOWN
        : ContactType.FRIEND;

    switch (contact.type) {
      case ContactType.FRIEND:
        // showProgress(context, 'removingFromContacts'.tr(), false);
        await fireStoreUtils.removeFromContacts(contact.user, true);
        break;
      case ContactType.UNKNOWN:
        // showProgress(context, 'addingtocontacts'.tr(), false);
        await fireStoreUtils.addToContacts(contact.user, false);
        break;
    }
    // Update the contact object with the new type
    contact.type = newType;

    // Update the contact in the list
    setState(() {
      _contacts[index] = contact;
    });
  }
}
