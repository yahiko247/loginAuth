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
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.red,
                    height: 200,
                    child: const Column(
                      children: [
                        Text("4.5 (Placeholder)"),
                        Text("Star Rating Placeholder"),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      color: Colors.lightBlueAccent,
                      child: const Column(
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
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 300,
                    color: Colors.pink,
                    child:Text("Comments"),
                    /* ListView.builder(
                      itemCount: 10,
                        itemBuilder:(context, index){
                        return const ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('images/Avatar1.png'),
                          ),
                          trailing: Text("Time PH"),
                        );
                        }),*/
                  ),
                ),
              )
            ],
          ),
        ),
      ) ,
    );
  }
}