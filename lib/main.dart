import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

// --- Configuration ---
const String firebaseHost = "k9-smart-fecdd-default-rtdb.firebaseio.com"; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAisxs2GEPLBi1CRWsCiuOQTdubqv9SzRg", 
      appId: "1:632362218622:web:c3bfd2f33173b5a3bf942f",
      messagingSenderId: "632362218622",
      projectId: "k9-smart-fecdd",
      storageBucket: "k9-smart-fecdd.firebasestorage.app",
      databaseURL: "https://$firebaseHost", 
    ),
  );
  runApp(const K9SmartApp());
}

class K9SmartApp extends StatelessWidget {
  const K9SmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K9 Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1), 
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const DeviceListScreen(), // Starts at the Device List
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 1: DEVICE MANAGER (List of Systems)
// ---------------------------------------------------------------------------
class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Simple list to store device IDs (In a real app, use SharedPreferences to save this)
  final List<String> myDevices = ['default-app-id']; 
  final TextEditingController _deviceController = TextEditingController();

  void _addDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Feeder"),
        content: TextField(
          controller: _deviceController,
          decoration: const InputDecoration(
            labelText: "Device ID (e.g. feeder_02)",
            hintText: "Enter the ID flashed to your ESP32"
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_deviceController.text.isNotEmpty) {
                setState(() => myDevices.add(_deviceController.text.trim()));
                Navigator.pop(context);
                _deviceController.clear();
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My K9 Devices')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: myDevices.length,
        itemBuilder: (context, index) {
          final deviceId = myDevices[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0D47A1),
                child: Icon(Icons.pets, color: Colors.white),
              ),
              title: Text("Feeder: $deviceId", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Tap to control"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeederDashboard(deviceId: deviceId)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 2: DASHBOARD (Control Specific Feeder)
// ---------------------------------------------------------------------------
class FeederDashboard extends StatefulWidget {
  final String deviceId;
  const FeederDashboard({super.key, required this.deviceId});

  @override
  State<FeederDashboard> createState() => _FeederDashboardState();
}

class _FeederDashboardState extends State<FeederDashboard> {
  late DatabaseReference statusRef;
  late DatabaseReference commandRef;
  String hopperDistance = "Loading...";
  String statusAlert = "Checking...";

  @override
  void initState() {
    super.initState();
    // Build path using the dynamic Device ID
    final basePath = 'artifacts/${widget.deviceId}/public/data/feeder_data';
    statusRef = FirebaseDatabase.instance.ref('$basePath/status');
    commandRef = FirebaseDatabase.instance.ref('$basePath/commands');

    statusRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          hopperDistance = "${data['hopperDistance'] ?? 0} cm";
          statusAlert = data['statusAlert'] ?? 'OK';
        });
      }
    });
  }

  Future<void> sendManualFeed() async {
    await commandRef.update({
      'manual_feed': true,
      'timestamp': ServerValue.timestamp,
    });
    if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feed Command Sent!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Control: ${widget.deviceId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.kitchen, size: 50, color: Colors.blueGrey),
                    const SizedBox(height: 10),
                    const Text("Hopper Level", style: TextStyle(color: Colors.grey)),
                    Text(hopperDistance, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text("Status: $statusAlert", style: TextStyle(
                      color: statusAlert.contains("LOW") ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: sendManualFeed,
                icon: const Icon(Icons.fastfood),
                label: const Text("DISPENSE NOW"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScheduleScreen(deviceId: widget.deviceId)),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("MANAGE SCHEDULE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN 3: SCHEDULER (Set Times)
// ---------------------------------------------------------------------------
class ScheduleScreen extends StatefulWidget {
  final String deviceId;
  const ScheduleScreen({super.key, required this.deviceId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DatabaseReference scheduleRef;
  List<String> scheduledTimes = [];

  @override
  void initState() {
    super.initState();
    final basePath = 'artifacts/${widget.deviceId}/public/data/feeder_data';
    scheduleRef = FirebaseDatabase.instance.ref('$basePath/schedule');

    scheduleRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        // Firebase returns a List or a Map, we convert to List<String>
        final data = event.snapshot.value;
        if (data is List) {
          setState(() {
            scheduledTimes = List<String>.from(data.where((e) => e != null));
          });
        }
      } else {
        setState(() => scheduledTimes = []);
      }
    });
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Format as "HH:MM" (24 hour format is easier for ESP32)
      final String formatted = "${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}";
      if (!scheduledTimes.contains(formatted)) {
        final newTimes = [...scheduledTimes, formatted];
        newTimes.sort(); // Keep times in order
        await scheduleRef.set(newTimes);
      }
    }
  }

  Future<void> _deleteTime(int index) async {
    final newTimes = List<String>.from(scheduledTimes);
    newTimes.removeAt(index);
    await scheduleRef.set(newTimes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feeding Schedule")),
      body: scheduledTimes.isEmpty 
        ? const Center(child: Text("No feeding times set yet."))
        : ListView.separated(
            itemCount: scheduledTimes.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(scheduledTimes[index], style: const TextStyle(fontSize: 20)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTime(index),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTime,
        child: const Icon(Icons.add),
      ),
    );
  }
}