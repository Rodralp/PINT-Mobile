import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_api.dart';
import '../services/auth_session.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0;
  bool _loading = false;

  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int _captchaA = 0;
  int _captchaB = 0;
  String? _captchaError;

  String _recoveredEmail = '';

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final rng = Random();
    _captchaA = rng.nextInt(10) + 1;
    _captchaB = rng.nextInt(10) + 1;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _captchaController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final loc = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fillEmailAndPassword)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthApi.instance.recoverPassword(email: email);
      _recoveredEmail = email;
      setState(() {
        _currentStep = 1;
        _loading = false;
      });
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final msg = e.statusCode == 404 ? loc.forgotEmailNotFound : loc.forgotPasswordError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordError)),
      );
      setState(() => _loading = false);
    }
  }

  void _verifyCaptcha() {
    final loc = AppLocalizations.of(context)!;
    final answer = int.tryParse(_captchaController.text.trim());
    if (answer == _captchaA + _captchaB) {
      setState(() {
        _captchaError = null;
        _currentStep = 2;
      });
    } else {
      setState(() {
        _captchaError = loc.forgotWrongAnswer;
        _generateCaptcha();
        _captchaController.clear();
      });
    }
  }

  Future<void> _resetPassword() async {
    final loc = AppLocalizations.of(context)!;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordTooShort)),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordMismatch)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final account = await AuthApi.instance.resetPassword(
        email: _recoveredEmail,
        newPassword: newPass,
      );

      await AuthSession.saveAccount(account);
      await AuthSession.setRememberLogin(false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordSuccess)),
      );

      Navigator.pushReplacementNamed(context, '/app');
    } on AuthApiException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordError)),
      );
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.forgotPasswordError)),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.forgotPasswordTitle,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Step indicators
              _buildStepIndicator(loc),

              const SizedBox(height: 40),

              if (_currentStep == 0) _buildStep1(loc),
              if (_currentStep == 1) _buildStep2(loc),
              if (_currentStep == 2) _buildStep3(loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(AppLocalizations loc) {
    final steps = [
      loc.emailHint,
      loc.forgotStep2Subtitle,
      loc.forgotStep3Title,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i <= _currentStep;
        final isCurrent = i == _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? Colors.blue : Colors.grey[300],
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? Colors.blue
                      : isActive
                          ? Colors.blue
                          : Colors.grey[300],
                ),
                child: Center(
                  child: isActive
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? Colors.blue : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.forgotStep1Subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: loc.emailHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    loc.continueButton,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.forgotStep2Subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                loc.forgotMathQuestion(_captchaA, _captchaB),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _captchaController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: '?',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _captchaError != null ? Colors.red : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _captchaError != null ? Colors.red : Colors.blue,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_captchaError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _captchaError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _verifyCaptcha,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              loc.continueButton,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.forgotStep3Title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              hintText: loc.forgotNewPasswordHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: loc.forgotConfirmPasswordHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    loc.continueButton,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
