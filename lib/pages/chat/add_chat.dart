import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/chat/error_view.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:email_validator/email_validator.dart';
import 'chat_box.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:practice_login/Components/chat/empty_view.dart';

class AddChat extends StatefulWidget {
  const AddChat ({super.key});

  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Contacts'),
        titleSpacing: 0,
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
          child: const ContactList()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddContactDialog();
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
        child: const Icon(Icons.add),
      ),
    );
  }

}

class ContactList extends StatefulWidget {
  final bool? autoFocus;
  const ContactList({super.key, this.autoFocus});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  final TextEditingController _searchController = TextEditingController();

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
    return FutureBuilder(
        future: _userDataServices.getCurrentUserDataAsFuture(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (currentUserSnapshot.hasError) {
            return const Dialog(child: Text('An error has occurred'),);
          }

          var userData = currentUserSnapshot.data!.data();
          List<dynamic> contactList = userData!['contacts'];

          if (contactList.isEmpty) {
            return const EmptyView(
                displayIcon: true,
                message:'There are no contacts to be found here. To add a contact, tap the add button below.'
            );
          }

          return FutureBuilder(
              future: _fireStore.collection('users').where(FieldPath.documentId, whereIn: contactList).get(),
              builder: (context, contactsSnapshot) {
                if (contactsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (contactsSnapshot.hasError) {
                  return const Dialog(child: Text('An error has occurred'),);
                }

                var contactsDocs = contactsSnapshot.data!.docs;
                List<ContactUser> contacts = contactsDocs.map((doc) {
                  return ContactUser.fromSnapshot(doc);
                }).toList();

                return SearchableList<ContactUser>(
                  autoFocusOnSearch: widget.autoFocus ?? false,
                  style: const TextStyle(fontSize: 16),
                  searchTextController: _searchController,
                  builder: (list, index, item) {
                    return ContactUserItem(contact: item);
                  },
                  initialList: contacts,
                  filter: (p0) {
                    return contacts.where((element) => element.firstName.toLowerCase().contains(p0.toLowerCase())
                        || element.lastName.toLowerCase().contains(p0.toLowerCase())
                        || ('${element.firstName.toLowerCase()}${element.lastName.toLowerCase()}').replaceAll(' ', '').contains(p0.replaceAll(' ', '').toLowerCase())
                        || element.email.toLowerCase().contains(p0.toLowerCase())).toList();
                  },
                  emptyWidget: const EmptyView(
                      message: '\nContact not found.\n\nTap the add button below to add a new contact.',
                      displayIcon: true,
                      padding: EdgeInsets.fromLTRB(35, 60, 35, 0)
                  ),
                  errorWidget: const ErrorView(
                      message: 'Error while fetching contacts!',
                      displayIcon: true,
                      padding: EdgeInsets.fromLTRB(35, 50, 35, 0)
                  ),
                  spaceBetweenSearchAndList: 10,
                  inputDecoration: InputDecoration(
                    hintText: 'Search',
                    focusColor: Colors.black,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Icon(Icons.contacts, color: Colors.grey[600]),),
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
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
  final String firstName;
  final String lastName;

  const ContactUser({
    required this.email,
    required this.uid,
    required this.firstName,
    required this.lastName
  });

  factory ContactUser.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ContactUser(email: data['email'], uid: data['uid'], firstName: data['first_name'], lastName: data['last_name']);
  }

  factory ContactUser.fromMap(Map<String, dynamic> data) {
    return ContactUser(email: data['email'], uid: data['uid'], firstName: data['first_name'], lastName: data['last_name']);
  }
}

class ContactUserItem extends StatelessWidget {
  final ContactUser contact;
  final Color? textColor;

  const ContactUserItem({super.key, required this.contact, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Text('${contact.firstName} ${contact.lastName}', style: TextStyle(color: textColor ?? Colors.black),),
        leading: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: Image.asset('images/Avatar1.png', height: 50),
        ),
        subtitle: Text(contact.email, style: TextStyle(color: (textColor ?? Colors.black).withOpacity(0.6),),),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ChatBox(
                    userEmail: contact.email,
                    userId: contact.uid,
                    userFirstName: contact.firstName,
                    userLastName: contact.lastName,
                    origin: 'add_chat',
                  )
              )
          );
        },
      )
    );
  }
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});
  
  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final TextEditingController _addEmailController = TextEditingController();

  bool isEmailAndExists = false;

  @override
  void initState() {
    _addEmailController.addListener(_isEmailAndExists);
    super.initState();
  }

  @override
  void dispose() {
    _addEmailController.removeListener(_isEmailAndExists);
    _addEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.black.withOpacity(0.8),
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: TextFormField(
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          controller: _addEmailController,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
                              hintStyle: const TextStyle(color: Colors.white),
                              hintText: 'Enter an email',
                              prefixIcon: Container( padding: const EdgeInsets.fromLTRB(5, 0, 0, 0), child: const Icon(Icons.email, color: Colors.white)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13)
                          ),
                        ),
                      )
                  )
                ],
              ),
              _addEmailController.text == ''
                  ? const EmptyView(displayIcon: false, message: 'Please enter an email', textColor: Colors.white)
                  : (EmailValidator.validate(_addEmailController.text))
                  ? isEmailAndExists
                  ? _addNewContactItem()
                  : const EmptyView(displayIcon: true, message: 'The email you have entered doesn\'t seem to exist.', textColor: Colors.white)
                  : const EmptyView(displayIcon: false, message: 'Please enter a valid email', textColor: Colors.white),
            ]
        ),
      ),
    );
  }

  void _isEmailAndExists() {
    if (EmailValidator.validate(_addEmailController.text)) {
      Future<QuerySnapshot<Map<String, dynamic>>> snapshot = _fireStore.collection('users').where('email', isEqualTo: _addEmailController.text).get();
      snapshot.then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            isEmailAndExists = true;
          });
        } else {
          setState(() {
            isEmailAndExists = false;
          });
        }
      });
    }
    setState(() {
      isEmailAndExists = false;
    });
  }

  Widget _addNewContactItem() {
    return FutureBuilder(
        future: _userDataServices.getUserDataThroughEmail(_addEmailController.text),
        builder: (context, userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userDataSnapshot.hasError) {
            return const ErrorView(message: 'An error has occurred!', displayIcon: true);
          }

          Map<String, dynamic>? userData = userDataSnapshot.data!.docs.first.data();
          ContactUser newContactUser = ContactUser.fromMap(userData);

          return ContactUserItem(contact: newContactUser, textColor: Colors.white);
        }
    );
  }
}