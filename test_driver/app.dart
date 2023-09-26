import 'package:flutter_driver/driver_extension.dart';
import 'package:new_test/main.dart' as app;

void main() {
  // 启用扩展
  enableFlutterDriverExtension();

  // 通过 main()启动APP进行集成测试或者通过 runApp 启动组件测试
  app.main();
}
