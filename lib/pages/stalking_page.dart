import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:practice_login/nested_tab/nestedtab2.dart';
import 'package:practice_login/services/user_data_services.dart';

import 'chat/chat_box.dart';

class StalkPage extends StatelessWidget {
  String userEmail;
  StalkPage({super.key, required this.userEmail});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
      UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Row(
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 10, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('images/Avatar1.png', height: 120),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 50),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder(
                                      future: _userDataServices
                                          .getUserDataAsFuture(currentUser.uid),
                                      builder: (context, userDataSnapshot) {
                                        if (userDataSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(
                                              currentUser.email!.toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold));
                                        }
                                        if (userDataSnapshot.hasError) {
                                          return Text(
                                              currentUser.email!.toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold));
                                        }

                                        Map<String, dynamic>? userData =
                                            userDataSnapshot.data!.data()!;
                                        return Text(userEmail,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold));
                                      }),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: 120,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 209, 207, 207),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 5, top: 3),
                                      child: Text(
                                        'Gold Member',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 9),
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        )
                      ],
                    )),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(1),
                child: FutureBuilder(
                  future: _userDataServices.getUserDataThroughEmail(userEmail),
                  builder: (context, userDataSnapshot) {
                    if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                      return const IconButton(
                        icon: Icon(Icons.messenger),
                        onPressed: null
                      );
                    }
                    if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                      return const IconButton(
                        icon: Icon(Icons.messenger),
                        onPressed: null
                      );
                    }

                    Map<String, dynamic>? userData;
                    if (userDataSnapshot.hasData) {
                      userData = userDataSnapshot.data!.docs.first.data();
                    }

                    return IconButton(
                        icon: const Icon(Icons.messenger),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return ChatBox(
                                        userEmail: userEmail,
                                        userId: userData!['uid'],
                                        userFirstName: userData['first_name'],
                                        userLastName: userData['last_name'],
                                        origin: 'add_chat'
                                    );
                                  }
                              )
                          );
                        }
                    );
                  }
                )
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: Icon(Icons.book),
                  onPressed: () {},
                ),
              )
            ],
            backgroundColor: Color.fromARGB(255, 107, 199, 191),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            NestedTabBar2('first', userEmail: userEmail),
            NestedTabBar2(
              'second tab',
              userEmail: userEmail,
            )
          ],
        ),
      ),
    );
  }
}
