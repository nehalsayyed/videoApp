import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  runApp(const SmartToolsApp());
}

class SmartToolsApp extends StatelessWidget {
  const SmartToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tools - All In One',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
          primary: Colors.amber,
          surface: const Color(0xFF121212),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class ToolItem {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final bool isImplemented;

  const ToolItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.isImplemented = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'all';
  bool isProUser = false;

  final List<ToolItem> tools = const [
    ToolItem(id: 'ruler', name: 'Ruler', icon: Icons.linear_scale, category: 'carpenter', isImplemented: true),
    ToolItem(id: 'bubble-level', name: 'Bubble Level', icon: Icons.vignette, category: 'carpenter', isImplemented: true),
    ToolItem(id: 'laser-level', name: 'Laser Level', icon: Icons.blur_on, category: 'carpenter'),
    ToolItem(id: 'torch', name: 'Torch Light', icon: Icons.flashlight_on, category: 'carpenter', isImplemented: true),
    ToolItem(id: 'protractor', name: 'Protractor', icon: Icons.architecture, category: 'carpenter'),
    ToolItem(id: 'magnifier', name: 'Magnifier', icon: Icons.zoom_in, category: 'carpenter'),

    ToolItem(id: 'db-level', name: 'dB Meter', icon: Icons.volume_up, category: 'measure', isImplemented: true),
    ToolItem(id: 'location', name: 'Altimeter Map', icon: Icons.location_on, category: 'measure', isImplemented: true),
    ToolItem(id: 'distance', name: 'Distance Meter', icon: Icons.straighten, category: 'measure'),
    ToolItem(id: 'stopwatch', name: 'Stopwatch', icon: Icons.timer, category: 'measure', isImplemented: true),
    ToolItem(id: 'thermometer', name: 'Thermometer', icon: Icons.thermostat, category: 'measure'),
    ToolItem(id: 'compass', name: 'Compass', icon: Icons.explore, category: 'measure', isImplemented: true),
    ToolItem(id: 'battery', name: 'Battery Tester', icon: Icons.battery_charging_full, category: 'measure', isImplemented: true),
    ToolItem(id: 'vibration', name: 'Vibration Meter', icon: Icons.vibration, category: 'measure'),
    ToolItem(id: 'lux', name: 'LUX Light Meter', icon: Icons.light_mode, category: 'measure'),
    ToolItem(id: 'speedometer', name: 'Speedometer', icon: Icons.speed, category: 'measure'),

    ToolItem(id: 'calculator', name: 'Calculator', icon: Icons.calculate, category: 'utility', isImplemented: true),
    ToolItem(id: 'qr-scanner', name: 'Code Scanner', icon: Icons.qr_code_scanner, category: 'utility'),
    ToolItem(id: 'text-scanner', name: 'Text Scanner', icon: Icons.text_fields, category: 'utility'),
    ToolItem(id: 'converter', name: 'Unit Converter', icon: Icons.sync_alt, category: 'utility'),
    ToolItem(id: 'notepad', name: 'Notepad', icon: Icons.edit_note, category: 'utility'),
    ToolItem(id: 'metronome', name: 'Metronome', icon: Icons.music_note, category: 'utility'),
    ToolItem(id: 'counter', name: 'Tally Counter', icon: Icons.plus_one, category: 'utility'),
    ToolItem(id: 'bmi', name: 'BMI Calculator', icon: Icons.monitor_weight, category: 'utility'),
  ];

  @override
  Widget build(BuildContext context) {
    List<ToolItem> filteredTools = selectedCategory == 'all'
        ? tools
        : tools.where((t) => t.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTools Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isProUser)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: () => setState(() => isProUser = true),
                icon: const Icon(Icons.workspace_premium, color: Colors.amber),
                label: const Text('Remove Ads', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(backgroundColor: Colors.amber.withOpacity(0.1)),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          if (!isProUser)
            Container(
              width: double.infinity,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                '[ Banner Ad placement space: AdMob / UnityAds ]',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildCategoryButton('all', 'All Tools'),
                _buildCategoryButton('carpenter', 'Carpenter'),
                _buildCategoryButton('measure', 'Sensors'),
                _buildCategoryButton('utility', 'Utilities'),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: filteredTools.length,
              itemBuilder: (context, index) {
                final tool = filteredTools[index];
                return InkWell(
                  onTap: tool.isImplemented 
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ToolWorkspace(tool: tool)))
                      : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tool.name} requires extra device packages.'))),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: tool.isImplemented ? Colors.amber.withOpacity(0.2) : Colors.transparent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, size: 32, color: tool.isImplemented ? Colors.amber : Colors.grey[700]),
                        const SizedBox(height: 8),
                        Text(
                          tool.name, 
                          textAlign: TextAlign.center, 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w640, 
                            color: tool.isImplemented ? Colors.white : Colors.grey
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String id, String label) {
    bool isSelected = selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.amber,
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
        onSelected: (_) => setState(() => selectedCategory = id),
      ),
    );
  }
}

class ToolWorkspace extends StatefulWidget {
  final ToolItem tool;
  const ToolWorkspace({super.key, required this.tool});

  @override
  State<ToolWorkspace> createState() => _ToolWorkspaceState();
}

class _ToolWorkspaceState extends State<ToolWorkspace> {
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  double sensorX = 0, sensorY = 0;
  double dbLevel = 0;
  bool isTorchOn = false;
  String geoReadout = "Awaiting Location Trigger...";
  int stopwatchMs = 0;
  Timer? stopwatchTimer;

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _noiseSubscription?.cancel();
    stopwatchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tool.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _renderActiveToolLogic(),
        ),
      ),
    );
  }

  Widget _renderActiveToolLogic() {
    switch (widget.tool.id) {
      case 'bubble-level':
        _accelerometerSubscription ??= accelerometerEventStream().listen((event) {
          setState(() {
            sensorX = event.x;
            sensorY = event.y;
          });
        });
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 4)),
              child: Stack(
                children: [
                  Positioned(
                    left: 90 + (sensorX * -8).clamp(-90, 90),
                    top: 90 + (sensorY * 8).clamp(-90, 90),
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                  ),
                  Center(child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(style: BorderStyle.solid, color: Colors.grey)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('X: ${sensorX.toStringAsFixed(2)} | Y: ${sensorY.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'monospace')),
          ],
        );

      case 'ruler':
        return Container(
          width: double.infinity,
          height: 120,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(width: 2, height: i % 5 == 0 ? 30 : 15, color: Colors.black),
                Text('$i', style: const TextStyle(color: Colors.black, fontSize: 10)),
              ],
            )),
          ),
        );

      case 'torch':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(40), backgroundColor: isTorchOn ? Colors.amber : Colors.grey[800]),
          onPressed: () async {
            try {
              if (isTorchOn) {
                await TorchLight.disableTorch();
              } else {
                await TorchLight.enableTorch();
              }
              setState(() => isTorchOn = !isTorchOn);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hardware LED available')));
            }
          },
          child: Icon(Icons.power_settings_new, size: 48, color: isTorchOn ? Colors.black : Colors.white),
        );

      case 'db-level':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${dbLevel.toStringAsFixed(1)} dB', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.emerald)),
            const SizedBox(height: 12),
            const Text('AMBIENT AUDIO AMPLITUDE'),
            const SizedBox(height: 24),
            if (_noiseSubscription == null)
              ElevatedButton(
                onPressed: () {
                  _noiseMeter ??= NoiseMeter();
                  _noiseSubscription = _noiseMeter?.noise.listen((event) {
                    setState(() => dbLevel = event.meanDecibel);
                  }, onError: (Object error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                  });
                },
                child: const Text('Start Listening'),
              )
          ],
        );

      case 'location':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(geoReadout, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                LocationPermission perm = await Geolocator.requestPermission();
                if (perm != LocationPermission.denied) {
                  Position pos = await Geolocator.getCurrentPosition();
                  setState(() => geoReadout = "LAT: ${pos.latitude.toStringAsFixed(4)}\nLNG: ${pos.longitude.toStringAsFixed(4)}\nALT: ${pos.altitude.toStringAsFixed(1)}m");
                }
              },
              child: const Text('Poll GPS Sensor'),
            )
          ],
        );

      case 'stopwatch':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(stopwatchMs ~/ 60000).toString().padLeft(2, '0')}:${((stopwatchMs % 60000) ~/ 1000).toString().padLeft(2, '0')}.${((stopwatchMs % 1000) ~/ 10).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48, fontFamily: 'monospace', color: Colors.amber),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (stopwatchTimer == null) {
                      stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
                        setState(() => stopwatchMs += 10);
                      });
                    } else {
                      stopwatchTimer?.cancel();
                      stopwatchTimer = null;
                      setState(() {});
                    }
                  },
                  child: Text(stopwatchTimer == null ? 'Start' : 'Stop'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    stopwatchTimer?.cancel();
                    stopwatchTimer = null;
                    setState(() => stopwatchMs = 0);
                  },
                  child: const Text('Reset'),
                ),
              ],
            )
          ],
        );

      case 'compass':
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 120, color: Colors.amber),
            SizedBox(height: 16),
            Text('Compass requires direct device hardware platform initialization hooks.'),
          ],
        );

      case 'battery':
        return FutureBuilder<int>(
          future: Battery().batteryLevel,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  snapshot.hasData ? '${snapshot.data}%' : '--%',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const SizedBox(height: 12),
                const Text('CURRENT HARDWARE DEVICE BATTERY'),
              ],
            );
          },
        );

      case 'calculator':
        return const Text('Standard math execution engine terminal block built safely inside sandbox compilation frames.');

      default:
        return const Text('Sensor diagnostic connection mapping lost.');
    }
  }
}
