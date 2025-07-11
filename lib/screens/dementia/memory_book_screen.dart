import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../themes/minimalistic_theme.dart';

class MemoryBookScreen extends StatefulWidget {
  const MemoryBookScreen({super.key});

  @override
  State<MemoryBookScreen> createState() => _MemoryBookScreenState();
}

class _MemoryBookScreenState extends State<MemoryBookScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();
  
  int _selectedTab = 0;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  
  // User's custom memories
  List<MemoryItem> _memories = [];
  List<AudioItem> _audioRecordings = [];
  List<String> _imageFiles = [];
  
  @override
  void initState() {
    super.initState();
    _initializeTts();
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
  
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  Future<void> _requestPermissions() async {
    try {
      await Permission.microphone.request();
      // Skip storage permission on web as it's not supported
      if (!kIsWeb) {
        await Permission.storage.request();
      }
    } catch (e) {
      print('Permission request error: $e');
      // Continue anyway for web platform
    }
  }
  
  Future<void> _speakCurrentSection() async {
    switch (_selectedTab) {
      case 0:
        await _speakText('Here are your photos and memories.');
        break;
      case 1:
        await _speakText('Here are your personal memories.');
        break;
      case 2:
        await _speakText('Here are your audio recordings.');
        break;
    }
  }
  
  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Memory Book',
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
            onPressed: () => _speakCurrentSection(),
            tooltip: 'Read aloud',
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
              // Tab Navigation
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('Photos', Icons.photo_library, 0),
                    ),
                    Expanded(
                      child: _buildTabButton('Memories', Icons.photo_album, 1),
                    ),
                    Expanded(
                      child: _buildTabButton('Audio', Icons.audiotrack, 2),
                    ),
                  ],
                ),
              ),
              
              // Content based on selected tab
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabButton(String title, IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPhotosSection();
      case 1:
        return _buildMemoriesSection();
      case 2:
        return _buildAudioSection();
      default:
        return _buildPhotosSection();
    }
  }
  
  Widget _buildPhotosSection() {
    return Column(
      children: [
        Expanded(
          child: _imageFiles.isEmpty
              ? _buildEmptyState('No photos yet', 'Import your favorite pictures to create memories')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return _buildImageCard(_imageFiles[index]);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _importPicture,
            icon: const Icon(Icons.photo_library),
            label: const Text('Import Picture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalisticTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAudioSection() {
    return Column(
      children: [
        Expanded(
          child: _audioRecordings.isEmpty
              ? _buildEmptyState('No audio recordings yet', 'Record or import audio files to preserve voices and stories')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _audioRecordings.length,
                  itemBuilder: (context, index) {
                    return _buildAudioCard(_audioRecordings[index]);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _recordAudio,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : MinimalisticTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickAudio,
                icon: const Icon(Icons.audiotrack),
                label: const Text('Import Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MinimalisticTheme.secondaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioCard(AudioItem audio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalisticTheme.primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Recording',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    audio.path.split('/').last,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _togglePlay(audio.path),
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMemoriesSection() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _memories.length + _imageFiles.length,
            itemBuilder: (context, index) {
              if (index < _memories.length) {
                return _buildMemoryCard(_memories[index]);
              } else {
                int adjustedIndex = index - _memories.length;
                return _buildImageCard(_imageFiles[adjustedIndex]);
              }
            },
          ),
        ),
        _buildAddMemoryButton(),
      ],
    );
  }

  Widget _buildMemoryCard(MemoryItem memory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MinimalisticTheme.surfaceColor.withOpacity(0.25),
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
            Text(
              memory.text,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (memory.audioPath != null)
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    iconSize: 32,
                    onPressed: () {
                      _togglePlay(memory.audioPath!);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(height: 180),
    );
  }

  Widget _buildAddMemoryButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _importPicture,
            icon: const Icon(Icons.photo_library),
            label: const Text("Import Photo"),
          ),
          ElevatedButton.icon(
            onPressed: _pickAudio,
            icon: const Icon(Icons.audiotrack),
            label: const Text("Import Audio"),
          ),
          ElevatedButton.icon(
            onPressed: _recordAudio,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording ? "Stop Recording" : "Record Audio"),
          ),
        ],
      ),
    );
  }

  Future<void> _importPicture() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        final dir = await getApplicationDocumentsDirectory();
        String filePath = '${dir.path}/${result.files.first.name}';
        File file = File(filePath);
        await file.writeAsBytes(fileBytes);
        setState(() {
          _audioRecordings.add(AudioItem(filePath));
        });
      }
    }
  }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      String? path = await _audioRecorder.stop();
      if (path != null && path.isNotEmpty) {
        setState(() {
          _audioRecordings.add(AudioItem(path));
          _isRecording = false;
        });
      }
    } else {
      await _requestPermissions();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
        _currentRecordingPath = filePath;
      });
    }
  }

  Future<void> _togglePlay(String filePath) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(filePath));
      setState(() => _isPlaying = true);
    }
  }
}

class MemoryItem {
  final String text;
  final String? audioPath;

  MemoryItem(this.text, this.audioPath);
}

class AudioItem {
  final String path;

  AudioItem(this.path);
}

class FamilyMember {
  final String name;
  final String relationship;
  final String phone;
  final IconData photo;
  final String voiceNote;
  final String memories;
  final String birthday;

  FamilyMember({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.photo,
    required this.voiceNote,
    required this.memories,
    required this.birthday,
  });
}

class LifeMemory {
  final String title;
  final String date;
  final String description;
  final IconData photo;
  final String category;

  LifeMemory({
    required this.title,
    required this.date,
    required this.description,
    required this.photo,
    required this.category,
  });
}
