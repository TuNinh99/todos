import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos/models/todos.dart';

class FirestoreController {
  //Write data to Firestore
  static Future addTodo(Todo todo) async {
    final docTodo = FirebaseFirestore.instance.collection('todos').doc();
    todo.id = docTodo.id;
    final json = todo.toJson();
    await docTodo.set(json);
  }

//Read data from Firestore
  static Stream<List<Todo>> readTodos() => FirebaseFirestore.instance
      .collection('todos')
      .snapshots()
      .map((event) => event.docs.map((e) => Todo.fromJson(e.data())).toList());

  //Delete data using id
  static Future deleteTodo(String id) async {
    final docTodo = FirebaseFirestore.instance.collection('todos').doc(id);
    docTodo.delete();
  }

  //update data using id
  static Future updateTodoContent(Todo todo) async {
    final docTodo = FirebaseFirestore.instance.collection('todos').doc(todo.id);
    docTodo.update({
      'title': todo.title,
      'dateTime': todo.dateTime,
    });
  }

  static Future updateTodoStatus(String id, bool isFinished) async {
    final docTodo = FirebaseFirestore.instance.collection('todos').doc(id);
    docTodo.update({'isFinished': isFinished});
  }
}
