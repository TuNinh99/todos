// ignore_for_file: constant_identifier_names

// import 'dart:convert';
// import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:todos/controller/date_time_manager.dart';
import 'package:todos/controller/firestore_controller.dart';
import 'package:todos/models/todos.dart';
import 'package:todos/widgets/todo_item.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> registerNotification() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
    }
  });

  debugPrint('User granted permission: ${settings.authorizationStatus}');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    registerNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        // leadingWidth: 0,
        title: const Text('Todos App'),
        backgroundColor: Colors.deepPurpleAccent[100],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Todo>>(
          stream: FirestoreController.readTodos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No data, please add new todo!'),
                );
              } else {
                var todos = snapshot.data;
                todos!.sort((a, b) {
                  final adt = DateFormat("dd-MM-yyyy").parse(a.dateTime);
                  final bdt = DateFormat("dd-MM-yyyy").parse(b.dateTime);
                  return bdt.compareTo(adt);
                });
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final Todo todo = todos[index];
                    return TodoItem(
                      storage: todos,
                      todo: todo,
                      onDeleteTodo: (id) {
                        setState(
                          () {
                            todos.removeWhere((item) => item.id == id);
                            FirestoreController.deleteTodo(id);
                          },
                        );
                      },
                    );
                  },
                );
              }
            } else {
              return Center(
                child: Text('State: ${snapshot.connectionState}'),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _ShowAddNewTodoBox(context);
        },
        child: const Icon(Icons.add),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     FirebaseMessaging messaging = FirebaseMessaging.instance;

      //     try {
      //       String? token = await messaging.getToken();
      //       debugPrint(token);

      //       final body = {
      //         "to": token,
      //         "notification": {
      //           "title": "Hello From API",
      //           "body": "This is notification set event time",
      //           // "icon": "assets/images/app_icon.png",
      //           "icon":
      //               "https://icons.iconarchive.com/icons/blackvariant/button-ui-requests-5/512/ToDo-List-icon.png",
      //           "sound": "default",
      //           "event_time": "2023-05-17T00:16:30Z"
      //           // "event_time": "1684257240"
      //         }
      //       };

      //       var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      //       var response = await http.post(url,
      //           headers: {
      //             HttpHeaders.contentTypeHeader: 'application/json',
      //             HttpHeaders.authorizationHeader:
      //                 'key=AAAAqhrUhwA:APA91bG55kpPv-cdeTvmBxbP-QS1aFCCw5ewkJIhLlMZB-vTkgrylhoivC7M84UZWqjsgfiGtx-nbHNr-PN3bcoYyC9f_47w0tHT7QerIv9UynPnoob9eS0TvogULKjwb3jlGOYZBUpv'
      //           },
      //           body: jsonEncode(body));

      //       debugPrint('Response status: ${response.statusCode}');
      //       debugPrint('Response body: ${response.body}');
      //     } catch (e) {
      //       debugPrint('Send push notification error: $e');
      //     }

      //     // ignore: use_build_context_synchronously
      //     await _ShowAddNewTodoBox(context);
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> _ShowAddNewTodoBox(BuildContext context) {
    final TextEditingController titleControllder = TextEditingController();

    final TextEditingController dateTimeController = TextEditingController(
      text: DateTimeManager.formatToString(DateTime.now()),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add new todo'),
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              TextField(
                controller: titleControllder,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextField(
                controller: dateTimeController,
                decoration: const InputDecoration(
                  hintText: 'DateTime',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onTap: () async {
                  final date = await DateTimeManager.pickDate(
                    context,
                    DateTime.now(),
                  );
                  if (date == null) return; //pressed 'Cancel'

                  dateTimeController.text =
                      DateTimeManager.formatToString(date);
                },
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () async {
              setState(
                () {
                  FirestoreController.addTodo(
                    Todo(
                      title: titleControllder.text == ''
                          ? 'Empty'
                          : titleControllder.text,
                      dateTime: dateTimeController.text,
                    ),
                  );
                },
              );
              Navigator.pop(context);
            },
            color: Colors.deepPurpleAccent,
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
