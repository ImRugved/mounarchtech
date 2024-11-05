// To parse this JSON data, do
//
//     final todoApiModel = todoApiModelFromJson(jsonString);

import 'dart:convert';

List<TodoApiModel> todoApiModelFromJson(String str) => List<TodoApiModel>.from(
    json.decode(str).map((x) => TodoApiModel.fromJson(x)));

String todoApiModelToJson(List<TodoApiModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TodoApiModel {
  int? userId;
  int? id;
  String? title;
  bool? completed;

  TodoApiModel({
    this.userId,
    this.id,
    this.title,
    this.completed,
  });

  factory TodoApiModel.fromJson(Map<String, dynamic> json) => TodoApiModel(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
        completed: json["completed"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
        "completed": completed,
      };
}
