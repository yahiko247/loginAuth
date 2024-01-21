import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/nested_tab/nestedtab.dart';
import 'package:practice_login/components/end_drawer.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'calendar.dart';
import 'chat/chat_page.dart';

class Item {

  String category_name;
  Item(this.category_name);
}

class FreelancerProfilePage extends StatefulWidget{
  const FreelancerProfilePage({super.key});
  @override
  State<FreelancerProfilePage> createState() => _FreelancerProfilePage();
}

class _FreelancerProfilePage extends State<FreelancerProfilePage> {

  String response = "Null";
  List<Item> data = [];

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  refreshData() async {
    var dataStr = jsonEncode({
      "command": "get_categories",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
    });
    var url = "http://192.168.1.2:80/categories.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      data.clear();
      var jsonItems = jsonDecode(result.body) as List<dynamic>;
      for (var item in jsonItems) {
        data.add(Item(
          item['category_name'] as String,
        ));
      }
    });
  }

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 70,backgroundImage: AssetImage('images/Avatar1.png')),
                        Padding(
                          padding: const EdgeInsets.only(left:3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    data.isNotEmpty ? data[0]?.category_name ?? 'Category' : 'Category',
                                  ),
                                ],
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: FutureBuilder(
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left:5),
                                      child: Container(
                                        width: 120,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 209, 207, 207),
                                            borderRadius:
                                            BorderRadius.circular(20)),
                                        child: const Center(
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
                                  ])
                            ],
                          ),
                        ),

                      ],
                    )),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalendarSchedule()));
                        },
                        icon: const Icon(Icons.calendar_month,size: 25,))
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child:IconButton(
                        onPressed: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const ChatPage()));
                        },
                        icon: const Icon(Icons.message,size: 25,)
                    ),
                  ),
                  Builder(builder: (context){
                  return IconButton(
                      onPressed: (){
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(Icons.menu,size: 25,));
                  }),
                ],
              ),
            ],
            backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            NestedTabBar('first Page'),
            NestedTabBar('secondTab')
          ],
        ),
        endDrawer: const MyDrawer(),
      ),
    );
  }
}