import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart' ;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'City.dart';
import 'WeatherDao.dart';

class WeatherMap extends StatefulWidget {
  final double lat;
  final double lon;
  final double zoom;

  final MapState abs = MapState();

  WeatherMap(
      {Key? key, required this.lat, required this.lon, required this.zoom})
      : super(key: key);

  @override
  State<WeatherMap> createState() => abs;

  refresh() {
    abs.refresh();
  }
}

class MapState extends State<WeatherMap> with AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchOnMapController = TextEditingController();

  final _weatherDao = WeatherDao();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  List<City> _locations = [];

  @override
  void initState() {
    super.initState();
    initCities();
  }

  void refresh() {
    setState(() {});
  }

  Future<void> initCities() async {
    _weatherDao.getAllFire().then((DataSnapshot snapshot) => setState(() {
      var cityObjsJson = (snapshot.value) as List;
      List<City> cityObjs = cityObjsJson.map((cityJson) => City.fromJson(cityJson)).toList();
      _locations = cityObjs;
      initMapMarkers(cityObjs);
    }));
  }

  void initMapMarkers(List<City> locations) {
    for (int i = 0; i < locations.length; i++) {
      Marker marker = createMarker(locations.elementAt(i));
      _markers[marker.markerId] = marker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMap(),
    );
  }

  Widget _buildMap() {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownSearch<String>(
            mode: Mode.BOTTOM_SHEET,
            showSearchBox: true,
            showSelectedItem: true,
            items: _locations.map((e) => e.name).toList(),
            label: "City search",
            onChanged: (textValue) {
              String value = textValue ?? "";
              if (value.length >= 3) {
                searchByNamePartMap(value);
              } else {
                initCities();
              }
            } ,
          ),
         /* TextField(
              onChanged: (value) {
                if (value.length >= 3) {
                  searchByNamePartMap(value);
                } else {
                  initCities();
                }
              },
              controller: _searchOnMapController,
              decoration: const InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))))*/),
      Expanded(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            zoom: widget.zoom,
          ),
          markers: Set<Marker>.of(_markers.values),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(
                controller); //Unhandled Exception: Bad state: Future already completed
          },
        ),
      ),
    ]);
  }

  void searchByNamePartMap(String value) {

    _weatherDao.getAllFire().then((snapshot) => setState(() {
      var cityObjsJson = (snapshot.value) as List;
      List<City> cityObjs = cityObjsJson.map((cityJson) => City.fromJson(cityJson)).toList();
         _markers.clear();
          for (int i = 0; i < cityObjs.length; i++) {
            if (cityObjs
                .elementAt(i)
                .name
                .toLowerCase()
                .contains(value.toLowerCase())) {
              Marker marker = createMarker(cityObjs.elementAt(i));
              _markers[marker.markerId] = marker;
              _goToThePosition(cityObjs.elementAt(i).latitude, cityObjs.elementAt(i).longitude);
            }
          }
        }));
  }

  Marker createMarker(City city) {
    return Marker(
        markerId: MarkerId(city.name),
        position: LatLng(city.latitude, city.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
            title: city.name + "  " + city.weather.toString() + "℃",
            onTap: () {},
            snippet:
                city.latitude.toString() + ', ' + city.longitude.toString()));
  }

  Future<void> _goToThePosition(double lat, double lon) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lon),
      zoom: 10,
    )));
  }

  @override
  bool get wantKeepAlive => true;
}
