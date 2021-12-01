import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const d_light_violet = Color(0xFF812EAD);
const d_dark_violet = Color(0xFF501776);
DateTime now = DateTime.now();

//---------------------------style
TextStyle styleTitle() {
  return TextStyle(
    color: Colors.white.withOpacity(0.55),
  );
}

TextStyle styleData() {
  return const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
}

Future<Weather> fetchWeather() async {
  final response = await http
      .get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?id=3014728&units=metric&appid=3ee1c88773481377978efa37566919aa'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Weather.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load weather');
  }
}
//-------------------------------------parse data json class
class Main {
  Main({
    required this.temp,
    required this.humidity,
  });

  double temp;
  int humidity;

  factory Main.fromJson(Map<String, dynamic> json) => Main(
    temp: json["temp"].toDouble(),
    humidity: json["humidity"],
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "humidity": humidity,
  };
}

class WeatherElement {
  final String icon;

  WeatherElement({
    required this.icon,
  });

  factory WeatherElement.fromJson(Map<String, dynamic> json) => WeatherElement(
    icon: json["icon"],
  );

}


class Wind {
  Wind({
    required this.speed,
  });

  double speed;

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    speed: json["speed"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "speed": speed,
  };
}


class Weather {
  final String city;
  final Main main;
  final List<WeatherElement> weatherE;
  final Wind wind;

  Weather({
    required this.city,
    required this.main,
    required this.weatherE,
    required this.wind,

  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      main: Main.fromJson(json["main"]),
      weatherE: List<WeatherElement>.from(json["weather"].map((x) => WeatherElement.fromJson(x))),
      wind: Wind.fromJson(json["wind"]),
    );
  }
}
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  _MyAppState createState() => _MyAppState();
}
//----------------------------------------------parse data json class

class _MyAppState extends State<MyApp> {
  late Future<Weather> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(futureWeather:futureWeather),
       //
    );
  }

}
class MyHomePage extends StatefulWidget {
  var futureWeather;

  MyHomePage({Key? key, @required this.futureWeather}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    //timeout for refresh app
    Future.delayed(const Duration(milliseconds: 60000), () {
      setState(() {
        updateUi();
      });
    });

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  d_light_violet,
                  d_dark_violet,
                ],
              )
          ),
          child: Center(
            child: FutureBuilder<Weather>(
              future: widget.futureWeather,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ShowWeather(dataJ:snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: updateUi,
        tooltip: 'Increment',
        child: const Icon(Icons.autorenew, size: 40,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  void updateUi() {
    setState(() {
      widget.futureWeather = fetchWeather();
    });
  }
}


class ShowWeather extends StatefulWidget{
  var dataJ;

  ShowWeather({Key? key, @required this.dataJ}) : super(key: key);


  @override
  _ShowWeatherState createState() => _ShowWeatherState();

}


class _ShowWeatherState extends State<ShowWeather> {
  var dayF = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  var monthF = ['','Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:Column(
        children: [
          Container(
            child:Text(
                widget.dataJ.city,
              style: TextStyle(
                fontSize: 46.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height:10),
          Container(
            child:Text(
              dayF[now.weekday].toString()+" "+now.day.toString()+" "+monthF[now.month]+" "+now.year.toString(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            height:200,
            decoration: BoxDecoration(
            image: DecorationImage(
            image: AssetImage(
              'assets/'+ widget.dataJ.weatherE[0].icon.toString() +'.png',
            ),
              fit: BoxFit.fitHeight,),
            ),
          ),
          Container(
            color:Colors.white.withOpacity(0.1),
            padding: EdgeInsets.fromLTRB(30, 25, 30, 25),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width:90,
                  child: Column(
                      children: [
                        Text('Température',
                        style: styleTitle(),),
                        const SizedBox(height:8),
                        Text(widget.dataJ.main.temp.truncate().toString()+"°",
                            style:styleData() ),
                      ]
                  ),
                ),
                Container(
                  width:90,
                  child: Column(
                      children: [
                        Text('Vent',
                          style: styleTitle(),),
                        const SizedBox(height:8),
                        //*3.6 convert m/s to km/h
                        Text((widget.dataJ.wind.speed*3.6).truncate().toString()+' km/h',
                            style:styleData()),
                      ]
                  ),
                ),
                Container(
                  width:90,
                  child: Column(
                      children: [
                        Text('Humidité',
                          style: styleTitle(),),
                        const SizedBox(height:8),
                        Text(widget.dataJ.main.humidity.toString()+'%',
                          style:styleData()),
                      ]
                  ),
                ),
              ]
          ),),
        ],
      )
    );
    //return Text(widget.dataJ.main.humidity.toString());
  }
}