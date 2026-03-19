import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ─── Step 1: Enter email ──────────────────────────────────────────────────────
class AuthEmailScreen extends StatefulWidget {
  final bool isSignUp;
  final void Function(String email) onOtpSent;
  final VoidCallback onBack;

  const AuthEmailScreen({
    super.key,
    required this.isSignUp,
    required this.onOtpSent,
    required this.onBack,
  });

  @override
  State<AuthEmailScreen> createState() => _AuthEmailScreenState();
}

class _AuthEmailScreenState extends State<AuthEmailScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    // Replace with actual Supabase OTP call:
    // await Supabase.instance.client.auth.signInWithOtp(email: email);
    await Future.delayed(const Duration(seconds: 1)); // mock delay

    setState(() => _loading = false);
    widget.onOtpSent(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: widget.onBack,
                  ),
                  const Spacer(),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rall',
                          style: TextStyle(
                            fontFamily: 'InstrumentSerif',
                            fontSize: 22,
                            color: RallyColors.accent,
                          ),
                        ),
                        TextSpan(
                          text: 'l',
                          style: TextStyle(
                            fontFamily: 'InstrumentSerif',
                            fontSize: 22,
                            color: RallyColors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: 'y',
                          style: TextStyle(
                            fontFamily: 'InstrumentSerif',
                            fontSize: 22,
                            color: RallyColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      widget.isSignUp ? 'Create account' : 'Welcome back',
                      style: const TextStyle(
                        fontFamily: 'InstrumentSerif',
                        fontSize: 36,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.15, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      widget.isSignUp
                          ? "Enter your email and we'll send a one-time code"
                          : "We'll send a sign-in code to your email",
                      style: const TextStyle(
                        color: RallyColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 36),

                    // Email field
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'EMAIL ADDRESS',
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 18),
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: RallyColors.accent2,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    RallyButton(
                      label: 'Send code',
                      onPressed: _loading ? null : _submit,
                      loading: _loading,
                      icon: Icons.send_outlined,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 32),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: const TextStyle(
                              color: RallyColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onBack,
                            child: Text(
                              widget.isSignUp ? 'Sign in' : 'Sign up',
                              style: const TextStyle(
                                color: RallyColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: OTP verification ────────────────────────────────────────────────
class AuthOtpScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const AuthOtpScreen({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen>
    with SingleTickerProviderStateMixin {
  static const _codeLength = 6;
  final _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  bool _loading = false;
  bool _shake = false;
  int _resendTimer = 30;
  bool _canResend = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) _canResend = true;
      });
      return _resendTimer > 0;
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_code.length == _codeLength) _verify();
  }

  Future<void> _verify() async {
    if (_loading) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo: code 123456 always works
    // Real: await Supabase.instance.client.auth.verifyOTP(
    //   email: widget.email, token: _code, type: OtpType.email);

    if (_code == '123456') {
      widget.onVerified();
    } else {
      _shakeCtrl.forward(from: 0);
      for (final c in _controllers) c.clear();
      _focusNodes.first.requestFocus();
      setState(() { _loading = false; _shake = true; });
      Future.delayed(600.ms, () => setState(() => _shake = false));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: widget.onBack,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              const Text(
                'Check your email',
                style: TextStyle(
                  fontFamily: 'InstrumentSerif',
                  fontSize: 36,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: RallyColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: RallyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP digit inputs
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  final shake = _shake
                      ? 8 * (0.5 - (_shakeAnim.value - 0.5).abs())
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(shake * 6, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_codeLength, (i) {
                    return SizedBox(
                      width: 48,
                      height: 60,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'InstrumentSerif',
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _shake
                              ? RallyColors.accent2Light
                              : RallyColors.white,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _shake
                                  ? RallyColors.accent2
                                  : RallyColors.border2,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _shake
                                  ? RallyColors.accent2
                                  : RallyColors.border2,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) => _onDigitChanged(i, v),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),
              RallyButton(
                label: 'Verify',
                onPressed: _code.length == _codeLength ? _verify : null,
                loading: _loading,
              ),

              const SizedBox(height: 20),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _resendTimer = 30;
                            _canResend = false;
                          });
                          _startResendTimer();
                        },
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            color: RallyColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        'Resend in ${_resendTimer}s',
                        style: const TextStyle(
                          color: RallyColors.muted,
                          fontSize: 13,
                        ),
                      ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: RallyColors.surface2,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: RallyColors.border2),
                  ),
                  child: const Text(
                    '💡 Demo: use code 123456',
                    style: TextStyle(
                      fontSize: 12,
                      color: RallyColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
