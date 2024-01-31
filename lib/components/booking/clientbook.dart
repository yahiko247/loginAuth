import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/booking/to_dos.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/pages/booking/booking_details.dart';
import 'package:practice_login/services/booking/booking_services.dart';
import 'package:practice_login/services/user_data_services.dart';

class ClientBook extends StatefulWidget {
  final Map<String, dynamic> bookData;
  final String bookId;
  final String status;
  const ClientBook({super.key, required this.bookData, required this.bookId, required this.status});

  @override
  State<ClientBook> createState() => _ClientBookState();
}

class _ClientBookState extends State<ClientBook> {
  UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final BookingServices _bookingServices = BookingServices();

  void showRequestReceipt(Map<String, dynamic> bookingDetails) {
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
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      width: width,
                                      child: Column(
                                        children: [
                                          if (widget.status != 'completed')
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: 25),
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
                                                  trailing: InkWell(child: Icon(Icons.clear, size: 28,), onTap: () {Navigator.pop(context);}),
                                                  subtitle: Text('Request sent: ${bookingDetails['booking_date'].toDate().day.toString()}/${bookingDetails['booking_date'].toDate().month.toString()}/${bookingDetails['booking_date'].toDate().year.toString()}'),
                                                )
                                            ),
                                          if (widget.status == 'completed')
                                            Container(
                                                padding: EdgeInsets.symmetric(horizontal: 25),
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
                                                  trailing: InkWell(child: Icon(Icons.clear, size: 28,), onTap: () {Navigator.pop(context);}),
                                                  subtitle: Text('Date Completed: ${bookingDetails['completed_date'].toDate().day.toString()}/${bookingDetails['completed_date'].toDate().month.toString()}/${bookingDetails['completed_date'].toDate().year.toString()}'),
                                                )
                                            ),
                                          Divider(height: 1),
                                          Container(
                                            padding: EdgeInsets.only(top: 5, bottom: 15),
                                            child: Column(
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                    width: width,
                                                    child: RichText(
                                                        text: TextSpan(
                                                            text: 'Requested booking ${freelancerData['first_name']} ${freelancerData['last_name']} for ',
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
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                  width: width,
                                                  child: Text(
                                                    'Client: ${clientData['first_name']} ${clientData['last_name']}',
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                  width: width,
                                                  child: Text(
                                                    'Freelancer: ${freelancerData['first_name']} ${freelancerData['last_name']}',
                                                  ),
                                                ),
                                                if (bookingDetails['location'].isNotEmpty)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                    width: width,
                                                    child: Text(
                                                      'Location: ${bookingDetails['location']}',
                                                    ),
                                                  ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                  width: width,
                                                  child: Text(
                                                    'Message: ${bookingDetails['message']}',
                                                  ),
                                                ),
                                                if (bookingDetails['to_dos'].isNotEmpty)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                    width: width,
                                                    child: Text(
                                                      'To Dos (${bookingDetails['to_dos'].length})',
                                                    ),
                                                  ),
                                                if (bookingDetails['to_dos'].isNotEmpty)
                                                  ToDos(toDos: bookingDetails['to_dos']),
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                  width: width,
                                                  child: Text(
                                                    'Duration: ${bookingDetails['start_date'].toDate().day.toString()}/${bookingDetails['start_date'].toDate().month.toString()}/${bookingDetails['start_date'].toDate().year.toString()} '
                                                        '- ${bookingDetails['end_date'].toDate().day.toString()}/${bookingDetails['end_date'].toDate().month.toString()}/${bookingDetails['end_date'].toDate().year.toString()}',
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                                                  width: width,
                                                  child: Text(
                                                    'Budget: PHP ${bookingDetails['budget']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (widget.status != 'completed')
                                            Container(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    if (bookingDetails['status'] == 'request')
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return WarningDialog(
                                                                    title: 'Cancel booking?',
                                                                    message: 'Are you sure you want to cancel this booking request?',
                                                                    confirmButtonText: 'Confirm',
                                                                    confirmAction: () {
                                                                      _bookingServices.removeBook(widget.bookId);
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                    }
                                                                );
                                                              }
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(10),
                                                          width: 175,
                                                          decoration: BoxDecoration(
                                                            color: const Color.fromARGB(255, 70, 199, 177),
                                                            borderRadius: BorderRadius.circular(50),
                                                          ),
                                                          child: const Center(
                                                            child: Text('Cancel Request',
                                                                style: TextStyle(
                                                                    color: Colors.white,
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
                if (widget.bookData['status'] == 'request' || widget.bookData['status'] == 'completed') {
                  showRequestReceipt(widget.bookData);
                }
                if (widget.bookData['status'] == 'ongoing') {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return BookingDetails(
                            bookDetails: widget.bookData,
                            asFreelancer: false,
                            bookId: widget.bookId,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 350),
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
              },
              leading: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/Avatar1.png'),
              ),
              title: Text('${freelancerData['first_name']} ${freelancerData['last_name']}'),
              subtitle: Text(freelancerData['email']),
              trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.bookData['status'] == 'request')
                              const Text("Date"),
                            if (widget.bookData['status'] == 'ongoing')
                              const Text("Deadline"),
                            if (widget.bookData['status'] == 'completed')
                              const Text('Completed'),
                            if (widget.bookData['status'] == 'request')
                              Text('${widget.bookData['booking_date'].toDate().day.toString()}'
                                  '/${widget.bookData['booking_date'].toDate().month.toString()}'
                                  '/${widget.bookData['booking_date'].toDate().year.toString()}'),
                            if (widget.bookData['status'] == 'ongoing')
                              Text('${widget.bookData['end_date'].toDate().day.toString()}'
                                  '/${widget.bookData['end_date'].toDate().month.toString()}'
                                  '/${widget.bookData['end_date'].toDate().year.toString()}'),
                            if (widget.bookData['status'] == 'completed')
                              Text('${widget.bookData['completed_date'].toDate().day.toString()}'
                                  '/${widget.bookData['completed_date'].toDate().month.toString()}'
                                  '/${widget.bookData['completed_date'].toDate().year.toString()}')
                          ],
                        ),
                      ),
                      Icon(Icons.outbound_outlined, color: Colors.blue)
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