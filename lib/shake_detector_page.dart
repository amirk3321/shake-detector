import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shake/shake.dart';
import 'dart:ui';

class ShakeDeductorPage extends StatefulWidget {
  const ShakeDeductorPage({super.key});

  @override
  State<ShakeDeductorPage> createState() => _ShakeDeductorPageState();
}

class _ShakeDeductorPageState extends State<ShakeDeductorPage> with SingleTickerProviderStateMixin {


  bool isShake = false;

   ShakeDetector? detector;

   AudioPlayer player = AudioPlayer();


  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {

    player.setAsset('assets/alert.mp3');


    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
      }
    });
    detector = ShakeDetector.autoStart(
        onPhoneShake: () {
          print('Phone is shaking');
          setState(() {
            isShake = true;
          });

          player.play();
          _showShakeAlert();
        },
        shakeThresholdGravity: 2.7,
        minimumShakeCount: 2,
        shakeSlopTimeMS: 1000);

    print('Detector is $detector');


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Color animation (transitioning to red)
    _colorAnimation = ColorTween(
      begin: Colors.red.shade200,
      end: Colors.red.shade600,
    ).animate(_controller);

    // Border "breathing" animation
    _borderAnimation = Tween<double>(begin: 10, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isShake
            ? AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: double.infinity, // Full-screen width
              height: double.infinity, // Full-screen height
              decoration: BoxDecoration(
                color: _colorAnimation.value,
              ),
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.red, // Border color
                      width: _borderAnimation.value, // Breathing border
                    ),
                  ),
                ),
              ),
            );
          },
        )
            : const Text('Shake Phone'),
      ),
    );
  }


  void _showShakeAlert() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Dim the dialog
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Add blur effect to the background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3), // Dim background
              ),
            ),
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 16,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adjust to content height
                    children: [
                      const Text(
                        'Shake Alert',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This is a shake alert dialog.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isShake = false;
                          });
                          player.stop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    detector?.stopListening();
    player.dispose();
    _controller.dispose();
    super.dispose();
  }
}
