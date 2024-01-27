class DataModel {
  DataModel({
      this.hello, 
      this.data,});

  DataModel.fromJson(dynamic json) {
    hello = json['hello'];
    data = json['data'];
  }
  String? hello;
  String ?data;

 /* Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hello'] = hello;
    map['data'] = data;
    return map;
  }*/

}