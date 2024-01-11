import 'package:flutter/material.dart';

class ReviewsPage extends StatefulWidget{
  const ReviewsPage ({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPage();

}

class _ReviewsPage extends State<ReviewsPage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text("Review")
        ),
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: LayoutBuilder(
              builder: (BuildContext context,BoxConstraints constraints) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;

                return SizedBox(
                  width: width,
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                              color: Colors.red,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              height: 200,
                              child: const Center(
                                child: Column(
                                  children: [
                                    Text("4.5 (Placeholder)"),
                                    Text("Star Rating Placeholder"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius:  BorderRadius.circular(10)
                              ),
                              height: 100,
                              child: const Center(
                                child: Column(
                                  children: [
                                    Text("Very Satisfied"),
                                    Text("Satisfied"),
                                    Text("Good"),
                                    Text("Not Bad"),
                                    Text("Very Bad")
                                  ],
                                ),
                              ),
                            )
                        ),
                        Flexible(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(top:10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              height: 600,
                              child:ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 20,
                                  itemBuilder:(context, index){
                                    return const ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage('images/Avatar1.png'),
                                      ),
                                      trailing: Text("Time PH"),
                                    );
                                  })
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ) ,
    );
  }
}