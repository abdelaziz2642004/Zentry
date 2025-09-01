import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friend_code_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class FriendCodeDisplay extends StatefulWidget {
  const FriendCodeDisplay({super.key});

  @override
  State<FriendCodeDisplay> createState() => _FriendCodeDisplayState();
}

class _FriendCodeDisplayState extends State<FriendCodeDisplay> {
  final FriendCodeService _friendCodeService = FriendCodeService();
  String? _friendCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendCode();
  }

  Future<void> _loadFriendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final code = await _friendCodeService.getOrCreateFriendCode();
      setState(() {
        _friendCode = code;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading friend code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyFriendCode() {
    if (_friendCode != null) {
      Clipboard.setData(ClipboardData(text: _friendCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend code copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin, color: mainColor),
                SizedBox(width: 8),
                Text(
                  'Friend Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_friendCode != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: mainColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _friendCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copyFriendCode,
                          icon: const Icon(Icons.copy, color: mainColor),
                          tooltip: 'Copy friend code',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this code with friends to add them',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            else
              const Text('Error loading friend code'),
          ],
        ),
      ),
    );
  }
}
