import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:table_calendar/table_calendar.dart';

class BookPage extends StatefulWidget {
  final String userEmail;
  const BookPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPage(userEmail: userEmail);
}

class _BookPage extends State<BookPage> {
  final String userEmail;
  _BookPage({required this.userEmail});

  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
      UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
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
                              future: _userDataServices
                                  .getUserDataAsFuture(currentUser.uid),
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
                                    userDataSnapshot.data!.data()!;
                                return Text(
                                  userEmail,
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
          backgroundColor: const Color.fromARGB(255, 107, 199, 191),
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
                      color: Color.fromARGB(255, 253, 252, 252),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('Selected day' + today.toString().split(" ")[0]),
          Container(
            child: TableCalendar(
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 10, 14),
              onDaySelected: _onDaySelected,
              calendarStyle: CalendarStyle(
                  todayTextStyle: TextStyle(color: Colors.black),
                  weekNumberTextStyle: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}
