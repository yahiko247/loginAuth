import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/booking/clientbook.dart';
import 'package:practice_login/components/booking/freelancerbook.dart';
import 'package:practice_login/services/booking/booking_services.dart';

class FavoritePage extends StatefulWidget {
  final int? initPage;
  const FavoritePage({super.key, this.initPage});

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
    _tabController.animateTo(widget.initPage ?? 0);
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
          centerTitle: true,
          title: Text('Bookings'),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            TabBar.secondary(
                controller: _tabController,
                tabs: <Widget>[
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Requests'),
                  Tab(text: 'Completed'),
                ]
            ),
            Expanded(
                child: StreamBuilder(
                    stream: _bookingServices.getBookingAsClient(),
                    builder: (context, bookingsAsClientSnapshot) {
                      if (bookingsAsClientSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (bookingsAsClientSnapshot.hasError) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return StreamBuilder(
                          stream: _bookingServices.getBookingsAsFreelancer(),
                          builder: (context, bookingAsFreelancerSnapshot) {
                            if(bookingAsFreelancerSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (bookingAsFreelancerSnapshot.hasError) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (bookingAsFreelancerSnapshot.hasData) {
                              List<dynamic> bookingsData = bookingAsFreelancerSnapshot.data!.docs + bookingsAsClientSnapshot.data!.docs;
                              bookingsData.sort((a, b) => (b.data()['booking_date'].compareTo(a.data()['booking_date'])));
                              return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    /// Ongoing
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          itemCount: bookingsData.length,
                                          itemBuilder: (context, index) {
                                            dynamic doc = bookingsData[index];
                                            if (doc.data()['status'] == 'ongoing') {
                                              if (doc.data()['freelancer_user_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return FreelancerBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                              if (doc.data()['client_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return ClientBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                            }
                                            return Container();
                                          }
                                      ),
                                    ),
                                    /// Requests
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          itemCount: bookingsData.length,
                                          itemBuilder: (context, index) {
                                            dynamic doc = bookingsData[index];
                                            if (doc.data()['status'] == 'request') {
                                              if (doc.data()['freelancer_user_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return FreelancerBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                              if (doc.data()['client_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return ClientBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                            }
                                            return Container();
                                          }
                                      ),
                                    ),
                                    /// Completed
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          itemCount: bookingsData.length,
                                          itemBuilder: (context, index) {
                                            dynamic doc = bookingsData[index];
                                            if (doc.data()['status'] == 'completed') {
                                              if (doc.data()['freelancer_user_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return FreelancerBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                              if (doc.data()['client_id'] == FirebaseAuth.instance.currentUser!.uid) {
                                                return ClientBook(bookData: doc.data(), bookId: doc.id, status: doc.data()['status']);
                                              }
                                            }
                                            return Container();
                                          }
                                      ),
                                    ),
                                  ]
                              );
                            } else{
                              return Container();
                            }
                          }
                      );
                    }
                )
            )
          ],
        )
    );
  }
}