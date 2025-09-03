import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friend_code_service.dart';

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
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Friend code copied!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2CACAD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beautiful header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2CACAD).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2CACAD).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                color: Color(0xFF2CACAD),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Friend Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD9F5F0),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Content area
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                color: Color(0xFF2CACAD),
                strokeWidth: 3,
              ),
            ),
          )
        else if (_friendCode != null)
          Column(
            children: [
              // Friend code display container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2CACAD).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2CACAD).withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Friend code text
                    Text(
                      _friendCode!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                        color: Color(0xFF2CACAD),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Copy button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _copyFriendCode,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2CACAD).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2CACAD).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                color: Color(0xFF2CACAD),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Copy Code',
                                style: TextStyle(
                                  color: Color(0xFF2CACAD),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Helper text
              Text(
                'Share this code with friends to connect with them',
                style: TextStyle(
                  color: const Color(0xFFD9F5F0).withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: const Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                SizedBox(height: 12),
                Text(
                  'Error loading friend code',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
