import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class ReviewsPage extends StatefulWidget{
  const ReviewsPage ({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPage();

}

class _ReviewsPage extends State<ReviewsPage>{
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  double averageRatingValue = 4.5;

  double excellentValues = 12;
  double satisfiedValue = 15;
  double goodValue = 30;
  double badValue = 6.4;
  double veryBadValue = 14;

  @override
  void initState() {
    data = [
      _ChartData('Very Bad', veryBadValue),
      _ChartData('Bad', badValue),
      _ChartData('Satisfied', goodValue),
      _ChartData('Very Satisfied',satisfiedValue ),
      _ChartData('Excellent', excellentValues)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
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
                              child:  Center(
                                child: Column(
                                  children: [
                                    RatingBar.builder
                                      (initialRating: averageRatingValue,
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
                                    ),
                                    Text("$averageRatingValue"),
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
                                            if(data.y ==excellentValues){
                                              return Colors.green;
                                            }else if(data.y== satisfiedValue){
                                              return Colors.lightGreen;
                                            }else if(data.y == goodValue){
                                              return Colors.amberAccent;;
                                            }else if(data.y == badValue){
                                              return Colors.deepOrange;
                                            }else if(data.y == veryBadValue){
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
class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
