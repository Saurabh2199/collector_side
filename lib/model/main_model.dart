class MainModel {
  MainModel({
    this.wardId,
    this.wardName,
    this.latitude,
    this.longitude,
    this.startTime,
    this.endTime,
    this.vehicleId,
    this.collectionId,
  });

  String wardId;
  String wardName;
  List latitude;
  List longitude;
  DateTime startTime;
  DateTime endTime;
  String vehicleId;
  String collectionId;

  factory MainModel.fromJson(Map<String, dynamic> json) => MainModel(
        wardId: json["ward_id"],
        wardName: json["ward_name"],
        latitude: json["latitude"] == null
            ? null
            : json["latitude"].toString().split(","),
        longitude: json["longitude"] == null
            ? null
            : json["longitude"].toString().split(","),
        startTime: json["start_time"] == null
            ? null
            : DateTime.parse(json["start_time"]),
        endTime:
            json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
        collectionId: json["collection_id"],
        vehicleId: json['vehicle_id'],
      );
}
