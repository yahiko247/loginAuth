import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/chat/empty_view.dart';
import 'package:practice_login/pages/freelancerstalkingpage.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/pages/userstalkingpage.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:searchable_listview/searchable_listview.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _userSearchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        title: const Text('Search'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: const SearchableListWidget(),
      )
    );
  }
}

class SearchableListWidget extends StatefulWidget {
  const SearchableListWidget({super.key});

  @override
  State<SearchableListWidget> createState() => _SearchableListWidgetState();
}

class _SearchableListWidgetState extends State<SearchableListWidget> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _userSearchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fireStore.collection('users').get(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (usersSnapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (usersSnapshot.hasData) {
            var usersDocs =  usersSnapshot.data!.docs;
            List<User> users = usersDocs.map((doc) {
              return User.fromSnapshot(doc);
            }).toList();

            return SearchableList<User>(
              autoFocusOnSearch: true,
              style: const TextStyle(fontSize: 16),
              searchTextController: _userSearchController,
              builder: (list, index, item) {
                return UserItem(user: item);
              },
              initialList: const [],
              filter: (input) {
                if (_userSearchController.text.isNotEmpty) {
                  return users.where((element) => element.firstName.toLowerCase().contains(input.toLowerCase())
                      || element.lastName.toLowerCase().contains(input.toLowerCase())
                      || ('${element.firstName.toLowerCase()}${element.lastName.toLowerCase()}').replaceAll(' ', '').contains(input.replaceAll(' ', '').toLowerCase())
                      || element.email.toLowerCase().contains(input.toLowerCase())).toList();
                } else {
                  return [];
                }
              },
              emptyWidget: const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyView(
                  message: 'Enter a name or an email\nto search for users',
                  displayIcon: true,
                  messageIcon: Icon(Icons.search, size: 40, color: Colors.black),
                ),
              ),
              spaceBetweenSearchAndList: 10,
              inputDecoration: InputDecoration(
                prefix: const SizedBox(width: 15),
                hintText: 'Search GiGabay',
                focusColor: Colors.black,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            );
          } else {
            return Container();
          }
        }
    );
  }
}

class UserItem extends StatefulWidget {
  final User user;
  const UserItem({super.key, required this.user});

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void userNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => UserStalkPage(userEmail: userEmail)
        )
    );
  }

  void freelancerNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => FreelancerStalkPage(userEmail: userEmail)
        )
    );
  }

  void userProfileNavigator() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfilePage()
        )
    );
  }

  Future<void> freelancerIdentifier2(String email, String id, BuildContext context) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
    Map <String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

    if(id == FirebaseAuth.instance.currentUser!.uid) {
      userProfileNavigator();
    }else if (userData!.containsKey('freelancer')) {
      bool? isFreelancer = snapshot['freelancer'];
      if (isFreelancer == true) {
        freelancerNavigator(email);
      } else {
        userNavigator(email);
      }
    } else {
      userNavigator(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7))
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          trailing: const Icon(Icons.arrow_forward_outlined),
          leading: const CircleAvatar(
              radius: 24,
              backgroundImage:
              AssetImage('images/Avatar1.png')
          ),
          title: Text('${widget.user.firstName} ${widget.user.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: widget.user.freelancer ? Row(
            children: [
              Material(
                color: Colors.green,
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: const Text('Freelancer'),
                ),
              ),
              const SizedBox(width: 5),
              Material(
                color: Colors.orange,
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(widget.user.categoryName.isNotEmpty ? widget.user.categoryName.first : 'Category'),
                ),
              ),
            ],
          ) : null,
          onTap: () {
            freelancerIdentifier2(widget.user.email, widget.user.uid, context);
          },
        ),
      ),
    );
  }
}

class User {
  final String email;
  final String uid;
  final String firstName;
  final String lastName;
  final bool freelancer;
  final List<dynamic> categoryName;

  const User({
    required this.email,
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.freelancer,
    required this.categoryName
  });

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (data.containsKey('freelancer')) {
      return User(
          email: data['email'],
          uid: data['uid'],
          firstName: data['first_name'],
          lastName: data['last_name'],
          freelancer: data['freelancer'],
          categoryName: data.containsKey('category_name') ? data['category_name'] : []
      );
    } else {
      return User(
          email: data['email'],
          uid: data['uid'],
          firstName: data['first_name'],
          lastName: data['last_name'],
          freelancer: false,
          categoryName: []
      );
    }
  }
}