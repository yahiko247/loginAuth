import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/services/booking/booking_services.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:table_calendar/table_calendar.dart';


class BookPage extends StatefulWidget {
  final String userEmail;
  const BookPage({super.key, required this.userEmail});

  @override
  State<BookPage> createState() => _BookPage(userEmail: userEmail);
}

class _BookPage extends State<BookPage> {
  final String userEmail;
  _BookPage({required this.userEmail});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final BookingServices _bookingServices = BookingServices();
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
    showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder(
              future: _userDataServices.getUserDataThroughEmail(widget.userEmail),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasData) {
                  Map<String, dynamic> userData = userSnapshot.data!.docs.first.data();
                  return WarningDialog(
                      title: 'Set booking date?',
                      message: today.toString(),
                      confirmButtonText: 'Book',
                      confirmAction: () {
                        Navigator.pop(context);
                        enterBookingDetails(today, userData);
                      }
                  );
                } else {
                  return WarningDialog(
                      title: 'An unknown error has occured',
                      message: 'Try to restart the application or check your internet connection',
                      confirmButtonText: 'Ok',
                      confirmAction: () {
                        Navigator.pop(context);
                      }
                  );
                }
              }
          );
        }
    );
  }

  void enterBookingDetails(DateTime bookDate, Map<String, dynamic> userData) {
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController messageController = TextEditingController();
    TextEditingController durationController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    DateTime? pickedDate;

    setState(() {
      startDateController.text = '${bookDate.day.toString()} / ${bookDate.month.toString()} / ${bookDate.year.toString()}';
    });

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: StatefulBuilder(
              builder: (context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Container(
                    width: 500,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.clear)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text('From'),
                                  hintText: 'From',
                                  focusColor: Colors.black,
                                  contentPadding: EdgeInsets.all(13),
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                controller: startDateController,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                readOnly: true,
                                onTap: () async {
                                  DateTime selectedDate = bookDate;
                                  pickedDate = await showDatePicker(
                                    selectableDayPredicate: (DateTime day) {
                                      return !day.isBefore(selectedDate.subtract(const Duration(days: 1)));
                                    },
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  if (pickedDate != null && pickedDate != selectedDate) {
                                    setState (() {
                                      endDateController.text = '${pickedDate!.day.toString()}/${pickedDate!.month.toString()}/${pickedDate!.year.toString()}';
                                      Duration duration = pickedDate!.difference(bookDate);
                                      if (duration.inDays > Duration(days: 31).inDays) {
                                        durationController.text = 'Duration: ${((duration.inDays + 1) / 31).toStringAsFixed(2)} (months)';
                                      } else {
                                        durationController.text = '${pickedDate!.day.toString()}/${pickedDate!.month.toString()}/${pickedDate!.year.toString()} - '
                                            '${bookDate.day.toString()}/${bookDate.month.toString()}/${bookDate.year.toString()} '
                                            '(${(duration.inDays + 1).toString()} days)';
                                      }
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  label: Text('To'),
                                  hintText: 'To',
                                  focusColor: Colors.black,
                                  contentPadding: EdgeInsets.all(13),
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                controller: endDateController,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          onTap: () {
                          },
                          decoration: InputDecoration(
                            label: Text('Location'),
                            hintText: 'Location (optional)',
                            contentPadding: EdgeInsets.all(13),
                            focusColor: Colors.black,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: locationController,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          onTap: () {
                          },
                          minLines: 4,
                          maxLines: 4,
                          maxLength: 150,
                          decoration: InputDecoration(
                            hintText: 'Message to freelancer',
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: messageController,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                          },
                          decoration: InputDecoration(
                            label: Text('Duration'),
                            hintText: 'Project duration',
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: durationController,
                        ),
                        SizedBox(height: 15),
                        TextField(
                          keyboardType: TextInputType.numberWithOptions(),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            prefix: Text('PHP: '),
                            label: Text('Budget / Pricing'),
                            hintText: 'Enter your budget',
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: budgetController,
                        ),
                        SizedBox(height: 15),
                        TextField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            prefix: Text('+63: '),
                            prefixIcon: Icon(Icons.phone),
                            label: Text('Phone Number'),
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: phoneNumberController,
                        ),
                        SizedBox(height: 15),
                        TextField(
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            label: Text('Email Address (optional)'),
                            hintText: 'Your email address',
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          controller: emailController,
                        ),
                        SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Map<String, dynamic> bookingDetails = {};
                            bookingDetails['start_date'] = bookDate;
                            bookingDetails['end_date'] = pickedDate;
                            bookingDetails['location'] = locationController.text;
                            bookingDetails['message'] = messageController.text;
                            bookingDetails['budget'] = budgetController.text;
                            bookingDetails['client_contact_number'] = phoneNumberController.text;
                            bookingDetails['client_email_address'] = emailController.text;
                            bookingDetails['client_id'] = FirebaseAuth.instance.currentUser!.uid;
                            bookingDetails['freelancer_email_address'] = userData['email'];
                            bookingDetails['freelancer_user_id'] = userData['uid'];
                            bookingDetails['booking_date'] = FieldValue.serverTimestamp();
                            _bookingServices.createBook(bookingDetails);
                            showBookReceipt(bookingDetails);
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
                );
              }
          ),
        )
    );
  }

  void showBookReceipt(Map<String, dynamic> bookingDetails) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
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
                          return Center(child: CircularProgressIndicator());
                        }
                        if (clientSnapshot.hasError) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (clientSnapshot.hasData) {
                          Map<String, dynamic> clientData = clientSnapshot.data!.data()!;
                          return FutureBuilder(
                              future: _userDataServices.getUserDataAsFuture(bookingDetails['freelancer_user_id']),
                              builder: (context, freelancerSnapshot) {
                                if (clientSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (clientSnapshot.hasError) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (freelancerSnapshot.hasData) {
                                  Map<String, dynamic> freelancerData = freelancerSnapshot.data!.data()!;
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                    width: width,
                                    child: Column(
                                      children: [
                                        Container(
                                            width: width,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                'Booking Details',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              subtitle: Text('${DateTime.timestamp().day.toString()}/${DateTime.timestamp().month.toString()}/${DateTime.timestamp().year.toString()}'),
                                            )
                                        ),
                                        Divider(height: 1),
                                        Container(
                                          padding: EdgeInsets.only(top: 5, bottom: 15),
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5),
                                                  width: width,
                                                  child: RichText(
                                                      text: TextSpan(
                                                          text: 'You have successfully booked ${freelancerData['first_name']} ${freelancerData['last_name']} for ',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14.5
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                                text: '${bookingDetails['start_date'].day.toString()}/${bookingDetails['start_date'].month.toString()}/${bookingDetails['start_date'].year.toString()} '
                                                                    '- ${bookingDetails['end_date'].day.toString()}/${bookingDetails['end_date'].month.toString()}/${bookingDetails['end_date'].year.toString()}',
                                                                style: TextStyle(fontWeight: FontWeight.bold)
                                                            )
                                                          ]
                                                      )
                                                  )
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                width: width,
                                                child: Text(
                                                  'Client: ${clientData['first_name']} ${clientData['last_name']}',
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                width: width,
                                                child: Text(
                                                  'Freelancer: ${freelancerData['first_name']} ${freelancerData['last_name']}',
                                                ),
                                              ),
                                              if (bookingDetails['location'].isNotEmpty)
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5),
                                                  width: width,
                                                  child: Text(
                                                    'Location: ${bookingDetails['location']}',
                                                  ),
                                                ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                width: width,
                                                child: Text(
                                                  'Message: ${bookingDetails['message']}',
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                width: width,
                                                child: Text(
                                                  'Duration: ${bookingDetails['start_date'].day.toString()}/${bookingDetails['start_date'].month.toString()}/${bookingDetails['start_date'].year.toString()} '
                                                      '- ${bookingDetails['end_date'].day.toString()}/${bookingDetails['end_date'].month.toString()}/${bookingDetails['end_date'].year.toString()}',
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                width: width,
                                                child: Text(
                                                  'Budget: PHP ${bookingDetails['budget']}',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: 50,
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
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              future: _userDataServices.getUserDataThroughEmail(userEmail),
                              builder: (context, userDataSnapshot) {
                                if (userDataSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                if (userDataSnapshot.hasError) {
                                  return Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                Map<String, dynamic>? userData =
                                userDataSnapshot.data!.docs.first.data();
                                return Text(userData['first_name'] +' ' + userData['last_name'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 120,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 209, 207, 207),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 5, top: 3),
                                child: Text(
                                  'Gold Member',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 124, 210, 231),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                        height: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.deepOrange),
                        child: const Center(child: Text("Unavailable"))),
                  ),
                ),
                Expanded(
                  child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.green),
                      child: const Center(child: Text("Available"))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(
                        height: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.lightBlueAccent),
                        child: const Center(child: Text("Booked/Reserved"))),
                  ),
                ),
              ],
            ),
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 252, 252),
                      borderRadius: BorderRadius.circular(10)),
                  child: content(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Selected day${today.toString().split(" ")[0]}'),
            Container(
              child: TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                enabledDayPredicate: (day) {
                  return !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                },
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: today,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 10, 14),
                onDaySelected: _onDaySelected,
                calendarStyle: const CalendarStyle(
                    todayTextStyle: TextStyle(color: Colors.black),
                    weekNumberTextStyle: TextStyle(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
