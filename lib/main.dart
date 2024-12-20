import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

int globalcounter = 0;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => VoiceControlPage(),
        '/second': (context) => SecondPage(),
        '/splash': (context) => SplashScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the VoiceControlPage after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
    });

    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to Voice Control App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class VoiceControlPage extends StatefulWidget {
  @override
  _VoiceControlPageState createState() => _VoiceControlPageState();
}

class _VoiceControlPageState extends State<VoiceControlPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) => _onStatus(val),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _listenContinuously();
    } else {
      setState(() {
        _text = 'Speech recognition not available';
      });
    }
  }

  void _onStatus(String val) {
    print('onStatus: $val');
    if (val == "done" || val == "notListening") {
      _listenContinuously(); // Restart listening when status is "done" or "notListening"
    }
  }

  void _listenContinuously() {
    _speech.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
        if (val.hasConfidenceRating && val.confidence > 0) {
          _confidence = val.confidence;
        }
        // Check for specific command to open new page
        if (_text.toLowerCase().contains('open next')) {
          // Navigate to SecondPage
          if (globalcounter == 0) {
            Navigator.pushNamed(context, '/second');
            globalcounter = 1;
          }
        }

        if (_text.toLowerCase().contains('open home')) {
          // Prevent popping if on VoiceControlPage
          if (globalcounter == 1) {
            Navigator.pop(context);
            //Navigator.of(context).popUntil(ModalRoute.withName('/'));
            globalcounter = 0;
          }
        }
      }),
      listenMode: stt.ListenMode.dictation, // Enable continuous listening mode
      partialResults: true, // Get partial results for continuous updates
      onSoundLevelChange: (level) =>
          print('sound level: $level'), // Ensure the microphone stays active
      cancelOnError: false, // Prevent cancel on error
      listenFor: Duration(seconds: 60), // Set a long duration to keep listening
    );
    setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Control App'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _text,
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: Text(
          'This is the Second Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
