import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RateExperienceScreen extends StatefulWidget {
  const RateExperienceScreen({super.key});

  @override
  State<RateExperienceScreen> createState() => _RateExperienceScreenState();
}

class _RateExperienceScreenState extends State<RateExperienceScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: AppTheme.textDark), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('How was your experience?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Your feedback helps us improve Sentinel Pro for everyone.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textLight)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 48, color: Colors.amber),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _rating == 0 ? null : () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your rating!')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
