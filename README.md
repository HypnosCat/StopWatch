# Stopwatch App
Un semplice cronometro basato su Flutter

## Descrizione
Stopwatch App è un'applicazione mobile minimalista per la misurazione del tempo, con la possibilità di registrare i risultati intermedi. L'applicazione supporta l'orientamento verticale dello schermo.

## Funzionalità

- Cronometro preciso: misurazione del tempo con una precisione al centesimo di secondo
- Punti fissi: salvataggio dei risultati intermedi
- Pausa/Riprendi: possibilità di mettere in pausa e riprendere il conto alla rovescia
- Calcolo automatico della differenza: mostra la differenza tra i risultati intermedi
- Orientamento verticale: ottimizzato per l'uso verticale
- Elenco scorrevole: visualizza tutti i punti fissi

## Schermate
![](/assets/screenshot/s1.png)
![](/assets/screenshot/s2.png)
![](/assets/screenshot/s3.png)

## Installazione
- Requisiti
    - Flutter SDK 3.0 o successivo
    - Dart 3.0 o successivo
    - Android Studio / VS Code con plugin Flutter
    - Dispositivo fisico o emulatore

## Utilizzo
Funzioni di base

Avvio del cronometro
- Premere il pulsante "Start" per avviare il conto alla rovescia

Fissare il risultato intermedio
- Mentre il cronometro è in funzione, premere "Point"
- Il risultato verrà aggiunto all'elenco con il calcolo automatico della differenza

Pausa

- Premere "Pausa" per mettere in pausa il conto alla rovescia
- Premere "Continua" per continuare

Interrompi e azzera

- Durante la pausa, premere "Stop" per azzerare completamente il cronometro
- Tutti i punti salvati verranno eliminati

#### Formato di visualizzazione dell'ora:
```
ХХ:ХХ.ХХ
 │ │  │
 │ │  └─ Centesimi di secondo (00-99)
 │ └──── Secondi (00-59)
 └──────── Minuti (00-59)
```

### Elenco dei risultati intermedi
Ogni voce nell'elenco mostra:

- Numero del punto - il numero sequenziale del fix
- Differenza - il tempo tra il punto attuale e quello precedente (verde)
- Tempo totale - il tempo totale dall'inizio

## Struttura del progetto
```
lib/
├── main.dart                 # Punto di ingresso dell'applicazione
│   ├── MyApp                 # Widget principale di MaterialApp
│   ├── MyHomePage            # Pagina principale (StatefulWidget)
│   └── _MyHomePageState      # Stato della home page
│       ├── startTick()       # Avvio del timer
│       ├── updateTimerUI()   # Aggiornamento dell'interfaccia utente del timer
│       ├── stopTimer()       # Arresto del timer
│       ├── pause()           # Pausa/continua
│       ├── addTime()         # Aggiungere un punto
│       ├── bestTime()        # Calcolo della differenza
│       ├── body()            # Contenuto principale
│       ├── slider()          # Elenco dei punti
│       └── buttonAction()    # Pulsanti dinamici
```
### Funzionalità di implementazione
Timer basato su stream
Utilizza Stream.periodic per creare un timer preciso:

```
tickStream = Stream.periodic(Duration(milliseconds: 10), (x) => x);
```
- Genera un evento ogni 10 millisecondi (tick)
- Garantisce una precisione al centesimo di secondo
- Supporta la pausa e la ripresa tramite StreamSubscription