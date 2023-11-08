import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moblie_project/service/todo_service.dart';


class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        isEdit? 'Edit Todo' : 'Add Todo',
        ),
      ),
      body: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: 'Title'
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
                hintText: 'Description'
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: isEdit? updataData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEdit? 'Update' : 'Submit',
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updataData() async {
    // Get the data from form
    final todo = widget.todo;
    if(todo == null){
      print('You can not call updated without todo data');
      return ;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // Submit updated data to the server
    final isSuccess = await TodoService.updateTodo(id, body);

    // show success or fail message based on status
    if(isSuccess){
      showSuccessMessage('Updation Success');
    }
    else {
      showErrorMessage('Updation Failed');
    }
  }

  //form handling
  Future<void> submitData() async {
    // Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // Submit data to the server
    final url = 'https:api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
        uri,
        body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    // show success or fail message based on status
    if(response.statusCode == 201){
      titleController.text = '';
      descriptionController.text = '';
      //print('Creation Success');
      showSuccessMessage('Creation Success');
    }
    else {
      //print('Creation Failed');
      showErrorMessage('Creation Failed');
    }
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
