import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../services/feedback_services.dart';
class ReviewsPage extends StatefulWidget{
  final String freelancerID;
  const ReviewsPage ({super.key,required this.freelancerID});

  @override
  State<ReviewsPage> createState() => _ReviewsPage();

}

class _ReviewsPage extends State<ReviewsPage>{
  final FeedbackService _feedbackService = FeedbackService();
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;
  
  double veryBadValue = 0;
  double badValue = 0;
  double goodValue = 0;
  double satisfiedValue = 0;
  double excellentValues = 0;

  

  @override
  void initState() {
    
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  double calculateAverage(List<QueryDocumentSnapshot> feedbacks){
    double average = 0;
    if(feedbacks.isNotEmpty){
      for(int index = 0;index < feedbacks.length; index++){
        Map<String,dynamic> data = feedbacks[index].data() as Map<String,dynamic>;
        average = average + data['rating_value'];
        if(index == feedbacks.length - 1){
          return average/feedbacks.length;
        }
      }
    }
    return 0.0;
  }
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:StreamBuilder(
        stream: _feedbackService.getFeedbackStream(widget.freelancerID),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          List<QueryDocumentSnapshot<Map<String,dynamic>>> feedbacks = snapshot.data!.docs as List<QueryDocumentSnapshot<Map<String,dynamic>>>;
          if(feedbacks.isEmpty){
            return const Center(child: Text("No feedbacks yet"),);
          }
          data = [
            _ChartData('Very Bad', feedbacks.where((element) => element.data()['rating_value'] == 1 || element.data()['rating_value'] == 1.5).length * 1.0),
            _ChartData('Bad',feedbacks.where((element) => element.data()['rating_value'] == 2 || element.data()['rating_value'] == 2.5).length * 1.0),
            _ChartData('Satisfied', feedbacks.where((element) => element.data()['rating_value'] == 3 || element.data()['rating_value'] == 3.5).length * 1.0),
            _ChartData('Very Satisfied',feedbacks.where((element) => element.data()['rating_value'] == 4 || element.data()['rating_value'] == 4.5).length * 1.0),
            _ChartData('Excellent',feedbacks.where((element) => element.data()['rating_value'] == 5).length * 1.0),
          ];
          return SingleChildScrollView(
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
                                  child:  Center(
                                    child: Column(
                                      children: [
                                        RatingBar.builder
                                          (initialRating: calculateAverage(snapshot.data!.docs),
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 40,
                                          itemBuilder: (context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            // Not called as it is a readOnly rating bar
                                          },
                                          ignoreGestures: true,
                                        ),
                                        Text((calculateAverage(snapshot.data!.docs)).toStringAsFixed(2)),
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
                                  height: 200,
                                  child: Center(
                                    child: SfCartesianChart(
                                        primaryXAxis: const CategoryAxis(
                                        ),
                                        primaryYAxis: const NumericAxis(
                                            minimum: 0,
                                            interval: 10,
                                            axisLine: AxisLine(width: 0),
                                            majorTickLines: MajorTickLines(size: 0),
                                        ),
                                        tooltipBehavior: _tooltip,
                                        series: <CartesianSeries<_ChartData, String>>[
                                          BarSeries<_ChartData, String>(
                                              dataSource: data,
                                              xValueMapper: (_ChartData data, _) => data.x,
                                              yValueMapper: (_ChartData data, _) => data.y,
                                              pointColorMapper:(_ChartData data, _){
                                                if(data.y == feedbacks.where((element) => element.data()['rating_value'] == 5).length * 1.0){
                                                  return Colors.green;
                                                }else if(data.y == feedbacks.where((element) => element.data()['rating_value'] == 4 || element.data()['rating_value'] == 4.5).length * 1.0){
                                                  return Colors.lightGreenAccent;
                                                }else if(data.y == feedbacks.where((element) => element.data()['rating_value'] == 3 || element.data()['rating_value'] == 3.5).length * 1.0){
                                                  return Colors.amberAccent;
                                                }else if(data.y == feedbacks.where((element) => element.data()['rating_value'] == 2 || element.data()['rating_value'] == 2.5).length * 1.0){
                                                  return Colors.deepOrange;
                                                }else if(data.y == feedbacks.where((element) => element.data()['rating_value'] == 1 || element.data()['rating_value'] == 1.5).length * 1.0){
                                                  return Colors.red;
                                                }else{
                                                  return Colors.grey;
                                                }
                                              },
                                              name: 'Ratings',
                                          )
                                        ]),
                                  ),
                                )
                            ),
                            Flexible(
                              fit: FlexFit.tight,
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
                                      itemCount: feedbacks.length,
                                      itemBuilder:(context, index){
                                        return ListTile(
                                          leading: const CircleAvatar(
                                            radius: 20,
                                            backgroundImage: AssetImage('images/Avatar1.png'),
                                          ),
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${feedbacks[index].data()['client_first_name']} ${feedbacks[index].data()['client_last_name']}'),
                                              RatingBar.builder(
                                                initialRating: feedbacks[index].data()['rating_value'],
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 15,
                                                itemBuilder: (context, _) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  // Not called as it is a readOnly rating bar
                                                },
                                                ignoreGestures: true,
                                              ),
                                            ],
                                          ) ,
                                          subtitle: Text('${feedbacks[index].data()['feedback_message']}'),
                                          trailing: Text('${feedbacks[index].data()['timestamp'].toDate().year.toString()}/${feedbacks[index].data()['timestamp'].toDate().month.toString()}/${feedbacks[index].data()['timestamp'].toDate().day.toString()}'),
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
          );
        }
      ) ,
    );
  }
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
