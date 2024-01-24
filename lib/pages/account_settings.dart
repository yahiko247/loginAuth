import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import  'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/user_data_services.dart';

class Item {
  String category_name;
  Item(this.category_name);
}
class Item2 {
  String categoryName;
  String categoryID;
  Item2(this.categoryName,this.categoryID);
}
class Item3 {
  String? price_id;
  String? priceRate_type;
  String? price; // Change the data type to double for the price
  Item3(this.price,this.priceRate_type,this.price_id);
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
  String selectedRateType = 'HOURLY';
  var priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
    getDesc();
    refreshData2();
    getPrice();
  }

  String categoryResponse = "Null";
  List<Item> categoryData = [];
  String descResponse = "Null";
  List<Item> descData = [];

  String allCatResponse = "Null";
  List<Item2> allCategoryData= [];

  String updateResponse = "Null";
  String selectedCategoryID = "";

  String priceResponse = "Null";
  List<Item3> priceData = [];



  refreshData2() async {
    var dataStr = jsonEncode({
      "command": "get_allcategories",
    });
    var url = "http://192.168.1.2:80/categories.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      allCategoryData.clear();
      var jsonItems = jsonDecode(result.body) as List<dynamic>;
      for (var item in jsonItems) {
        allCategoryData.add(Item2(
          item['category_name'] as String,
          item['category_id'] as String,
        ));
      }
    });
  }
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
  updateItem(String categoryID) async {
    var dataStr = jsonEncode({
      "command": "update",
      "category_id": categoryID,
      "user_id": FirebaseAuth.instance.currentUser!.uid,
    });
    var url = 'http://192.168.1.2:80/categories.php?data=$dataStr';
    var result = await http.get(Uri.parse(url));

    setState(() {
      updateResponse = result.body;
      refreshData();
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
  getPrice() async {
    var dataStr = jsonEncode({
      "command": "get_price",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
    });
    var url = "http://192.168.1.2:80/price.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      priceData.clear();
      var jsonItems = jsonDecode(result.body) as List<dynamic>;
      for (var item in jsonItems) {
        priceData.add(Item3(
          item['price'] as String,
          item['priceRate_type'] as String,
          item['price_id'] as String,
        ));
      }
    });
  }
  updatePrice() async {
    var dataStr = jsonEncode({
      "command": "update_price",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "priceRate_type" : selectedRateType,
      "price" : double.tryParse(priceController.text) ?? 0.0,
    });
    var url = "http://192.168.1.2:80/price.php?data=$dataStr";
    var result = await http.get(Uri.parse(url));
    setState(() {
      priceResponse = result.body;
      getPrice();
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
                         showDialog(context: context,
                             builder: (context) => AlertDialog(
                               title: const Text("Update"),
                               content: SizedBox(
                                 width: double.maxFinite,
                                 height: 200,
                                 child: ListView.builder(itemCount:allCategoryData.length,
                                     itemBuilder:(context, index)  {
                                       return ListTile(
                                         title: TextButton(
                                           onPressed: (){
                                             setState(() {
                                               selectedCategoryID = allCategoryData[index].categoryID;
                                             });
                                           },
                                             child: Row(
                                               children: [
                                                 Padding(
                                                   padding: const EdgeInsets.only(right: 3),
                                                   child: Text(allCategoryData[index].categoryID),
                                                 ),
                                                 Text(allCategoryData[index].categoryName),

                                               ],
                                             )),
                                       );
                                     }
                                 ),
                               ),
                               actions:  [
                                 ElevatedButton(
                                   onPressed: (){
                                     showDialog(
                                         context: context,
                                         builder: (context) => AlertDialog(
                                           content: const Text("Are you sure you want to change category?"),
                                           actions: [
                                             TextButton(
                                                 onPressed: (){
                                                   updateItem(selectedCategoryID);
                                                   Navigator.of(context).pop();
                                                 },
                                                 child: const Text("Yes")
                                             ),
                                             TextButton(
                                                 onPressed: (){
                                                   Navigator.of(context).pop();
                                                 },
                                                 child: const Text("No")
                                             ),
                                           ],
                                         )
                                     );

                                   },
                                     child: const Text("Update")
                                 ),
                               ],
                             ),
                         );
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
              const LineDivider(),
              ListTile(
                title: const Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  priceData.isNotEmpty
                      ? 'Price: ${priceData[0].price ?? 'N/A'}/${priceData[0].priceRate_type ?? 'N/A'}'
                      : 'No price available',
                ),
                trailing: IconButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Update Your Price"),
                            content: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return SizedBox(
                                  height: 100,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: priceController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onChanged: (value) =>
                                        priceData[0].price = value,
                                        decoration: InputDecoration(
                                            hintText: priceData.isNotEmpty ? priceData[0].price : 'Enter Price'
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: selectedRateType,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedRateType = newValue!;
                                          });
                                        },
                                        items: <String>['HOURLY', 'DAILY']
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                            actions: [
                              TextButton(onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: const Text("Are you sure you want to change your price?"),
                                      actions: [
                                        TextButton(
                                            onPressed: (){
                                              updatePrice();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Yes")
                                        ),
                                        TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("No")
                                        ),
                                      ],
                                    )
                                );
                              },
                                  child: const Text("Yes")),
                              TextButton(onPressed: () {
                                Navigator.of(context).pop();
                              },
                                  child: const Text("No")),
                            ],
                          )
                      );
                    },
                    icon: const Icon(Icons.edit)) ,
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
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}

