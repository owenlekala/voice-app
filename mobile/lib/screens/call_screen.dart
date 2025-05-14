import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class CallScreen extends StatefulWidget {
  final String phoneNumber;
  final String? callSid;
  final String? contactName;
  final Uint8List? contactAvatar;

  const CallScreen({
    super.key,
    required this.phoneNumber,
    this.callSid,
    this.contactName,
    this.contactAvatar,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  String _callStatus = 'Calling...';
  String _callDuration = '00:00';
  bool _isCallActive = true;
  final String _backendUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isCallActive) {
        setState(() {
          _callStatus = 'Connected';
        });
        
        int seconds = 0;
        // Start the timer
        Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted || !_isCallActive) return false;
          
          seconds++;
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          
          setState(() {
            _callDuration = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
          });
          
          return _isCallActive;
        });
      }
    });
  }

  Future<void> _endCall() async {
    setState(() {
      _isCallActive = false;
      _callStatus = 'Ending call...';
    });

    if (widget.callSid != null) {
      try {
        await http.post(
          Uri.parse('$_backendUrl/api/voice/end'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'callSid': widget.callSid,
          }),
        );
      } catch (e) {
        // Handle error silently
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // Implement actual mute functionality with Twilio
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // Implement actual speaker functionality with Twilio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.contactName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              _buildContactAvatar(),
              const SizedBox(height: 20),
              Text(
                _callStatus,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _callDuration,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              _buildCallControls(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
        image: widget.contactAvatar != null
            ? DecorationImage(
                image: MemoryImage(widget.contactAvatar!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.contactAvatar == null
          ? Center(
              child: Text(
                (widget.contactName?.isNotEmpty == true)
                    ? widget.contactName!.substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.mic_off,
          label: 'Mute',
          isActive: _isMuted,
          onPressed: _toggleMute,
        ),
        _buildEndCallButton(),
        _buildControlButton(
          icon: Icons.volume_up,
          label: 'Speaker',
          isActive: _isSpeakerOn,
          onPressed: _toggleSpeaker,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue.shade700 : Colors.white,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: isActive ? Colors.white : Colors.blue.shade700,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'End Call',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}