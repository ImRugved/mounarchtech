import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class SecondScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Operation Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: GetBuilder(
              init: HomeController(),
              id: 'data',
              builder: (controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Form fields
                    TextField(
                      controller:
                          TextEditingController(text: controller.name.value),
                      onChanged: (value) => controller.name.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          TextEditingController(text: controller.email.value),
                      onChanged: (value) => controller.email.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          TextEditingController(text: controller.number.value),
                      onChanged: (value) => controller.number.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          TextEditingController(text: controller.address.value),
                      onChanged: (value) => controller.address.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    controller.selectedImage.value != null
                        ? Image.file(controller.selectedImage.value!)
                        : const Text('No image selected'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              controller.selectImage(ImageSource.camera),
                          child: const Text('Camera'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              controller.selectImage(ImageSource.gallery),
                          child: const Text('Gallery'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.addData(),
                      child: const Text('Add'),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.data.length,
                      itemBuilder: (context, index) {
                        final userData = controller.data[index];
                        return Card(
                          child: ListTile(
                            leading: userData['image'] != null
                                ? Image.memory(base64Decode(userData['image']))
                                : null,
                            title: Text(userData['name']),
                            subtitle: Text(userData['email']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.name.value = userData['name'];
                                    controller.email.value = userData['email'];
                                    controller.number.value =
                                        userData['number'];
                                    controller.address.value =
                                        userData['address'];
                                    controller.image.value = userData['image'];
                                    controller.selectedImage.value =
                                        userData['image'] != null
                                            ? File.fromRawPath(
                                                base64Decode(userData['image']))
                                            : null;
                                    controller.updateData(userData);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      controller.deleteData(userData),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
