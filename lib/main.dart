import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Blocca l'orientamento dello schermo solo in modalità portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
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
  // Stringa che mostra il tempo formattato (MM:SS.CS)
  String timerString = "00:00.00";

  // Flag per verificare se il timer è attivo
  bool isTimerActive = false;

  // Flag per gestire lo stato successivo del timer
  bool nextState = false;

  // Flag per gestire la visualizzazione dei pulsanti stop/continue
  bool nextStateButtns = false;

  // Stream per generare tick periodici
  late Stream<int> tickStream;

  // Stream che mappa i tick ai centesimi di secondo
  late Stream<int> tenthofsecondStream;

  // Subscription per ascoltare gli aggiornamenti del timer
  late StreamSubscription<int> secondStreamSubscription;

  // Avvia il timer 
  void startTick() {
    // Crea uno stream che emette un valore ogni 10ms (un tick sia centesimi di secondo)
    tickStream = Stream.periodic(Duration(milliseconds: 10), (x) => x);

    tenthofsecondStream = tickStream.map((tick) => tick);

    // Sottoscrive lo stream e aggiorna l'UI ad ogni tick
    secondStreamSubscription = tenthofsecondStream.listen((tick) {
      if (!isPause) {
        //print('Second: $tick');
        // Calcola i centesimi di secondo
        tenthofsecond = tick % 101;
        updateTimerUI(tenthofsecond);
      }
    });
  }

  // Variabili per tenere traccia del tempo
  int minutes = 0;
  int seconds = 0;
  int tenthofsecond = 0;

  // Aggiorna l'interfaccia utente con il tempo corrente
  void updateTimerUI(int tenthofsecond) {
    setState(() {
      String tempTS = "00"; // Centesimi di secondo temporanei
      String tempS = "00";  // Secondi temporanei
      String tempM = "00";  // Minuti temporanei

      
      // Quando raggiungiamo 100 centesimi, incrementa i secondi
      if (tenthofsecond == 100) {
        seconds++;
        tenthofsecond = 0; 
      }

      // Formatta i centesimi di secondo con zero iniziale se necessario
      if (tenthofsecond < 10) {
        tempTS = "0" + tenthofsecond.toString();
      } else {
        tempTS = tenthofsecond.toString();
      }

      // Quando raggiungiamo 60 secondi, incrementa i minuti
      if (seconds == 60) {
        minutes++;
        seconds = 0;
      }
     
      // Formatta i secondi con zero iniziale se necessario
      if (seconds < 10) {
        tempS = "0" + seconds.toString();
      } else {
        tempS = seconds.toString();
      }
      
      // Reset dei cronometro
      if (minutes == 60) {
        minutes = 0;
        seconds = 0;
        tenthofsecond = 0;
      }
      
      // Formatta i minuti con zero iniziale se necessario
      if (minutes < 10) {
        tempM = "0" + minutes.toString();
      } else {
        tempM = minutes.toString();
      }
      // Aggiorna la stringa del timer nel formato MM:SS.CS
      timerString = tempM + ":" + tempS + "." + tempTS;
    });
  }

  // Ferma il timer e resetta tutti i valori
  void stopTimer() {
    secondStreamSubscription.cancel();
    minutes = 0;
    seconds = 0;
    tenthofsecond = 0;
  }

  // Flag per gestire lo stato di pausa
  bool isPause = false;

  // Mette in pausa o riprende il timer
  void pause() {
    setState(() {
      if (isTimerActive) {
        isPause = !isPause;
        if (isPause) {
          secondStreamSubscription.pause(); // Pausa lo stream
        } else {
          secondStreamSubscription.resume(); // Riprende lo stream
        }
      }
    });
  }

  // Lista dei widget che mostrano i punti registrati
  List<Widget> textWidgets = [];

  // Lista dei tempi registrati come stringhe
  List<String> listtime = [];

  // Aggiunge un nuovo punto alla lista con il tempo corrente
  void addTime(String time) {
    setState(() {
      // Calcola l'indice del nuovo punto
      int index = textWidgets.length + 1;
      String formattedIndex = index < 10 ? "0$index" : index.toString();

      // Inserisce un nuovo widget all'inizio della lista (ordine inverso)
      textWidgets.insert(
          0,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Numero del punto
              Text(
                formattedIndex,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Differenza rispetto al punto precedente
              Text(
                "+" + bestTime(time),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              // Tempo totale
              Text(
                time,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )); 
          listtime.add(time);
    });
  }

  // Calcola la differenza tra il tempo corrente e l'ultimo punto registrato
  String bestTime(String time) {
    // Se è il primo punto, restituisce il tempo stesso
    if (listtime.isEmpty) {
      return time;
    }
    //print(time);
    // Parse del nuovo tempo
    List<String> newParts = time.split(':');
    int newMinutes = int.parse(newParts[0]);
    List<String> secParts = newParts[1].split('.');
    int newSeconds = int.parse(secParts[0]);
    int newTenths = int.parse(secParts[1]);

    // Parse dell'ultimo tempo registrato
    String lastTime = listtime.last;

    print(lastTime);
    List<String> oldParts = lastTime.split(':');
    int oldMinutes = int.parse(oldParts[0]);
    List<String> oldSecParts = oldParts[1].split('.');
    int oldSeconds = int.parse(oldSecParts[0]);
    int oldTenths = int.parse(oldSecParts[1]);

    // Converte tutto in centesimi di secondo per calcolare la differenza
    int newTotal = (newMinutes * 60 * 100) + (newSeconds * 100) + newTenths;
    int oldTotal = (oldMinutes * 60 * 100) + (oldSeconds * 100) + oldTenths;

    int diff = newTotal - oldTotal;

    // Converte la differenza in minuti, secondi e centesimi
    int diffMinutes = diff ~/ 6000;
    int diffSeconds = (diff % 6000) ~/ 100;
    int diffTenths = diff % 100;

    // Formatta la differenza con zeri iniziali
    String tempM = diffMinutes < 10 ? "0$diffMinutes" : diffMinutes.toString();
    String tempS = diffSeconds < 10 ? "0$diffSeconds" : diffSeconds.toString();
    String tempTS = diffTenths < 10 ? "0$diffTenths" : diffTenths.toString();
    print("| $diffMinutes : $diffSeconds . $diffTenths |");

    return "$tempM:$tempS.$tempTS";
  }

  // Widget principale che mostra il timer e la lista dei punti
  Widget body() {
    return Expanded(
      // Container del timer con bordo dinamico (cerchio o rettangolo)
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

  // Widget scorrevole per mostrare la lista dei punti registrati
  Widget slider() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: textWidgets,
        ),
      ),
    );
  }
  
  // Widget dinamico che mostra i pulsanti appropriati in base allo stato
  Widget buttonAction() {
    // Stato iniziale: mostra solo il pulsante "start"
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
      // Se il timer è in pausa: mostra "stop" e "continue"
      if (nextStateButtns) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Pulsante per fermare completamente il timer
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

            // Pulsante per continuare il timer
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
        // Timer in esecuzione: mostra "point" e "pause"
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Pulsante per aggiungere un punto 
            TextButton(
              style: IconButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () {
                addTime(timerString);
              },
              child: Text(
                "point",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 30,
            ),

            // Pulsante per mettere in pausa
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
              height: 60,
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
