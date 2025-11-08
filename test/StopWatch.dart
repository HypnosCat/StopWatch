import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stop Watch!!',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String timerString = "00:00.00";
  bool isTimerActive = false;
  bool nextState = false;
  bool nextStateButtns = false;

  late Stream<int> tickStream;
  late Stream<int> tenthofsecondStream;
  late StreamSubscription<int> secondStreamSubscription;

  void startTick() {
    tickStream = Stream.periodic(Duration(milliseconds: 10), (x) => x);

    tenthofsecondStream = tickStream.map((tick) => tick);

    secondStreamSubscription = tenthofsecondStream.listen((tick) {
      if (!isPause) {
        //print('Second: $tick');
        tenthofsecond = tick % 101;
        updateTimerUI(tenthofsecond);
      }
    });
  }

  int minutes = 0;
  int seconds = 0;
  int tenthofsecond = 0;

  void updateTimerUI(int tenthofsecond) {
    setState(() {
      String tempTS = "00";
      String tempS = "00";
      String tempM = "00";

      
      if (tenthofsecond == 100) {
        seconds++;
        tenthofsecond = 0; 
      }

      if (tenthofsecond < 10) {
        tempTS = "0" + tenthofsecond.toString();
      } else {
        tempTS = tenthofsecond.toString();
      }

      if (seconds == 60) {
        minutes++;
        seconds = 0;
      }
     
      if (seconds < 10) {
        tempS = "0" + seconds.toString();
      } else {
        tempS = seconds.toString();
      }

      if (minutes == 60) {
        minutes = 0;
      }

      if (minutes < 10) {
        tempM = "0" + minutes.toString();
      } else {
        tempM = minutes.toString();
      }
      // Оновлюємо рядок таймера
      timerString = tempM + ":" + tempS + "." + tempTS;
    });
  }

  void stopTimer() {
    secondStreamSubscription.cancel();
    minutes = 0;
    seconds = 0;
    tenthofsecond = 0;
  }

  bool isPause = false;
  void pause() {
    setState(() {
      if (isTimerActive) {
        isPause = !isPause;
        if (isPause) {
          secondStreamSubscription.pause();
        } else {
          secondStreamSubscription.resume();
        }
      }
    });
  }

  List<Widget> textWidgets = [];
  List<String> listtime = [];
  void addTime(String time) {
    setState(() {
     
      int index = textWidgets.length + 1;
      String formattedIndex = index < 10 ? "0$index" : index.toString();

      textWidgets.insert(
          0,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                formattedIndex,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "+" + bestTime(time),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )); 
          listtime.add(time);
    });
  }

  String bestTime(String time) {
    if (listtime.isEmpty) {
      return time;
    }
    print(time);
    List<String> newParts = time.split(':');
    int newMinutes = int.parse(newParts[0]);
    List<String> secParts = newParts[1].split('.');
    int newSeconds = int.parse(secParts[0]);
    int newTenths = int.parse(secParts[1]);

    String lastTime = listtime.last;

    print(lastTime);
    List<String> oldParts = lastTime.split(':');
    int oldMinutes = int.parse(oldParts[0]);
    List<String> oldSecParts = oldParts[1].split('.');
    int oldSeconds = int.parse(oldSecParts[0]);
    int oldTenths = int.parse(oldSecParts[1]);

    int newTotal = (newMinutes * 60 * 100) + (newSeconds * 100) + newTenths;
    int oldTotal = (oldMinutes * 60 * 100) + (oldSeconds * 100) + oldTenths;

    int diff = newTotal - oldTotal;

    int diffMinutes = diff ~/ 6000;
    int diffSeconds = (diff % 6000) ~/ 100;
    int diffTenths = diff % 100;

    String tempM = diffMinutes < 10 ? "0$diffMinutes" : diffMinutes.toString();
    String tempS = diffSeconds < 10 ? "0$diffSeconds" : diffSeconds.toString();
    String tempTS = diffTenths < 10 ? "0$diffTenths" : diffTenths.toString();
    print("| $diffMinutes : $diffSeconds . $diffTenths |");

    return "$tempM:$tempS.$tempTS";
  }

  Widget body() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: textWidgets.isEmpty
                ? EdgeInsets.symmetric(horizontal: 100, vertical: 100)
                : EdgeInsets.symmetric(horizontal: 60, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              shape: textWidgets.isEmpty ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  textWidgets.isEmpty ? null : BorderRadius.circular(20),
            ),
            child: Text(
              timerString,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          if (textWidgets.isNotEmpty) slider()
        ],
      ),
    );
  }

  Widget slider() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: textWidgets,
        ),
      ),
    );
  }

  Widget buttonAction() {
    if (!nextState) {
      return TextButton(
        style: TextButton.styleFrom(
          side: BorderSide(color: Colors.blue, width: 2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        onPressed: () => setState(() {
          startTick();
          nextState = true;
          isTimerActive = true;
          print("next $nextState");
        }),
        child: Text(
          "start",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      if (nextStateButtns) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () => setState(() {
                stopTimer();
                textWidgets.clear();
                isTimerActive = false;
                isPause = false;
                nextState = false;
                nextStateButtns = false;
                timerString = "00:00.00";
                print("next $nextState");
              }),
              child: Text(
                "stop",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 30,
            ),
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () => setState(() {
                pause();
                nextStateButtns = false;
              }),
              child: Text(
                "continue",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              onPressed: () {
                addTime(timerString);
              },
              icon: Icon(
                Icons.abc,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(
              width: 30,
            ),
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () => setState(() {
                pause();
                nextStateButtns = true;
              }),
              child: Text(
                "pause",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            body(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonAction(),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(255, 56, 56, 56),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
