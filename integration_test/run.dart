import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:new_test/main.dart' as app;


late WidgetTester globalTester;
late IntegrationTestWidgetsFlutterBinding binding;
void main() async {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.testTextInput.register();
  //bool r = binding.registerTestTextInput;
  testWidgets('run test', (WidgetTester tester) async {
    globalTester = tester;
    app.MyApp my = const app.MyApp();
    await tester.pumpWidget(my); // Create main app
    await tester.pumpAndSettle(); // Finish animations and scheduled microtasks
    await Future.delayed(const Duration(seconds: 1));
    //设置可视范围外点击事件的警告为致命异常
    WidgetController.hitTestWarningShouldBeFatal = true;

    await binding.traceAction(
          () async {
              //TestApi.flutterBinding = binding;
              RunTests rt = RunTests(globalTester);
              await rt.run();
          },reportKey: 'studio_blood_integration_test'
    );
  });
}


class RunTests{

  /*执行步骤*/
  Map<String, dynamic> steps = {};

  bool hasLogin = false;

  WidgetTester driver;
  RunTests(this.driver);

  Future<void> run()async{

    Finder conut0 = byText("0");
    expect(conut0, findsOneWidget);

    Finder add = byKey("+");
    if(await pumpUntilFound(add)){
      for(int i = 0; i < 10; i++){
        await tapFinder(add);
      }
    }

    Finder conut10 = byText("10");
    expect(conut10, findsOneWidget);
    if (kDebugMode) {
      print("测试完成");
    }

    sleep(const Duration(seconds:30));
  }

  Future<bool> tapFinder(Finder finder, {int seconds = 2}) async {
    if (await isPresent(finder)) {
      return await tapEvent(finder);
    }
    return false;
  }


  /*点击事件*/
  Future<bool> tapEvent(Finder finder) async {
    try {
      await tap(finder);
      await pump();
      await pumpAndSettle(
        const Duration(milliseconds: 100),
        const Duration(minutes: 1),
      );
      return true;
    } catch (e) {
      //滑动一下
      if(await isPresentByScroll(finder)){
        return tapEvent(finder);
      }else{
        return false;
      }
    }

  }


  /*通过滑动 判断元素是否存在，如果到底部了，就直接返回*/
  Future<bool> isPresentByScroll(Finder finder,
      {bool toStart = false, int maxWhile = 10, String containerKey = "ListViewContainer", double dy = 100000}) async {
    try {
      // 判断是否在首页 先滑动一次
      // 首页能够找到活动，但不在可视范围内，需要滑动到可视范围内
      final plan = byKey('PlanTask');
      if (await isPresent(plan)) {
        await globalTester.scrollUntilVisible(finder, 40);
        return true;
      }

      if (toStart) {
        //从头开始滑动
        int scrollNum = 1;
        //找不到当前的元素及最底部的元素，最多滑10次
        for (; scrollNum <= maxWhile; scrollNum++) {
          if (!await isPresent(finder)) {
            await globalTester.scrollUntilVisible(finder, dy);
            // return await scrollFinderIntoView(finder, dyScroll: 40, containerKey: containerKey);
          }
        }
        return true;
      }

      //已经滑动到可视区
      if (await scrollFinderIntoView(finder, containerKey: containerKey, dyScroll: dy)) {
        return await isPresent(finder);
      } else {

      }
      return false;
    } catch (e) {
      return false;
    }

  }


  /*finder元素 滚动到可视区域*/
  Future<bool> scrollFinderIntoView(Finder finder,
      {double seconds = 0.5, String containerKey = "ListViewContainer", double dyScroll = 100000}) async {
    try {
      await globalTester.ensureVisible(finder);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> tap(finder) async {
    await globalTester.tap(finder);
  }


  Future<void> pumpAndSettle([
    Duration duration = const Duration(milliseconds: 100),
    Duration timeout = const Duration(minutes: 1),
  ]) async {
    await globalTester.pumpAndSettle(duration, EnginePhase.sendSemanticsUpdate, timeout);
  }

  Finder byKey(String strKey) {
    return find.byKey(ValueKey(strKey));
  }

  Finder byText(String text) {
    return find.text(text);
  }

  Future<bool> pumpUntilFound(Finder finder, {int seconds = 15, }) async {
    bool timerDone = false;
    while (timerDone != true && seconds > 0) {
      await globalTester.pumpAndSettle();

      final found = globalTester.any(finder);
      if (found) {
        timerDone = true;
        break;
      }
      sleep(const Duration(seconds: 1));
      seconds--;
    }
    return timerDone;
  }

  /*判断元素是否存在*/
  Future<bool> isPresent(Finder finder, {Duration timeout = const Duration(seconds: 2)}) async {

    bool r = await _isPresent(finder);
    int seconds = timeout.inSeconds;
    int retry = 0;

    while (!r && seconds > retry) {
      //循环等待1秒刷新再判断
      await pump(const Duration(seconds: 1));
      r = await _isPresent(finder);
      retry++;
    }
    return r;
  }

  Future<bool> _isPresent(Finder finder) async {
    try {
      expect(finder, findsOneWidget);
      return true;
    } catch (e) {
      return false;
    }

  }

  Future<void> pump([
    Duration? duration = const Duration(milliseconds: 50),
  ]) async {
    await globalTester.pump(duration, EnginePhase.sendSemanticsUpdate);
  }
}