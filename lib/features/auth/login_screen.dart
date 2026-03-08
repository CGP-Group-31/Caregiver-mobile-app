import 'package:caregiver/features/dashboard/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';
import '../dashboard/dashboard_screen.dart';
import 'register_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllersf
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool _obscure = true;

  // Palette colors
  static const Color _teal = Color(0xFF2E7D7A);
  static const Color _mint1 = Color(0xFFD6EFE6);
  static const Color _mint2 = Color(0xFFBEE8DA);
  static const Color _offWhite = Color(0xFFF6F7F3);

  static const Color _dark = Color(0xFF243333);
  static const Color _gray = Color(0xFF6F7F7D);
  static const Color _gold = Color(0xFFE6B566);

  static const Color _red = Color(0xFFC62828);
  static const Color _pink = Color(0xFFFBDADA);

  Future<void> login() async {
    // Validate form first
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => loading = true);

    try {
      final data = await AuthService.loginCaregiver(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      await SessionManager.saveUser(data["user_id"]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError("Invalid email or password");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _dark,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // soft background blobs
            Positioned(
              top: -120,
              left: -90,
              child: _SoftBlob(size: 260, color: _mint2.withOpacity(0.65)),
            ),
            Positioned(
              bottom: -140,
              right: -120,
              child: _SoftBlob(size: 320, color: _mint1.withOpacity(0.75)),
            ),

            // content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // top header row with back button
                      Row(
                        children: [
                          _BackPill(
                            onTap: () => Navigator.pop(context),
                            bg: _mint1,
                            iconColor: _teal,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _dark,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // main card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.86),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _mint2, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: _dark.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // small badge
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _gold.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: _gold.withOpacity(0.55), width: 1),
                                  ),
                                  child: const Text(
                                    "TrustCare",
                                    style: TextStyle(
                                      color: _dark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              const Text(
                                "Welcome back 👋",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: _dark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Log in to continue managing reminders and safety features.",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: _gray,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Email field
                              _LabeledField(
                                label: "Email",
                                child: TextFormField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(color: _dark, fontWeight: FontWeight.w600),
                                  decoration: _inputDecoration(
                                    hint: "name@example.com",
                                    prefix: Icons.email_rounded,
                                  ),
                                  validator: (v) {
                                    final value = (v ?? "").trim();
                                    if (value.isEmpty) return "Email is required";
                                    // simple email check
                                    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                                    if (!emailOk) return "Enter a valid email";
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Password field
                              _LabeledField(
                                label: "Password",
                                child: TextFormField(
                                  controller: passCtrl,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => loading ? null : login(),
                                  style: const TextStyle(color: _dark, fontWeight: FontWeight.w600),
                                  decoration: _inputDecoration(
                                    hint: "••••••••",
                                    prefix: Icons.lock_rounded,
                                    suffix: IconButton(
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                        color: _gray,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    final value = v ?? "";
                                    if (value.isEmpty) return "Password is required";
                                    if (value.length < 6) return "Password must be at least 6 characters";
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Inline error hint box (optional nice touch)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _pink.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _red.withOpacity(0.25)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: _red, size: 18),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Make sure your email and password are correct.",
                                        style: TextStyle(
                                          color: _dark,
                                          fontSize: 12.5,
                                          height: 1.3,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Login button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: loading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _teal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Create account row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don’t have an account?",
                                    style: TextStyle(color: _gray, fontWeight: FontWeight.w600),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: _teal,
                                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                    child: const Text("Create account"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Secure login • Elder care system",
                        style: TextStyle(
                          color: _gray.withOpacity(0.95),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
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
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _gray.withOpacity(0.8), fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _mint1.withOpacity(0.55),
      prefixIcon: Icon(prefix, color: _teal),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _mint2, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _teal.withOpacity(0.9), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _red.withOpacity(0.8), width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _red.withOpacity(0.9), width: 1.6),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  static const Color _dark = Color(0xFF243333);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _dark,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  final Color bg;
  final Color iconColor;

  const _BackPill({
    required this.onTap,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg.withOpacity(0.75),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Icon(Icons.arrow_back_rounded),
        ),
      ),
    ).applyIconTheme(iconColor);
  }
}

extension on Widget {
  Widget applyIconTheme(Color color) {
    return IconTheme(data: IconThemeData(color: color), child: this);
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2.2),
      ),
    );
  }
}
