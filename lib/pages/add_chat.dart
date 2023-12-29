import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/add_contact.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:email_validator/email_validator.dart';
import 'chat_box.dart';

class AddChat extends StatefulWidget {
  const AddChat ({Key? key}) : super(key:key);

  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  final TextEditingController _searchController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start a conversation'),
        titleSpacing: 0,
        centerTitle: true,
        actions: [],
      ),
      body: Column(children: [RecipientInputForm(), Expanded(child: _buildContactList())]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: [Container(
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(child: Center(child: Text('Dialog Content'))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Add'),
                            ),
                            SizedBox(width: 50,),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        )
                      ],
                    ),
                  )]
                );
              }
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 124, 210, 231),
      ),
    );
  }

  Widget _buildContactList() {
    return FutureBuilder(
        future: _userDataServices.getCurrentUserDataAsFuture(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.hasError) {
            return const Center(child: Text('Error Loading Contacts'));
          } else if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading Contacts'));
          }

          Map<String, dynamic>? currentUserData = currentUserSnapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> checkContactList = currentUserData['contacts'];
          if (checkContactList.isEmpty) {
            return Container(
                padding: EdgeInsets.all(60),
                child: const Center(
                    child: Text(
                        'Tap the \'add\' button below to add a contact',
                        textAlign: TextAlign.center
                    )
                )
            );
          }

          return ListView(
            children: _buildContactItems(currentUserData),
          );
        }
    );
  }

  List<Widget> _buildContactItems(Map<String, dynamic> _currentUserData) {
    List<dynamic> contactList = _currentUserData['contacts'];

    List<Widget> contacts = contactList.map((contactID) {
      return FutureBuilder(
          future: _userDataServices.getUserDataAsFuture(contactID),
          builder: (context, contactSnapshot) {
            if (contactSnapshot.hasError) {
              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                title: Text('Error Loading User'),
                leading: Container(
                  child: Icon(Icons.person, size: 35),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                ),
                subtitle: Text(' '),
              );
            } else if (contactSnapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                title: Text('User'),
                leading: Container(
                  child: Icon(Icons.person, size: 35),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                ),
                subtitle: Text(' '),
              );;
            }

            Map<String, dynamic>? contactData = contactSnapshot.data!.data() as Map<String, dynamic>;
            String contactFullName = '${contactData['first_name']} ${contactData['last_name']}';

            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              title: Text(contactFullName),
              leading: Container(
                child: Icon(Icons.person, size: 35),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
              ),
              subtitle: Text('${contactData['email']}'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ChatBox(
                            userEmail: contactData['email'],
                            userId: contactData['uid'],
                            userFirstName: contactData['first_name'],
                            userLastName: contactData['last_name']
                        )
                    )
                );
              },
            );
          }
      );
    }).toList();

    return contacts;
  }

}

class RecipientInputForm extends StatefulWidget {
  const RecipientInputForm({Key? key}) : super(key: key);

  @override
  State<RecipientInputForm> createState() => _RecipientInputFormState();
}

class _RecipientInputFormState extends State<RecipientInputForm> {
  final TextEditingController _searchController = TextEditingController();
  bool isEmail = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  void _showDialog(BuildContext context, String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  if (!(value == '') && !(value == null)) {
                    (EmailValidator.validate(value)) ? isEmail = true : isEmail = false;
                  } else {
                    isEmail = false;
                  }
                });
              },
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Enter an email...',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: Container(child: Text('To:', style: TextStyle(color: Colors.grey[600], fontSize: 16),), padding: EdgeInsets.fromLTRB(15, 10, 10, 10),),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13)
              ),
            ),
          ),
          SizedBox(width: 13),
          IconButton(
            onPressed: isEmail ? () async {
              _userDataServices.getUserDataThroughEmail(_searchController.text).then((value) {
                if (value.docs.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FutureBuilder(
                        future: _userDataServices.getUserDataThroughEmail(_searchController.text),
                        builder: (context, userDataSnapshot) {
                          if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (userDataSnapshot.hasError){
                            return Text('Error Creating Chat');
                          }
                          Map<String, dynamic> userData = userDataSnapshot.data!.docs.first.data();

                          return ChatBox(userEmail: userData['email'],
                              userId: userData['uid'],
                              userFirstName: userData['first_name'],
                              userLastName: userData['last_name']
                          );
                        }
                    );
                  }));
                } else {
                  _showDialog(context, 'Error', 'The email you have entered does not exist.');
                }
              });
            } : null,
            icon: Icon(Icons.add),
            color: Colors.black, iconSize: 25,
          ),
        ],
      ),
    );
  }
}

