import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:lab_1/City.dart';
import 'package:lab_1/Map.dart';
import 'package:lab_1/WeatherDao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AnimatedSplashScreen(
          splash: (SizedBox(
            child: Column(
              children: [
                Image.asset("assets/img/sun.png"),
                const Text(
                  "Daria Zakhvey production",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "2022",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              ],
            ),
            width: 200,
            height: 400,
          )),
          splashIconSize: 400,
          nextScreen: const MyHomePage(),
          splashTransition: SplashTransition.sizeTransition,
          centered: true,
          backgroundColor: Colors.lightGreen,
        ));
    //return const MyHomePage(title: 'World Weather');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _weatherDao = WeatherDao();

  var _locations = <City>[];

  double _currentTextSize = 20;
  Color _currentTextColor = Colors.black;
  var _currentTextStyle = const TextStyle(fontSize: 20, color: Colors.black);

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  WeatherMap mainMap = WeatherMap(
    lat: 57,
    lon: 27,
    zoom: 3,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    initCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.location_city_outlined)),
            Tab(icon: Icon(Icons.map_outlined)),
            Tab(icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: _buildLocations(),
          ),
          Center(
            child: mainMap,
          ),
          Center(
            child: _buildSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocations() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                onChanged: (value) {
                  if (value.length >= 3) {
                    searchByNamePart(value);
                  } else {
                    initCity();
                  }
                },
                controller: _searchController,
                decoration: const InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(25.0)))))),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _locations.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return _buildRow(_locations[index]);
            },
          ),
        )
      ],
    );
  }

  Widget _buildRow(City city) {
    return ListTile(
      leading: CircleAvatar(
          backgroundImage: AssetImage("assets/img/" + city.imgPath)),
      trailing: Text(city.weather.toString() + "℃",
          style: TextStyle(
              fontSize: _currentTextStyle.fontSize, color: Colors.green)),
      title: Text(city.name, style: _currentTextStyle),
      subtitle: Text(
          city.latitude.toString() + ', ' + city.longitude.toString(),
          style: TextStyle(
              fontSize: _currentTextStyle.fontSize! / 2,
              color: _currentTextColor.withOpacity(0.5))),
      onTap: () => _goToTheCity(city),
    );
  }

  void initCity() {
    _weatherDao.getAllFire().then((DataSnapshot snapshot) => setState(() {
          var cityObjsJson = (snapshot.value) as List;
          List<City> cityObjs =
              cityObjsJson.map((cityJson) => City.fromJson(cityJson)).toList();
          _locations = cityObjs;
        }));
  }

  _buildSettings() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(40),
        child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              "Example Text",
              style: _currentTextStyle,
            )),
      ),
      Slider(
        value: _currentTextSize,
        min: 16,
        max: 40,
        divisions: 24,
        label: _currentTextSize.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentTextSize = value;
            _currentTextStyle =
                TextStyle(fontSize: value, color: _currentTextColor);
          });
        },
      ),
      ColorPicker(
        pickerColor: _currentTextColor,
        onColorChanged: (color) {
          setState(() {
            _currentTextColor = color;
            _currentTextStyle =
                TextStyle(fontSize: _currentTextSize, color: color);
          });
        },
        colorPickerWidth: 300.0,
        pickerAreaHeightPercent: 0.7,
        enableAlpha: true,
        displayThumbColor: true,
        showLabel: true,
        paletteType: PaletteType.hsv,
        pickerAreaBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2.0),
          topRight: Radius.circular(2.0),
        ),
      ),
    ]);
  }

  void searchByNamePart(String value) {
    _weatherDao.getAllFire().then((snapshot) => setState(() {
          var cityObjsJson = (snapshot.value) as List;
          List<City> cityObjs =
              cityObjsJson.map((cityJson) => City.fromJson(cityJson)).toList();
          _locations = [];
          for (int i = 0; i < cityObjs.length; i++) {
            if (cityObjs
                .elementAt(i)
                .name
                .toLowerCase()
                .contains(value.toLowerCase())) {
              _locations.add(cityObjs.elementAt(i));
            }
          }
        }));
  }

  Future<void> _goToTheCity(City location) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WeatherMap(
                lat: location.latitude, lon: location.longitude, zoom: 10)));
  }
}
