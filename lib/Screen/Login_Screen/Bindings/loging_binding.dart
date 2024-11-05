import 'package:get/get.dart';
import 'package:mounarch/Screen/Login_Screen/Controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
