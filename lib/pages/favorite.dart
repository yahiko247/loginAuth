import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/booking.dart';
import 'package:practice_login/services/booking/booking_services.dart';
import 'package:practice_login/services/user_data_services.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final BookingServices _bookingServices = BookingServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            TabBar.secondary(
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    text: 'Requests',
                  ),
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Completed'),
                ]
            ),
            Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: [
                      Card(
                        color: Colors.green,
                      ),
                      FutureBuilder(
                          future: _bookingServices.getOngoing(),
                          builder: (context, bookingSnapshot) {
                            if(bookingSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (bookingSnapshot.hasError) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (bookingSnapshot.hasData) {
                              Map<String, dynamic> onGoingBookingData = bookingSnapshot.data!;
                              List<dynamic> onGoingBooksAsList = [];
                              for (dynamic doc in onGoingBookingData['as_client']) {
                                onGoingBooksAsList.insert(0, doc);
                              }
                              for (dynamic doc in onGoingBookingData['as_freelancer']) {
                                onGoingBooksAsList.insert(0, doc);
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    itemCount: onGoingBooksAsList.length,
                                    itemBuilder: (context, index) {
                                      dynamic doc = onGoingBooksAsList[index];
                                      if (doc.data()['freelancer_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                        return ClientBook(bookData: doc.data());
                                      }
                                      if (doc.data()['client_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                        return ClientBook(bookData: doc.data());
                                      }
                                      return Container();
                                    }
                                ),
                              );
                            } else{
                              return Container();
                            }
                          }
                      ),
                      Card(
                        color: Colors.blue,
                      ),
                    ]
                )
            )
          ],
        )
    );
  }
}

class ClientBook extends StatefulWidget {
  final Map<String, dynamic> bookData;
  const ClientBook({super.key, required this.bookData});

  @override
  State<ClientBook> createState() => _ClientBookState();
}

class _ClientBookState extends State<ClientBook> {
  UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

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
                                                subtitle: Text('You booked on: ${DateTime.timestamp().day.toString()}/${DateTime.timestamp().month.toString()}/${DateTime.timestamp().year.toString()}'),
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
                                                            text: 'Booked ${freelancerData['first_name']} ${freelancerData['last_name']} for ',
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 14.5
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                  text: '${bookingDetails['start_date'].toDate().day.toString()}/${bookingDetails['start_date'].toDate().month.toString()}/${bookingDetails['start_date'].toDate().year.toString()} '
                                                                      '- ${bookingDetails['end_date'].toDate().day.toString()}/${bookingDetails['end_date'].toDate().month.toString()}/${bookingDetails['end_date'].toDate().year.toString()}',
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
                                                    'Duration: ${bookingDetails['start_date'].toDate().day.toString()}/${bookingDetails['start_date'].toDate().month.toString()}/${bookingDetails['start_date'].toDate().year.toString()} '
                                                        '- ${bookingDetails['end_date'].toDate().day.toString()}/${bookingDetails['end_date'].toDate().month.toString()}/${bookingDetails['end_date'].toDate().year.toString()}',
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
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    width: 125,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 70, 199, 177),
                                                      borderRadius: BorderRadius.circular(50),
                                                    ),
                                                    child: const Center(
                                                      child: Text('Complete',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: Color.fromRGBO(215, 215, 215, 1),
                                                      borderRadius: BorderRadius.circular(50),
                                                    ),
                                                    child: const Center(
                                                      child: Text('Close',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
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
  Widget build(BuildContext context){
    return FutureBuilder(
        future: _userDataServices.getUserDataAsFuture(widget.bookData['freelancer_user_id']),
        builder: (context, freelancerSnapshot) {
          if (freelancerSnapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/Avatar1.png'),
              ),
              title: Text(''),
              subtitle: Text(''),
              trailing: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(''),
                      Text("Booking Date")
                    ],
                  )
              ),
            );
          }
          if (freelancerSnapshot.hasError) {
            return ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/Avatar1.png'),
              ),
              title: Text('Error'),
              subtitle: Text(freelancerSnapshot.error.toString()),
              trailing: const SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(''),
                      Text("Booking Date")
                    ],
                  )
              ),
            );
          }
          if (freelancerSnapshot.hasData) {
            Map<String, dynamic> freelancerData = freelancerSnapshot.data!.data()!;
            return ListTile(
              onTap: () {
                showBookReceipt(widget.bookData);
              },
              leading: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/Avatar1.png'),
              ),
              title: Text('${freelancerData['first_name']} ${freelancerData['last_name']}'),
              subtitle: Text(freelancerData['email']),
              trailing: Container(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${widget.bookData['booking_date'].toDate().day.toString()}'
                          '/${widget.bookData['booking_date'].toDate().month.toString()}'
                          '/${widget.bookData['booking_date'].toDate().year.toString()}'),
                      Text("Booking Date")
                    ],
                  )
              ),
            );
          } else {
            return Container();
          }
        }
    );
  }
}