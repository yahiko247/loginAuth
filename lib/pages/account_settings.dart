import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import  'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_data_services.dart';

class Item {

  String category_name;
  Item(this.category_name);
}

class FreelancerAccountSettings extends StatefulWidget{
  const FreelancerAccountSettings({super.key});
  
  @override
  State<FreelancerAccountSettings> createState() => _FreelancerAccountSettings();
}

class _FreelancerAccountSettings extends State<FreelancerAccountSettings>{

  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
  UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);


  @override
  void initState() {
    super.initState();
    refreshData();
    getDesc();
  }

  String categoryResponse = "Null";
  List<Item> categoryData = [];
  String descResponse = "Null";
  List<Item> descData = [];
  refreshData() async {
    var dataStr = jsonEncode({
      "command": "get_categories",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
    });
    var url = "http://192.168.1.2:80/categories.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      categoryData.clear();
      var jsonItems = jsonDecode(result.body) as List<dynamic>;
      for (var item in jsonItems) {
        categoryData.add(Item(
          item['category_name'] as String,
        ));
      }
    });
  }
  getDesc() async {
    var dataStr = jsonEncode({
      "command": "get_desc",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
    });
    var url = "http://192.168.1.2:80/categories.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      descData.clear();
      var jsonItems = jsonDecode(result.body) as List<dynamic>;
      for (var item in jsonItems) {
        descData.add(Item(
          item['description'] as String,
        ));
      }
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title:const Padding(
                  padding: EdgeInsets.only(bottom:3),
                  child: Text("Name",
                    style:
                    TextStyle(fontWeight: FontWeight.bold),),
                ),
                subtitle: FutureBuilder(
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
                            fontWeight: FontWeight.normal));
                        }),
                trailing: IconButton(
                          onPressed: (){

                        },
                          icon: const Icon(Icons.edit))
              ),


              const LineDivider(),
              ListTile(
              title:const Padding(
                padding: EdgeInsets.only(bottom:3),
                child: Text("Email",
                  style:
                  TextStyle(fontWeight: FontWeight.bold),),
              ),
              subtitle:FutureBuilder(
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
                            '${userData['email']}',
                            style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal));
                        }),
                  trailing: IconButton(
                      onPressed: (){

                      },
                      icon: const Icon(Icons.edit))
              ),
              const LineDivider(),
               ListTile(
                title:const Padding(
                  padding: EdgeInsets.only(bottom:3),
                  child: Text("Category",
                    style:
                    TextStyle(fontWeight: FontWeight.bold),),
                ),
                subtitle: Text(
                  categoryData.isNotEmpty ? categoryData[0].category_name : 'Category',
                  ),
                   trailing: IconButton(
                       onPressed: (){

                       },
                       icon: const Icon(Icons.edit))
              ),
              const LineDivider(),
              ListTile(
                title:const Text("Description",
                  style:  TextStyle(
                    fontWeight: FontWeight.bold),),
              subtitle:Text(
                descData.isNotEmpty ? descData[0].category_name : 'description',
                ),
             ),


            ],
          ),
        ],
      ),
    );
  }
}

class LineDivider extends StatelessWidget{
  const LineDivider({super.key});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(right: 15,top: 15,bottom: 15,left: 15),
      child: Container(
        width: double.infinity,
        height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.red,
        ),
      ),
    );
  }
}