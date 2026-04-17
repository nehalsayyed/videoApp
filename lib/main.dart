import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart'; // Added
import 'package:path/path.dart' as p;

void main() => runApp(const MaterialApp(home: RecorderExample()));

class RecorderExample extends StatefulWidget {
  const RecorderExample({super.key});

  @override
  State<RecorderExample> createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample> {
  // Controllers
  late AudioRecorder audioRecorder;
  late AudioPlayer audioPlayer;

  // State variables
  bool isRecording = false;
  String? lastPath;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioRecorder = AudioRecorder();
    audioPlayer = AudioPlayer();

    // Listen to player state to update UI when audio finishes
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  // --- RECORDING LOGIC ---

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final String filePath = p.join(directory.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');

        await audioRecorder.start(const RecordConfig(), path: filePath);

        setState(() {
          isRecording = true;
          lastPath = null;
        });
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      setState(() {
        isRecording = false;
        lastPath = path;
      });
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  // --- PLAYBACK LOGIC ---

  Future<void> playRecording() async {
    try {
      if (lastPath != null) {
        // Source.deviceFilePath is used for local storage files
        await audioPlayer.play(DeviceFileSource(lastPath!));
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> stopPlayback() async {
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recorder & Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Indicator
            Icon(
              isRecording ? Icons.mic : (isPlaying ? Icons.play_circle : Icons.mic_none),
              size: 80,
              color: isRecording ? Colors.red : (isPlaying ? Colors.green : Colors.grey),
            ),
            const SizedBox(height: 20),

            // Record Button
            ElevatedButton.icon(
              onPressed: isRecording ? stopRecording : startRecording,
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? "Stop Recording" : "Start Recording"),
              style: ElevatedButton.styleFrom(backgroundColor: isRecording ? Colors.red.shade100 : null),
            ),

            const SizedBox(height: 10),

            // Play Button (only shows if we have a file)
            if (lastPath != null && !isRecording)
              ElevatedButton.icon(
                onPressed: isPlaying ? stopPlayback : playRecording,
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? "Stop Playback" : "Play Last Recording"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
              ),

            if (lastPath != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "File: ${p.basename(lastPath!)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
