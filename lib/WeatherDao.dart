import 'package:firebase_database/firebase_database.dart';

class WeatherDao {

  Future<DataSnapshot> getAllFire() async {
    final DatabaseReference _cityRef =
        FirebaseDatabase.instance.reference().child("CityInfo");
    return _cityRef.get();
  }
}
