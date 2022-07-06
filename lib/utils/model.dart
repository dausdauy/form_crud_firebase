import 'dart:convert';

class UsersModel {
  final String? fName;
  final String? lName;
  final String? age;
  final String? level;
  final String? dateCreated;
  final String? dateUpdated;

  UsersModel({
    this.fName,
    this.lName,
    this.age,
    this.level,
    this.dateCreated,
    this.dateUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'fName': fName,
      'lName': lName,
      'age': age,
      'level': level,
      'dateCreated': dateCreated,
      'dateUpdated': dateUpdated,
    };
  }

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      fName: map['fName'],
      lName: map['lName'],
      age: map['age'],
      level: map['level'],
      dateCreated: map['dateCreated'],
      dateUpdated: map['dateUpdated'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UsersModel.fromJson(String source) => UsersModel.fromMap(json.decode(source));
}
