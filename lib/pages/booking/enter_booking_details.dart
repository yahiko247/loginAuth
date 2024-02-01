import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/pages/favorite.dart';
import 'package:practice_login/services/booking/booking_services.dart';
import 'package:practice_login/services/user_data_services.dart';


class ListProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> toDo) {
    _items.add(toDo);
    notifyListeners();
  }

  void editItem(int index, String newTitle, String newDescription) {
    _items[index]['title'] = newTitle;
    _items[index]['description'] = newDescription;
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

class EnterBookingDetails extends StatefulWidget {
  final DateTime startDate;
  final String freelancerEmail;
  final String freelancerId;
  const EnterBookingDetails({super.key, required this.startDate, required this.freelancerEmail, required this.freelancerId});

  @override
  State<EnterBookingDetails> createState() => _EnterBookingDetailsState();
}

class _EnterBookingDetailsState extends State<EnterBookingDetails> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  late DateTime startDate;
  DateTime? endDate;

  final _formKey = GlobalKey<FormState>();
  final BookingServices _bookingServices = BookingServices();
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final ListProvider _listProvider = ListProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDate = widget.startDate;
    startDateController.text = '${widget.startDate.day.toString()} / ${widget.startDate.month.toString()} / ${widget.startDate.year.toString()}';
  }

  @override
  void dispose() {
    super.dispose();
    startDateController.dispose();
    endDateController.dispose();
    locationController.dispose();
    messageController.dispose();
    durationController.dispose();
    budgetController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
  }

  void showBookReceipt(Map<String, dynamic> bookingDetails) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: StatefulBuilder(
                builder: (context, StateSetter setState) {
                  double width = MediaQuery.of(context).size.width;
                  return SingleChildScrollView(
                      child: FutureBuilder(
                          future: _userDataServices.getCurrentUserDataAsFuture(),
                          builder: (context, clientSnapshot) {
                            if (clientSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (clientSnapshot.hasError) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (clientSnapshot.hasData) {
                              Map<String, dynamic> clientData = clientSnapshot.data!.data()!;
                              return FutureBuilder(
                                  future: _userDataServices.getUserDataAsFuture(bookingDetails['freelancer_user_id']),
                                  builder: (context, freelancerSnapshot) {
                                    if (clientSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (clientSnapshot.hasError) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (freelancerSnapshot.hasData) {
                                      Map<String, dynamic> freelancerData = freelancerSnapshot.data!.data()!;
                                      return Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        width: width,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                width: width,
                                                child: ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  title: const Text(
                                                    'Booking Details',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                  subtitle: Text('${DateTime.timestamp().day.toString()}/${DateTime.timestamp().month.toString()}/${DateTime.timestamp().year.toString()}'),
                                                )
                                            ),
                                            const Divider(height: 1),
                                            Container(
                                              padding: const EdgeInsets.only(top: 5, bottom: 15),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                      width: width,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              text: 'Your request to book ${freelancerData['first_name']} ${freelancerData['last_name']} for ',
                                                              style: const TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 14.5
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                    text: '${bookingDetails['start_date'].day.toString()}/${bookingDetails['start_date'].month.toString()}/${bookingDetails['start_date'].year.toString()} '
                                                                        '- ${bookingDetails['end_date'].day.toString()}/${bookingDetails['end_date'].month.toString()}/${bookingDetails['end_date'].year.toString()}',
                                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                                    children: const [
                                                                      TextSpan(
                                                                          text: ' is underway. You may message them to discuss further details.',
                                                                          style: TextStyle(fontWeight: FontWeight.normal)
                                                                      )
                                                                    ]
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    width: width,
                                                    child: Text(
                                                      'Client: ${clientData['first_name']} ${clientData['last_name']}',
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    width: width,
                                                    child: Text(
                                                      'Freelancer: ${freelancerData['first_name']} ${freelancerData['last_name']}',
                                                    ),
                                                  ),
                                                  if (bookingDetails['location'].isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                      width: width,
                                                      child: Text(
                                                        'Location: ${bookingDetails['location']}',
                                                      ),
                                                    ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    width: width,
                                                    child: Text(
                                                      'Message: ${bookingDetails['message']}',
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    width: width,
                                                    child: Text(
                                                      'Duration: ${bookingDetails['start_date'].day.toString()}/${bookingDetails['start_date'].month.toString()}/${bookingDetails['start_date'].year.toString()} '
                                                          '- ${bookingDetails['end_date'].day.toString()}/${bookingDetails['end_date'].month.toString()}/${bookingDetails['end_date'].year.toString()}',
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    width: width,
                                                    child: Text(
                                                      'Budget: PHP ${bookingDetails['budget']}',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FavoritePage(initPage: 1)));
                                                },
                                                child: Container(
                                                  width: 100,
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(255, 70, 199, 177),
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  child: const Center(
                                                    child: Text('Done',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 18
                                                        )
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                    return Container();
                                  }
                              );
                            }
                            return Container();
                          }
                      )
                  );
                }
            ),
          );
        }
    );
  }

  void _addItem(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    final addFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        double width = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: const Text('To Do'),
          content: Form(
            key: addFormKey,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title cannot be empty!';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Title',
                        focusColor: Colors.black,
                        contentPadding: const EdgeInsets.all(13),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      controller: titleController,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      minLines: 4,
                      maxLines: 4,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: 'Add a description',
                        focusColor: Colors.black,
                        contentPadding: const EdgeInsets.all(13),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      controller: descriptionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (addFormKey.currentState!.validate()) {
                  Map<String, dynamic> newItem = {};
                  newItem['title'] = titleController.text;
                  newItem['description'] = descriptionController.text;
                  _listProvider.addItem(newItem);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editToDo(BuildContext context, int index) {
    TextEditingController titleController = TextEditingController(text: _listProvider.items[index]['title']);
    TextEditingController descriptionController = TextEditingController(text: _listProvider.items[index]['description']);
    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        double width = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Form(
            key: editFormKey,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title cannot be empty!';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Title',
                        focusColor: Colors.black,
                        contentPadding: const EdgeInsets.all(13),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      controller: titleController,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      minLines: 4,
                      maxLines: 4,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: 'Add a description',
                        focusColor: Colors.black,
                        contentPadding: const EdgeInsets.all(13),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      controller: descriptionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  _listProvider.editItem(index, titleController.text, descriptionController.text);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _removeToDo(BuildContext context, int index) {
    _listProvider.removeItem(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Enter Booking Details'),
        backgroundColor: Colors.white,
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WarningDialog(
                            title: 'Cancel Booking?',
                            message: 'Are you sure you want to cancel booking?',
                            confirmButtonText: 'Cancel Book',
                            cancelText: 'Continue',
                            confirmAction: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                        );
                      }
                  );
                },
                icon: const Icon(Icons.clear)
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Start date can\'t be empty!';
                              }
                              if (endDateController.text.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                            textAlign: TextAlign.center,
                            readOnly: true,
                            decoration: InputDecoration(
                              label: const Text('From'),
                              hintText: 'From',
                              focusColor: Colors.black,
                              contentPadding: const EdgeInsets.all(13),
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            controller: startDateController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'End date can\'t be empty!';
                              }
                              if (startDateController.text.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                            textAlign: TextAlign.center,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                selectableDayPredicate: (DateTime day) {
                                  return !day.isBefore(startDate.subtract(const Duration(days: 1)));
                                },
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null && pickedDate != startDate) {
                                setState (() {
                                  endDate = pickedDate;
                                  endDateController.text = '${pickedDate.day.toString()}/${pickedDate.month.toString()}/${pickedDate.year.toString()}';
                                  Duration duration = pickedDate.difference(startDate);
                                  if (duration.inDays > const Duration(days: 31).inDays) {
                                    durationController.text = 'Duration: ${((duration.inDays + 1) / 31).toStringAsFixed(2)} (months)';
                                  } else {
                                    durationController.text = '${startDate.day.toString()}/${startDate.month.toString()}/${startDate.year.toString()} - '
                                        '${pickedDate.day.toString()}/${pickedDate.month.toString()}/${pickedDate.year.toString()} '
                                        '(${(duration.inDays + 1).toString()} days)';
                                  }
                                });
                              }
                            },
                            decoration: InputDecoration(
                              label: const Text('To'),
                              hintText: 'To',
                              focusColor: Colors.black,
                              contentPadding: const EdgeInsets.all(13),
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            controller: endDateController,
                          ),
                        )
                      ],
                    ),
                  ),
                  TextFormField(
                    onTap: () {
                    },
                    decoration: InputDecoration(
                      label: const Text('Location (optional)'),
                      hintText: 'Location (optional)',
                      contentPadding: const EdgeInsets.all(13),
                      focusColor: Colors.black,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: locationController,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    onTap: () {
                    },
                    minLines: 4,
                    maxLines: 4,
                    maxLength: 150,
                    decoration: InputDecoration(
                      hintText: 'Message to freelancer',
                      focusColor: Colors.black,
                      contentPadding: const EdgeInsets.all(13),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: messageController,
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1),
                  Container(
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('To do (Optional)', textAlign: TextAlign.start, style: TextStyle(fontSize: 16)),
                                IconButton(
                                    onPressed: () {
                                      _addItem(context);
                                    },
                                    icon: const Icon(Icons.add, size: 25,)
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(7)),
                            ),
                            height: _listProvider.items.isEmpty ? 30.00 : 65.5 * _listProvider.items.length,
                            child: _listProvider.items.isEmpty ?
                            const Text('Tap the add button to add a to do', style: TextStyle(fontSize: 17, color: Colors.grey)) :
                            ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(_listProvider.items.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: const Color.fromRGBO(225, 225, 225, 1), // You can set your desired background color
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          _editToDo(context, index);
                                        },
                                        title: Text(_listProvider.items[index]['title']),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                _editToDo(context, index);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _removeToDo(context, index);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  TextFormField(
                    readOnly: true,
                    onTap: () {
                    },
                    decoration: InputDecoration(
                      label: const Text('Duration'),
                      hintText: 'Project duration',
                      focusColor: Colors.black,
                      contentPadding: const EdgeInsets.all(13),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: durationController,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'You must enter your budget / pricing';
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefix: const Text('PHP: '),
                      label: const Text('Budget / Pricing'),
                      hintText: 'Enter your budget',
                      focusColor: Colors.black,
                      contentPadding: const EdgeInsets.all(13),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: budgetController,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Your phone number is required to proceed';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefix: const Text('+63: '),
                      prefixIcon: const Icon(Icons.phone),
                      label: const Text('Phone Number'),
                      focusColor: Colors.black,
                      contentPadding: const EdgeInsets.all(13),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: phoneNumberController,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      label: const Text('Email Address (optional)'),
                      hintText: 'Your email address',
                      focusColor: Colors.black,
                      contentPadding: const EdgeInsets.all(13),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    controller: emailController,
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      Map<String, dynamic> bookingDetails = {};
                      if (_formKey.currentState!.validate()) {
                        if (messageController.text.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return WarningDialog(
                                    title: 'Confirm Booking?',
                                    message: 'Are you sure you want to leave the \'Message to freelancer\' field empty?',
                                    confirmButtonText: 'Confirm',
                                    confirmAction: () {
                                      Navigator.pop(context);
                                      bookingDetails['start_date'] = startDate;
                                      bookingDetails['end_date'] = endDate;
                                      bookingDetails['location'] = locationController.text;
                                      bookingDetails['message'] = messageController.text;
                                      bookingDetails['budget'] = budgetController.text;
                                      bookingDetails['client_contact_number'] = phoneNumberController.text;
                                      bookingDetails['client_email_address'] = emailController.text;
                                      bookingDetails['client_id'] = FirebaseAuth.instance.currentUser!.uid;
                                      bookingDetails['freelancer_email_address'] = widget.freelancerEmail;
                                      bookingDetails['freelancer_user_id'] = widget.freelancerId;
                                      bookingDetails['status'] = 'request'; ///request, ongoing, completed
                                      bookingDetails['booking_date'] = FieldValue.serverTimestamp();
                                      bookingDetails['to_dos'] = _listProvider.items;
                                      _bookingServices.createBook(bookingDetails);
                                      showBookReceipt(bookingDetails);
                                    }
                                );
                              }
                          );
                        } else {
                          bookingDetails['start_date'] = startDate;
                          bookingDetails['end_date'] = endDate;
                          bookingDetails['location'] = locationController.text;
                          bookingDetails['message'] = messageController.text;
                          bookingDetails['budget'] = budgetController.text;
                          bookingDetails['client_contact_number'] = phoneNumberController.text;
                          bookingDetails['client_email_address'] = emailController.text;
                          bookingDetails['client_id'] = FirebaseAuth.instance.currentUser!.uid;
                          bookingDetails['freelancer_email_address'] = widget.freelancerEmail;
                          bookingDetails['freelancer_user_id'] = widget.freelancerId;
                          bookingDetails['status'] = 'request'; ///request, ongoing, completed
                          bookingDetails['booking_date'] = FieldValue.serverTimestamp();
                          bookingDetails['to_dos'] = _listProvider.items;
                          _bookingServices.createBook(bookingDetails);
                          showBookReceipt(bookingDetails);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 70, 199, 177),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text('Confirm',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}