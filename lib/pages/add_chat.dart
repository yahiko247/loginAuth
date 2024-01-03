import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:email_validator/email_validator.dart';
import 'chat_box.dart';
import 'package:searchable_listview/searchable_listview.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        titleSpacing: 0,
        centerTitle: true,
        actions: [],
      ),
      body: Container(child: _searchableContactList(), padding: EdgeInsets.fromLTRB(15, 10, 15, 0),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return BottomSheet();
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 124, 210, 231),
      ),
    );
  }

  Widget _searchableContactList() {
    return FutureBuilder(
        future: _userDataServices.getCurrentUserDataAsFuture(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (currentUserSnapshot.hasError) {
            return Dialog(child: Text('An error has occured'),);
          }
          
          Map<String, dynamic>? userData = currentUserSnapshot.data!.data();
          List<dynamic> contactList = userData!['contacts'];
          
          return FutureBuilder(
              future: _firestore.collection('users').where(FieldPath.documentId, whereIn: contactList).get(),
              builder: (context, contactsSnapshot) {
                if (contactsSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (contactsSnapshot.hasError) {
                  return Dialog(child: Text('An error has occured'),);
                }

                var contactsDocs = contactsSnapshot.data!.docs;
                List<ContactUser> contacts = contactsDocs.map((doc) {
                  return ContactUser.fromSnapshot(doc);
                }).toList();

                return SearchableList<ContactUser>(
                  listViewPadding: EdgeInsets.zero,
                  style: const TextStyle(fontSize: 16),
                  searchTextController: _searchController,
                  builder: (list, index, item) {
                    return ContactUserItem(contact: item, doublePop: false);
                  },
                  errorWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Error while fetching actors')
                    ],
                  ),
                  initialList: contacts,
                  filter: (p0) {
                    return contacts.where((element) => element.first_name.toLowerCase().contains(p0.toLowerCase()) ||
                        element.last_name.toLowerCase().contains(p0.toLowerCase()) ||
                        ('${element.first_name.toLowerCase()}${element.last_name.toLowerCase()}').contains(p0.replaceAll(' ', '').toLowerCase()) ||
                        element.email.toLowerCase().contains(p0.toLowerCase())).toList();
                  },
                  reverse: false,
                  emptyWidget: Column(children: [const SizedBox(height: 150), EmptyView(displayIcon: true, message: 'Contact not found.\n\nTap the add button below to add a new contact.')]),
                  onRefresh: () async {},
                  onItemSelected: (ContactUser item) {},
                  spaceBetweenSearchAndList: 10,
                  inputDecoration: InputDecoration(
                    focusColor: Colors.black,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Container(child: Text('To:', style: TextStyle(color: Colors.grey[600], fontSize: 16),), padding: EdgeInsets.fromLTRB(15, 10, 10, 10)),
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                );
              }
          );
        }
    );
  }
}

class ContactUser {
  final String email;
  final String uid;
  final String first_name;
  final String last_name;

  const ContactUser({
    required this.email,
    required this.uid,
    required this.first_name,
    required this.last_name
  });

  factory ContactUser.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ContactUser(email: data['email'], uid: data['uid'], first_name: data['first_name'], last_name: data['last_name']);
  }

  factory ContactUser.fromMap(Map<String, dynamic> data) {
    return ContactUser(email: data['email'], uid: data['uid'], first_name: data['first_name'], last_name: data['last_name']);
  }
}

class ContactUserItem extends StatelessWidget {
  final ContactUser contact;
  final bool doublePop;

  const ContactUserItem({Key? key, required this.contact, required this.doublePop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(5),
      title: Text('${contact.first_name} ${contact.last_name}'),
      leading: Container(
        child: Icon(Icons.person, size: 35),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
      ),
      subtitle: Text('${contact.email}'),
      onTap: () {
        Navigator.pop(context);
        doublePop ? Navigator.pop(context) : null;
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                ChatBox(
                    userEmail: contact.email,
                    userId: contact.uid,
                    userFirstName: contact.first_name,
                    userLastName: contact.last_name
                )
            )
        );
      },
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  final bool displayIcon;

  EmptyView({Key? key, required this.message, required this.displayIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.fromLTRB(35, 0, 35, 0), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          displayIcon! ? Icon(
            Icons.question_mark,
            color: Colors.red,
          ) : Container(),
          const SizedBox(height: 5,),
          Text(message, textAlign: TextAlign.center,),
        ],
      ));
    }
}

class BottomSheet extends StatefulWidget {
  const BottomSheet({Key? key}) : super(key: key);
  
  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final TextEditingController _addEmailController = TextEditingController();

  bool isEmail = false;

  @override
  void initState() {
    _addEmailController.addListener(_isEmail);
    super.initState();
  }

  @override
  void dispose() {
    _addEmailController.removeListener(_isEmail);
    _addEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(15),
      height: 300, // Adjust height as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      controller: _addEmailController,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                          hintText: 'Enter an email',
                          prefixIcon: Container(child: Icon(Icons.email, color: Colors.grey[600],), padding: EdgeInsets.fromLTRB(5, 0, 0, 0),),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13)
                      ),
                    ),
                  )
                )
              ],
            ),
          ),
          _addEmailController.text == ''
              ? Column(children: [SizedBox(height: 75), EmptyView(displayIcon: false, message: 'Please enter an email')])
              : (EmailValidator.validate(_addEmailController.text))
              ? isEmail
              ? _addNewContactItem()
              : Column(children: [SizedBox(height: 50), EmptyView(displayIcon: true, message: 'The email you have entered doesn\'t seem to exist.')])
              : Column(children: [SizedBox(height: 75), EmptyView(displayIcon: false, message: 'Please enter a valid email')]),
        ]
      ),
    );
  }

  void _isEmail() {
    if (EmailValidator.validate(_addEmailController.text)) {
      Future<QuerySnapshot<Map<String, dynamic>>> snapshot = _firestore.collection('users').where('email', isEqualTo: _addEmailController.text).get();
      snapshot.then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            isEmail = true;
          });
        } else {
          setState(() {
            isEmail = false;
          });
        }
      });
    }
    setState(() {
      isEmail = false;
    });
  }

  Widget _addNewContactItem() {
    return FutureBuilder(
        future: _userDataServices.getUserDataThroughEmail(_addEmailController.text),
        builder: (context, userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userDataSnapshot.hasError) {
            return Dialog(child: Text('An error has occured'),);
          }

          Map<String, dynamic>? userData = userDataSnapshot.data!.docs.first.data();
          ContactUser newContactUser = ContactUser.fromMap(userData);

          return ContactUserItem(contact: newContactUser, doublePop: true,);
        }
    );
  }
}