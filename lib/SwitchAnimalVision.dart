import 'package:flutter/material.dart';

class SwitchAnimalVision extends StatelessWidget {
  final String currentAnimal;
  final void Function(String value) onChange;

  const SwitchAnimalVision(
      {super.key, required this.currentAnimal, required this.onChange});

  Widget _buildAnimalButton(String vision, String emoji) {
    return ElevatedButton(
      onPressed: () => onChange(vision),
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: currentAnimal == vision ? Colors.blue : Colors.grey),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAnimalButton('cat', '🐱'),
        _buildAnimalButton('dog', '🐶'),
        _buildAnimalButton('parrot', '🦜'),
      ],
    );
  }
}
