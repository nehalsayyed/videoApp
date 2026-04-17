import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MaterialApp(home: RecorderExample()));

class RecorderExample extends StatefulWidget {
  const RecorderExample({super.key});

  @override
  State<RecorderExample> createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample> {
  late AudioRecorder audioRecorder;
  bool isRecording = false;
  String? lastPath;

  @override
  void initState() {
    super.initState();
    audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        // 1. Get a valid directory to save the file
        final directory = await getApplicationDocumentsDirectory();
        final String filePath = p.join(directory.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');

        // 2. Define the configuration
        const config = RecordConfig(); 

        // 3. Start recording
        await audioRecorder.start(config, path: filePath);

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
      debugPrint("Saved to: $path");
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording)
              const Text("Recording in progress...", style: TextStyle(color: Colors.red, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isRecording ? stopRecording : startRecording,
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? "Stop Recording" : "Start Recording"),
            ),
            if (lastPath != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Last file saved at:\n$lastPath", textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
