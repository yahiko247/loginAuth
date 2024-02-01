import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/nested_tab/nestedtab2.dart';
import 'package:practice_login/nested_tab/nestedtab4.dart';
import 'package:practice_login/pages/booking.dart';
import 'package:practice_login/pages/chat/chat_box.dart';
import 'package:practice_login/services/user_data_services.dart';

import '../components/end_drawer.dart';

class FreelancerStalkPage extends StatelessWidget {
  String userEmail;
  FreelancerStalkPage({super.key, required this.userEmail});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
  UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  void navigatorDetails(
      BuildContext context,
      String userEmail,
      ) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookPage(userEmail: userEmail)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('images/Avatar1.png', height: 120),
                        Padding(
                          padding: const EdgeInsets.only(left: 3,),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: _userDataServices.getUserDataThroughEmail(userEmail),
                                builder: (context,snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting){
                                  return const Text("Category");
                                }
                                  Map<String,dynamic> snapshotdata = snapshot.data!.docs.first.data();

                                  return StreamBuilder(
                                      stream: _userDataServices.getUserDataAsStream(snapshotdata['uid']),
                                      builder: (context,usersnapshot){
                                        if (usersnapshot.connectionState == ConnectionState.waiting){
                                          return const Text("Category");
                                        }
                                        Map<String,dynamic> userData = usersnapshot.data!.data()!;
                                        if(userData.containsKey('categories') && userData['categories'].isNotEmpty){
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                userData['categories'].first ?? 'Category',
                                              ),
                                            ],
                                          );
                                        }else{
                                          return const Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Category',
                                              ),
                                            ],
                                          );
                                        }
                                      });
                                }
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: FutureBuilder(
                                          future: _userDataServices.getUserDataThroughEmail(userEmail),
                                          builder: (context, userDataSnapshot) {
                                            if (userDataSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text(
                                                 "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold));
                                            }
                                            if (userDataSnapshot.hasError) {
                                              return const Text(
                                                  "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold));
                                            }

                                            Map<String, dynamic>? userData =
                                            userDataSnapshot.data!.docs.first.data();
                                            return Text(userData['first_name'] +' ' + userData['last_name'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold));
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Container(
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
                                            'Freelancer Gold Member',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 9),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]),
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: const Icon(Icons.book),
                  onPressed: () {
                    navigatorDetails(context, userEmail);
                  },
                ),
              ),

              Padding(
                  padding: const EdgeInsets.only(right:5),
                  child: FutureBuilder(
                      future:
                      _userDataServices.getUserDataThroughEmail(userEmail),
                      builder: (context, userDataSnapshot) {
                        if (userDataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const IconButton(
                              icon: Icon(Icons.messenger), onPressed: null);
                        }
                        if (userDataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const IconButton(
                              icon: Icon(Icons.messenger), onPressed: null);
                        }

                        Map<String, dynamic>? userData;
                        if (userDataSnapshot.hasData) {
                          userData = userDataSnapshot.data!.docs.first.data();
                        }

                        return IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return ChatBox(
                                        userEmail: userEmail,
                                        userId: userData!['uid'],
                                        userFirstName: userData['first_name'],
                                        userLastName: userData['last_name'],
                                        origin: 'add_chat');
                                      }
                                    )
                               );
                              }
                            );
                       }
                      )
              ),

              Builder(builder: (context){
                return IconButton(
                    onPressed: (){
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.menu,size: 25,));
              }),

            ],
            backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            NestedTabBar4('first', userEmail: userEmail),
            NestedTabBar4('second', userEmail: userEmail),
            NestedTabBar4('third', userEmail: userEmail),
          ],
        ),
        endDrawer: const MyDrawer(),
      ),
    );
  }
}
