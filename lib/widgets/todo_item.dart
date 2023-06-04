import 'package:flutter/material.dart';
import 'package:todos/controller/date_time_manager.dart';
import 'package:todos/controller/firestore_controller.dart';
import 'package:todos/models/todos.dart';

class TodoItem extends StatefulWidget {
  const TodoItem({
    super.key,
    required this.storage,
    required this.todo,
    required this.onDeleteTodo,
  });

  final Todo todo;
  final List<Todo> storage;
  final dynamic onDeleteTodo;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    Todo todo = widget.todo;
    return Card(
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isFinished
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(todo.dateTime),
        leading: Checkbox(
          value: todo.isFinished,
          onChanged: (value) {
            setState(() {
              todo.isFinished = value!;
              FirestoreController.updateTodoStatus(todo.id, value);
            });
          },
        ),
        trailing: FittedBox(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _ShowEditBox(context, todo);
                },
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () {
                  widget.onDeleteTodo(todo.id);
                },
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> _ShowEditBox(BuildContext context, Todo todo) {
    final TextEditingController titleControllder =
        TextEditingController(text: todo.title);

    final TextEditingController dateTimeController =
        TextEditingController(text: todo.dateTime);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit todo'),
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              TextField(
                controller: titleControllder,
              ),
              TextField(
                controller: dateTimeController,
                onTap: () async {
                  DateTime todoDateTime =
                      DateTimeManager.formatToDateTime(todo.dateTime);

                  final date = await DateTimeManager.pickDate(
                    context,
                    todoDateTime,
                  );
                  if (date == null) return; //pressed cancel button

                  dateTimeController.text =
                      DateTimeManager.formatToString(date);
                },
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Todo newTodo = Todo(
                  id: todo.id,
                  title: todo.title != titleControllder.text
                      ? titleControllder.text
                      : todo.title,
                  dateTime: todo.title != dateTimeController.text
                      ? dateTimeController.text
                      : todo.title,
                  isFinished: todo.isFinished);
              setState(() {
                todo.title = titleControllder.text;
                todo.dateTime = dateTimeController.text;
              });
              FirestoreController.updateTodoContent(newTodo);
              Navigator.pop(context);
            },
            color: Colors.blue,
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: const Color.fromARGB(255, 201, 199, 199),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names

