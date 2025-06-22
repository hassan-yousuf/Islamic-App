import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzanSettingsScreen extends StatefulWidget {
  const AzanSettingsScreen({super.key});

  @override
  State<AzanSettingsScreen> createState() => _AzanSettingsScreenState();
}

class _AzanSettingsScreenState extends State<AzanSettingsScreen> {
  final List<String> azanSounds = ['azan1', 'azan2', 'azan3'];
  String? selectedSound;
  final AudioPlayer player = AudioPlayer();
  String? currentlyPlaying;
  PlayerState playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();

    // Listen to player state
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        playerState = state;
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          currentlyPlaying = null;
        }
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSound = prefs.getString('azan_sound') ?? azanSounds[0];
    });
  }

  Future<void> _saveSelectedSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('azan_sound', sound);
    setState(() {
      selectedSound = sound;
    });
  }

  Future<void> _togglePlayPause(String sound) async {
    if (currentlyPlaying == sound && playerState == PlayerState.playing) {
      await player.pause();
    } else {
      await player.stop();
      await player.play(AssetSource('audio/$sound.mp3'));
      setState(() {
        currentlyPlaying = sound;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azan Sound Settings')),
      body: ListView.builder(
        itemCount: azanSounds.length,
        itemBuilder: (context, index) {
          final sound = azanSounds[index];
          final isPlaying =
              currentlyPlaying == sound && playerState == PlayerState.playing;

          return ListTile(
            title: Text(sound.toUpperCase()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _togglePlayPause(sound),
                ),
                Radio<String>(
                  value: sound,
                  groupValue: selectedSound,
                  onChanged: (value) {
                    if (value != null) _saveSelectedSound(value);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
