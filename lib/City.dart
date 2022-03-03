class City{
  final String name;
  final int weather;
  final double latitude;
  final double longitude;
  final String imgPath;

  City(this.name, this.weather, this.latitude, this.longitude, this.imgPath);

  City.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        weather = int.parse(json['weather']),
        latitude = double.parse(json['latitude']),
        longitude = double.parse(json['longitude']),
        imgPath = json['imgPath'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'weather': weather,
    'latitude': latitude,
    'longitude': longitude,
    'imgPath': imgPath
  };
}