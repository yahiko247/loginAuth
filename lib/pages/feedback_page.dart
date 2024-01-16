import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Ratings extends StatefulWidget{
   const Ratings({super.key});

  @override
  State<Ratings> createState() => _Ratings();
}

class _Ratings extends State<Ratings>{



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Service Rating")
        ),
        body:SingleChildScrollView(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = MediaQuery.of(context).size.width;
              double height = MediaQuery.of(context).size.height;

              return SizedBox(
                height: height,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            height: 100,
                            child:  Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text("Services"),
                                ),
                                RatingBarIndicator(
                                  rating: 2.75,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 30.0,
                                  direction: Axis.horizontal,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text("Amazing"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            height: 200,
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Add Photo"),
                                Text("Add Video")
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            color: Colors.grey,
                            height: 500,
                            child: const Center(
                              child: Text("Photo Here"),
                            ),

                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.lightBlueAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              height: 200,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const Text("Communication"),
                                          RatingBarIndicator(
                                            rating: 2.75,
                                            itemBuilder: (context, index) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 30.0,
                                            direction: Axis.horizontal,
                                          ),
                                        ],
                                      ),
                                    ),

                                  const Divider(thickness: 1),
                                  Flexible(
                                    flex: 1,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const Text("Overall Rating"),
                                          RatingBarIndicator(
                                            rating: 2.75,
                                            itemBuilder: (context, index) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 30.0,
                                            direction: Axis.horizontal,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                      ),
                       const Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: SizedBox(
                          height: 100,
                          child: Column(
                              children:[
                                Text("Payment Center/E-Wallet"),
                                Text("Linked Bank Account"),
                              ]
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ) ,
    );
  }

}