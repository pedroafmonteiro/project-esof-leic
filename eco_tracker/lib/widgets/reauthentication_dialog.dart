import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

class ReauthenticationDialog extends StatefulWidget {
  final bool isGoogleSignIn;

  const ReauthenticationDialog({
    super.key,
    required this.isGoogleSignIn,
  });

  @override
  State<ReauthenticationDialog> createState() => _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<ReauthenticationDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verification Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'For security reasons, please verify your identity before deleting your account.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (widget.isGoogleSignIn)
            _buildGoogleSignInPrompt()
          else
            _buildPasswordPrompt(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL'),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          TextButton(
            onPressed: _handleReauthentication,
            child: const Text('CONTINUE'),
          ),
      ],
    );
  }

  Widget _buildPasswordPrompt() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      autofocus: true,
    );
  }

  Widget _buildGoogleSignInPrompt() {
    return const Text(
      'You\'ll need to sign in with Google again to verify your identity.',
      style: TextStyle(fontSize: 14),
    );
  }

  Future<void> _handleReauthentication() async {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success;

      if (widget.isGoogleSignIn) {
        success = await authService.reauthenticateWithGoogle();
      } else {
        if (_passwordController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter your password';
            _isLoading = false;
          });
          return;
        }
        success = await authService
            .reauthenticateWithPassword(_passwordController.text);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = 'Verification failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}

Future<bool> showReauthenticationDialog(
  BuildContext context,
  bool isGoogleUser,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ReauthenticationDialog(isGoogleSignIn: isGoogleUser),
  );

  return result ?? false;
}
