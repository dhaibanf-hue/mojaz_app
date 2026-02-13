import 'package:flutter/material.dart';
import '../models/book.dart';
import '../constants.dart';

class DriveModeScreen extends StatelessWidget {
  final Book book;
  const DriveModeScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark for driving safety/focus
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
            ),
            const Spacer(),
            Container(
              width: 200, height: 300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(book.cover), fit: BoxFit.cover)),
            ),
            const SizedBox(height: 40),
            Text(book.title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(book.author, style: const TextStyle(color: Colors.white70, fontSize: 20)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.replay_30, color: Colors.white, size: 48), onPressed: () {}),
                Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(color: AppColors.primaryButton, shape: BoxShape.circle),
                  child: const Icon(Icons.pause, color: Colors.white, size: 60),
                ),
                IconButton(icon: const Icon(Icons.forward_30, color: Colors.white, size: 48), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 60),
            const Text('وضع القيادة نشط', style: TextStyle(color: AppColors.primaryButton, fontWeight: FontWeight.bold)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
