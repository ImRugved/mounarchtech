import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Screen"),
      ),
      body: GetBuilder(
          init: HomeController(),
          id: 'todo',
          builder: (ctrl) {
            return ctrl.loading.value
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: ctrl.todoApi.length,
                    itemBuilder: (context, index) {
                      final todo = ctrl.todoApi[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: (_) {},
                          activeColor: Colors.green,
                        ),
                        title: Text('${todo.id}. ${todo.title}'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        tileColor: todo.completed!
                            ? Colors.green.withOpacity(0.2)
                            : null,
                      );
                    },
                  );
          }),
    );
  }
}
