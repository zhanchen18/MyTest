// Imports the Flutter Driver API

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

late FlutterDriver driver;
void main() {
  group('Flutter App', () {
    // First, define the Finders. We can use these to locate Widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect(dartVmServiceUrl: "localhost:8888");
      // Wait for the first frame to be rasterized during the app launch.
      await driver.waitUntilFirstFrameRasterized();
      driver.setSemantics(true);//设置这个之后，才能通过find.bySemanticsLabel查找
    });


    test("run", () async{
      Map result = {};

      // Verify that our counter starts at 0.
      // expect(find.text('0'), findsOneWidget);
      // expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await driver.tap(find.byValueKey("+"));

      // Verify that our counter has incremented.
      // expect(find.text('0'), findsNothing);
      // expect(find.text('1'), findsOneWidget);

    }, timeout: Timeout.none);

  }, timeout: Timeout.none);
}

