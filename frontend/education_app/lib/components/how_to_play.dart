import 'package:flutter/material.dart';

class HowToPlayButton extends StatelessWidget {
  final String instructions;

  const HowToPlayButton({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('How to Play'),

              content: Text(
                instructions,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Got it'),
                ),
              ],
            );
          },
        );
      },

      icon: const Icon(Icons.help_outline),

      label: const Text('How to Play'),
    );
  }
}