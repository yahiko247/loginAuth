import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/pages/booking/enter_booking_details.dart';
import 'package:practice_login/services/booking/booking_services.dart';
import 'package:flutter/services.dart';
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
                      message: 'Set a booking date starting on\n${today.day.toString()}/${today.month.toString()}/${today.year.toString()}',
                      confirmButtonText: 'Book',
                      confirmAction: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return EnterBookingDetails(
                                    startDate: day,
                                    freelancerEmail: userData['email'],
                                    freelancerId: userData['uid']
                                );
                              },
                              transitionDuration: Duration(milliseconds: 400),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.linearToEaseOut;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                            )
                        );
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
                            color: Colors.deepOrangeAccent),
                        child: const Center(child: Text("Unavailable", style: TextStyle(fontWeight: FontWeight.bold),))),
                  ),
                ),
                Expanded(
                  child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Color.fromRGBO(240, 240, 240, 1)),
                      child: const Center(child: Text("Available", style: TextStyle(fontWeight: FontWeight.bold)))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(
                        height: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.lightBlueAccent),
                        child: const Center(child: Text("Booked/Reserved", style: TextStyle(fontWeight: FontWeight.bold)))),
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
