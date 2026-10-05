class ShiftModel {
  ShiftModel({this.id, this.name, this.startTime, this.endTime, this.isFullDay});

  int? id;
  String? name;
  String? startTime;
  String? endTime;
  int? isFullDay;

  ShiftModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    startTime = json["start_time"];
    endTime= json["end_time"];
    isFullDay= json["is_full_day"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["start_time"] = startTime;
    data["end_time"] = endTime;
    data["is_full_day"] = isFullDay;
    return data;
  }
}
