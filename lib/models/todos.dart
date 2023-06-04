class Todo {
  String id;
  String title;
  String dateTime;
  bool isFinished;

  Todo({
    this.id = '',
    required this.title,
    this.dateTime = 'Nothing',
    this.isFinished = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      isFinished: json['isFinished'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateTime': dateTime,
        'isFinished': isFinished
      };
}
