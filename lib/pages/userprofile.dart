import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/nested_tab/nestedtab.dart';
import 'package:practice_login/components/end_drawer.dart';
import 'package:practice_login/services/user_data_services.dart';

class UserProfilePage extends StatelessWidget {
  UserProfilePage({super.key});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
  UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

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
                                        return Text(
                                            '${userData['first_name']} ${userData['last_name']}',
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
                                        'Clients Gold Member',
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
            backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            NestedTabBar('first Page')
          ],
        ),
        endDrawer: const MyDrawer(),
      ),
    );
  }
}