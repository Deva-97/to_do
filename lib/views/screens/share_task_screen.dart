import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class ShareTaskScreen extends StatefulWidget {
  final Task task;
  const ShareTaskScreen({super.key, required this.task});

  @override
  State<ShareTaskScreen> createState() => _ShareTaskScreenState();
}

class _ShareTaskScreenState extends State<ShareTaskScreen> {
  final _emailCtrl = TextEditingController();
  final _waCtrl    = TextEditingController();
  bool _isSharing  = false;

  Future<void> _shareEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      // 1) Record share in Firestore
      await context.read<TaskProvider>().shareTask(
        widget.task,
        'email',
        email,
      );

      // 2) Build the public edit‐URL
      final editLink = 'https://to-do-49ef2.web.app/edit/${widget.task.id}';

      // 3) Compose subject & body
      final rawSubject = 'Task: ${widget.task.title}';
      final rawBody    = '${widget.task.title}\n\n'
          'Tap to edit your task:\n$editLink';
      final subject    = Uri.encodeComponent(rawSubject).replaceAll('+','%20');
      final body       = Uri.encodeComponent(rawBody).   replaceAll('+','%20');

      // 4) Create mailto: URI
      final mailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=$subject&body=$body',
      );

      // 5) Launch email app
      if (!await launchUrl(mailUri, mode: LaunchMode.externalApplication)) {
        throw 'No email app installed';
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email share failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    final number = _waCtrl.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a WhatsApp number')),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      // 1) Record share in Firestore
      await context.read<TaskProvider>().shareTask(
        widget.task,
        'whatsapp',
        number,
      );

      // 2) Build the public edit‐URL
      final editLink = 'https://to-do-49ef2.web.app/edit/${widget.task.id}';

      // 3) Compose WhatsApp text
      final rawText = '${widget.task.title}\n\n'
          'Tap to edit your task:\n$editLink';
      final text    = Uri.encodeComponent(rawText).replaceAll('+','%20');

      // 4) Create WhatsApp URI
      final waUri = Uri(
        scheme: 'https',
        host: 'api.whatsapp.com',
        path: 'send',
        query: 'phone=${number.replaceAll('+','')}&text=$text',
      );

      // 5) Launch WhatsApp
      if (!await launchUrl(waUri, mode: LaunchMode.externalApplication)) {
        throw 'WhatsApp not installed';
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WhatsApp share failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSharing
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Send Email'),
              onPressed: _shareEmail,
            ),

            const Divider(height: 32),

            // WhatsApp
            TextField(
              controller: _waCtrl,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number',
                hintText: '+911234567890',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Send WhatsApp'),
              onPressed: _shareWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}
