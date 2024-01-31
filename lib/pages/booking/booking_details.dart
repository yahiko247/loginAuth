import 'package:flutter/material.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/services/booking/booking_services.dart';

class BookingDetails extends StatefulWidget {
  final Map<String, dynamic> bookDetails;
  final bool asFreelancer;
  final String bookId;
  const BookingDetails({super.key, required this.bookDetails, required this.asFreelancer, required this.bookId});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late Map<String, dynamic> _bookingDetails;
  BookingServices _bookingServices = BookingServices();
  bool isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bookingDetails = widget.bookDetails;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(padding: EdgeInsets.only(left: 10, top: 15), child: Text('Booking Details')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25, top: 15),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.clear)
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1),
            ),
            FutureBuilder(
                future: _bookingServices.getClientAndFreelancerData(_bookingDetails['client_id'], _bookingDetails['freelancer_user_id']),
                builder: (context, clientFreelancerSnapshot) {
                  if (clientFreelancerSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (clientFreelancerSnapshot.hasError) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (clientFreelancerSnapshot.hasData) {
                    Map<String, dynamic> clientFreelancerData = clientFreelancerSnapshot.data!;
                    return Column(
                      children: [
                        if (!widget.asFreelancer)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            width: width,
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                    text: '${clientFreelancerData['freelancer']['first_name']} ${clientFreelancerData['freelancer']['last_name']}',
                                    children: [
                                      TextSpan(
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                        text: '\nFreelancer',
                                      )
                                    ]
                                )
                            ),
                          ),
                        if (widget.asFreelancer)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            width: width,
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                    text: '${clientFreelancerData['client']['first_name']} ${clientFreelancerData['client']['last_name']}',
                                    children: [
                                      TextSpan(
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                        text: '\nClient',
                                      )
                                    ]
                                )
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          width: width,
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
                                  text: widget.asFreelancer ? 'Booked you for: ' : 'You booked for: ',
                                children: [
                                  TextSpan(
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    text: '${_bookingDetails['start_date'].toDate().day.toString()}/${_bookingDetails['start_date'].toDate().month.toString()}/${_bookingDetails['start_date'].toDate().year.toString()} '
                                        '- ${_bookingDetails['end_date'].toDate().day.toString()}/${_bookingDetails['end_date'].toDate().month.toString()}/${_bookingDetails['end_date'].toDate().year.toString()}',
                                  )
                                ]
                              )
                          ),
                        ),
                        if (_bookingDetails['location'].isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            width: width,
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
                                    text: 'Location: ',
                                    children: [
                                      TextSpan(
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        text: '${_bookingDetails['location']}',
                                      )
                                    ]
                                )
                            ),
                          ),
                        if (_bookingDetails['message'].isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            width: width,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(7)),
                                color: Color.fromRGBO(215, 215, 215, 1),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: width,
                                    child: widget.asFreelancer ? Text('Client message', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)) : Text('Your message', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                    padding: EdgeInsets.only(bottom: 10),
                                  ),
                                  Container(
                                    width: width,
                                    child: Text(_bookingDetails['message'], style: TextStyle(fontSize: 16)),
                                  )
                                ],
                              ),
                            )
                          ),
                        if (_bookingDetails['to_dos'].isNotEmpty)
                          Container(
                            padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                            width: width,
                            child: Text('To Dos', style: TextStyle(fontSize: 16)),
                          ),
                        if (_bookingDetails['to_dos'].isNotEmpty)
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              width: width,
                              height: 190,
                              child: ToDoView(toDo: _bookingDetails['to_dos'], bookId: widget.bookId, isClient: !widget.asFreelancer),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          width: width,
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                  text: 'Budget: ',
                                  children: [
                                    TextSpan(
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      text: 'PHP ${_bookingDetails['budget']}',
                                    )
                                  ]
                              )
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 25),
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: widget.asFreelancer ? null : () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WarningDialog(
                                            confirmSideColor: Colors.green,
                                            confirmOverlayColor: const Color.fromARGB(15, 0, 255, 0),
                                            confirmTextColor: Colors.green,
                                            title: 'Complete Booking?',
                                            message: 'Are you sure you want to complete this booking?',
                                            confirmButtonText: 'Confirm',
                                            confirmAction: () {
                                              _bookingServices.completeBook(widget.bookId);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                        );
                                      }
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: 190,
                                  decoration: BoxDecoration(
                                    color: widget.asFreelancer ? Color.fromARGB(100, 70, 199, 177) : const Color.fromARGB(255, 70, 199, 177),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: Text('Complete Booking',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.asFreelancer ? null : () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WarningDialog(
                                            confirmSideColor: Colors.red,
                                            confirmOverlayColor: const Color.fromARGB(15, 255, 0, 0),
                                            confirmTextColor: Colors.red,
                                            title: 'Cancel Booking?',
                                            message: 'Are you sure you want to cancel this booking?',
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
                                  padding: const EdgeInsets.all(9),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: widget.asFreelancer ? const Color.fromARGB(100, 255, 0, 0) : Colors.red, // Choose the border color
                                      width: 1, // Choose the border width
                                    ),
                                  ),
                                  child: Center(
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: widget.asFreelancer ? const Color.fromARGB(100, 255, 0, 0) : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
            )
          ],
        ),
      )
    );
  }

  /*Widget asClient() {
    return Container(

    )
  }*/

}

class ToDoView extends StatefulWidget {
  final bool isClient;
  final List<dynamic> toDo;
  final String bookId;
  const ToDoView({super.key, required this.toDo, required this.bookId, required this.isClient});

  @override
  State<ToDoView> createState() => _ToDoViewState();
}

class _ToDoViewState extends State<ToDoView> {
  final PageController toDoController = PageController();
  int toDoIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [
        PageView(
          scrollDirection: Axis.horizontal,
          controller: toDoController,
          onPageChanged: (index) {
            setState(() {
              toDoIndex = index;
            });
          },
          children: List.generate(widget.toDo.length, (index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                child: ToDoItem(
                  itemIndex: index,
                  bookingId: widget.bookId,
                  toDos: widget.toDo,
                  isClient: widget.isClient,
                ),
              ),
            );
          }),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30),
            child: AnimatedOpacity(
              opacity: toDoIndex == widget.toDo.length - 1 ? 0 : 1,
              duration: Duration(milliseconds: 200),
              child: IconButton(
                  onPressed: () {
                    toDoController.animateToPage(widget.toDo.length - 1, duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
                  },
                  icon: Icon(Icons.arrow_forward, size: 28)
              ),
            )
          ),
        )
      ],
    );
  }
}

class ToDoItem extends StatefulWidget {
  final bool isClient;
  final int itemIndex;
  final String bookingId;
  final List<dynamic> toDos;
  const ToDoItem({super.key, required this.itemIndex, required this.bookingId, required this.toDos, required this.isClient});

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  late int _itemIndex;
  late String _bookId;
  late List<dynamic> _toDo;
  late bool _isChecked;
  BookingServices _bookingServices = BookingServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemIndex = widget.itemIndex;
    _bookId = widget.bookingId;
    _toDo = widget.toDos;
    if (_toDo[_itemIndex].containsKey('cleared')) {
      _isChecked = _toDo[_itemIndex]['cleared'];
    } else {
      _isChecked = false;
    }
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Stack(
        children: [
          Container(
            width: width * (74 / 100),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(7)),
                border: Border.all(color: Colors.grey, width: 1)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * (80 / 100),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_toDo[_itemIndex]['title'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                ),
                Container(
                  width: width * (75 / 100),
                  child: Text(_toDo[_itemIndex]['description'], style: const TextStyle(fontSize: 15),),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.only(right: 10),
              child: Column(
                children: [
                  Transform.scale(
                    scale: 1,
                    child: Checkbox(
                        value: _isChecked,
                        onChanged: !widget.isClient ? null : (bool? value) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return WarningDialog(
                                    title: _isChecked ? 'Unclear Requirement' : 'Clear Requirement?',
                                    message: 'You may undo this change later',
                                    confirmButtonText: _isChecked ? 'Unclear' : 'Clear',
                                    confirmTextColor: _isChecked ? Colors.red : Colors.green,
                                    confirmOverlayColor: _isChecked ? Color.fromRGBO(255, 0, 0, 0.1) : Color.fromRGBO(0, 255, 0, 0.1),
                                    confirmSideColor: _isChecked ? Colors.red : Colors.green,
                                    confirmAction: () {
                                      setState(() {
                                        _isChecked = value!;
                                      });
                                      _bookingServices.clearToDoStatus(_itemIndex, _bookId);
                                      Navigator.pop(context);
                                    }
                                );
                              }
                          );
                        }
                    ),
                  ),
                  /*IconButton(
                      onPressed: !widget.isClient ? null : () {
                      },
                      icon: Icon(Icons.delete_outline_outlined, size: 29)
                  )*/
                ],
              )
            )
          ),
        ],
      ),
    );

    /*CheckboxListTile(
      title: Text(_toDo[_itemIndex]['title'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      subtitle: Text(_toDo[_itemIndex]['description']),
      value: _isChecked,
      onChanged: (bool? value) {

      },
    );*/
  }
}