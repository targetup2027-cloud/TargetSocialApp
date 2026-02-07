import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class CallScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = false;
  bool _isCallConnected = false;
  int _callDuration = 0;
  Timer? _callTimer;
  Timer? _connectTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _simulateConnection();
    if (widget.isVideoCall) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _simulateConnection() {
    _connectTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCallConnected = true);
        _startCallTimer();
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDuration++);
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _toggleMic() {
    HapticFeedback.lightImpact();
    setState(() => _isMicMuted = !_isMicMuted);
  }

  void _toggleCamera() {
    HapticFeedback.lightImpact();
    setState(() => _isCameraOff = !_isCameraOff);
  }

  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() => _isSpeakerOn = !_isSpeakerOn);
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
  }

  void _switchCamera() async {
    if (_cameraController == null) return;
    HapticFeedback.lightImpact();
    
    final cameras = await availableCameras();
    if (cameras.length < 2) return;
    
    final currentDirection = _cameraController!.description.lensDirection;
    final newCamera = cameras.firstWhere(
      (c) => c.lensDirection != currentDirection,
      orElse: () => cameras.first,
    );
    
    await _cameraController!.dispose();
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _connectTimer?.cancel();
    _cameraController?.dispose();
    _pulseController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.isVideoCall) _buildVideoBackground() else _buildAudioBackground(),
          _buildGradientOverlay(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                if (!_isCallConnected) _buildCallingIndicator(),
                const Spacer(),
                _buildControls(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (widget.isVideoCall && _isCameraInitialized && !_isCameraOff)
            _buildSelfView(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.userAvatar.isNotEmpty
                    ? Image.network(
                        widget.userAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            const Color(0xFF0f3460),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4 + (_pulseController.value * 0.2)),
                          blurRadius: 40 + (_pulseController.value * 20),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.userAvatar.isNotEmpty
                          ? Image.network(
                              widget.userAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.person, size: 70, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                _isCallConnected ? _formatDuration(_callDuration) : (widget.isVideoCall ? 'Video Call' : 'Voice Call'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isCallConnected)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Spacer(),
          if (widget.isVideoCall)
            GestureDetector(
              onTap: _switchCamera,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cameraswitch, color: Colors.white, size: 22),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildCallingIndicator() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (_pulseController.value * 0.5),
              child: Text(
                'Calling...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.3;
                final value = ((_pulseController.value + delay) % 1.0);
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMicMuted ? Icons.mic_off : Icons.mic,
            label: _isMicMuted ? 'Unmute' : 'Mute',
            isActive: _isMicMuted,
            onTap: _toggleMic,
          ),
          if (widget.isVideoCall)
            _buildControlButton(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: _isCameraOff ? 'Camera On' : 'Camera Off',
              isActive: _isCameraOff,
              onTap: _toggleCamera,
            ),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
            isActive: _isSpeakerOn,
            onTap: _toggleSpeaker,
          ),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: _endCall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'End',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfView() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 20,
      child: GestureDetector(
        onTap: _switchCamera,
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B981),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
