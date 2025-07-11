import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // User-customized medication data
  List<Medication> _medications = [];
  
  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeNotifications();
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  Future<void> _initializeNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Medications',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Go back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
            onPressed: () => _readAllMedications(),
            tooltip: 'Read all medications',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF7B68EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Today's Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medication, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Today\'s Medications',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Taken',
                          _getTakenCount().toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                        _buildStatCard(
                          'Remaining',
                          _getRemainingCount().toString(),
                          Colors.orange,
                          Icons.pending,
                        ),
                        _buildStatCard(
                          'Total',
                          _getTotalDosesCount().toString(),
                          Colors.blue,
                          Icons.medication,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Next Medication Alert
              if (_getNextMedication() != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alarm, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next: ${_getNextMedication()!.name}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Time: ${_getNextMedicationTime()}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _takeMedication(_getNextMedication()!, 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                        ),
                        child: const Text('Take Now'),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Medications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return _buildMedicationCard(medication);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddMedicationDialog(),
            heroTag: "add_medication",
            backgroundColor: Colors.blue.withOpacity(0.9),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => _showMedicationHistory(),
            heroTag: "medication_history",
            icon: const Icon(Icons.history, color: Colors.white),
            label: Text(
              'History',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green.withOpacity(0.9),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMedicationCard(Medication medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMedicationIcon(medication),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        medication.dosage,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'Prescribed by ${medication.prescribedBy}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white, size: 24),
                  onPressed: () => _readMedicationInfo(medication),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Times and Status
            Text(
              'Schedule:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(medication.times.length, (index) {
              return _buildTimeSlot(medication, index);
            }),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medication.instructions,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            if (medication.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Side Effects:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.sideEffects,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMedicationIcon(Medication medication) {
    IconData iconData;
    switch (medication.shape) {
      case MedicationShape.round:
        iconData = Icons.circle;
        break;
      case MedicationShape.oval:
        iconData = Icons.circle_outlined;
        break;
      case MedicationShape.square:
        iconData = Icons.square;
        break;
      case MedicationShape.capsule:
        iconData = Icons.medication;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: medication.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: medication.color, width: 2),
      ),
      child: Icon(
        iconData,
        size: 32,
        color: medication.color,
      ),
    );
  }
  
  Widget _buildTimeSlot(Medication medication, int timeIndex) {
    final isTaken = medication.isTaken[timeIndex];
    final time = medication.times[timeIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTaken 
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTaken ? Colors.green : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.schedule,
            color: isTaken ? Colors.green : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (!isTaken)
            ElevatedButton(
              onPressed: () => _takeMedication(medication, timeIndex),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Take'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Taken',
                style: GoogleFonts.inter(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  int _getTakenCount() {
    int count = 0;
    for (final medication in _medications) {
      count += medication.isTaken.where((taken) => taken).length;
    }
    return count;
  }
  
  int _getRemainingCount() {
    int count = 0;
    for (final medication in _medications) {
      count += medication.isTaken.where((taken) => !taken).length;
    }
    return count;
  }
  
  int _getTotalDosesCount() {
    int count = 0;
    for (final medication in _medications) {
      count += medication.times.length;
    }
    return count;
  }
  
  Medication? _getNextMedication() {
    for (final medication in _medications) {
      for (int i = 0; i < medication.isTaken.length; i++) {
        if (!medication.isTaken[i]) {
          return medication;
        }
      }
    }
    return null;
  }
  
  String _getNextMedicationTime() {
    final nextMed = _getNextMedication();
    if (nextMed != null) {
      for (int i = 0; i < nextMed.isTaken.length; i++) {
        if (!nextMed.isTaken[i]) {
          return nextMed.times[i];
        }
      }
    }
    return '';
  }
  
  void _takeMedication(Medication medication, int timeIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildMedicationIcon(medication),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Take ${medication.name}?',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosage: ${medication.dosage}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${medication.times[timeIndex]}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              medication.instructions,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markMedicationTaken(medication, timeIndex);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Taken'),
          ),
        ],
      ),
    );
  }
  
  void _markMedicationTaken(Medication medication, int timeIndex) {
    setState(() {
      medication.isTaken[timeIndex] = true;
      medication.lastTaken = DateTime.now();
    });
    
    _speakText('Good job! You took your ${medication.name}.');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${medication.name} marked as taken!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Notify caregiver (simulated)
    _notifyCaregiver(medication);
  }
  
  void _notifyCaregiver(Medication medication) {
    // Simulate caregiver notification
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Caregiver notified: ${medication.name} taken'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
  
  Future<void> _readMedicationInfo(Medication medication) async {
    final info = '${medication.name}. Take ${medication.dosage} at ${medication.times.join(' and ')}. ${medication.instructions}';
    await _speakText(info);
  }
  
  Future<void> _readAllMedications() async {
    String allMeds = 'Here are your medications for today. ';
    for (final medication in _medications) {
      allMeds += '${medication.name}, take ${medication.dosage} at ${medication.times.join(' and ')}. ';
    }
    await _speakText(allMeds);
  }
  
  void _showMedicationHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medication History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Your medication history is tracked and shared with your caregivers and doctors.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Today: ${_getTakenCount()} of ${_getTotalDosesCount()} doses taken',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  void _showAddMedicationDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dosageController = TextEditingController();
    final TextEditingController instructionsController = TextEditingController();
    final TextEditingController sideEffectsController = TextEditingController();
    final TextEditingController prescribedByController = TextEditingController();
    
    List<String> times = [''];
    MedicationShape selectedShape = MedicationShape.round;
    Color selectedColor = Colors.red;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Medication',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 1 tablet)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prescribedByController,
                  decoration: const InputDecoration(
                    labelText: 'Prescribed by (Doctor name)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Medication Times:'),
                ...List.generate(times.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Time ${index + 1} (e.g., 8:00 AM)',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              times[index] = value;
                            },
                          ),
                        ),
                        if (times.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              setDialogState(() {
                                times.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      times.add('');
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Time'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MedicationShape>(
                  value: selectedShape,
                  decoration: const InputDecoration(
                    labelText: 'Medication Shape',
                    border: OutlineInputBorder(),
                  ),
                  items: MedicationShape.values.map((shape) {
                    String shapeName = shape.toString().split('.').last;
                    shapeName = shapeName[0].toUpperCase() + shapeName.substring(1);
                    return DropdownMenuItem(
                      value: shape,
                      child: Text(shapeName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedShape = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Medication Color:'),
                Row(
                  children: [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.yellow,
                    Colors.teal,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sideEffectsController,
                  decoration: const InputDecoration(
                    labelText: 'Side Effects (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    dosageController.text.isNotEmpty &&
                    times.any((time) => time.isNotEmpty)) {
                  
                  final validTimes = times.where((time) => time.isNotEmpty).toList();
                  final newMedication = Medication(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    dosage: dosageController.text,
                    times: validTimes,
                    color: selectedColor,
                    shape: selectedShape,
                    instructions: instructionsController.text.isEmpty 
                        ? 'Take as prescribed' 
                        : instructionsController.text,
                    isTaken: List.filled(validTimes.length, false),
                    lastTaken: null,
                    sideEffects: sideEffectsController.text,
                    prescribedBy: prescribedByController.text.isEmpty 
                        ? 'Doctor' 
                        : prescribedByController.text,
                  );
                  
                  setState(() {
                    _medications.add(newMedication);
                  });
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Medication "${nameController.text}" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Medication'),
            ),
          ],
        ),
      ),
    );
  }
}

enum MedicationShape {
  round,
  oval,
  square,
  capsule,
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final Color color;
  final MedicationShape shape;
  final String instructions;
  final List<bool> isTaken;
  DateTime? lastTaken;
  final String sideEffects;
  final String prescribedBy;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.color,
    required this.shape,
    required this.instructions,
    required this.isTaken,
    this.lastTaken,
    required this.sideEffects,
    required this.prescribedBy,
  });
}
