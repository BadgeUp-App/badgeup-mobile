import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Ingresa tu correo electronico.', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final msg = await AuthService.instance.requestPasswordReset(email);
      if (!mounted) return;
      _showSnack(msg);
      setState(() => _codeSent = true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Error de conexion.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (code.isEmpty || password.isEmpty) {
      _showSnack('Completa todos los campos.', isError: true);
      return;
    }
    if (password != confirm) {
      _showSnack('Las contrasenas no coinciden.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnack('La contrasena debe tener al menos 6 caracteres.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final msg = await AuthService.instance.confirmPasswordReset(
        email: _emailController.text.trim(),
        code: code,
        newPassword: password,
      );
      if (!mounted) return;
      _showSnack(msg);
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Error de conexion.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppTheme.error : AppTheme.primary,
          content: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.subtleLift,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppTheme.onSurface),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recuperar contrasena',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'Ingresa el codigo que recibiste y tu nueva contrasena.'
                    : 'Ingresa tu correo y te enviaremos un codigo de verificacion.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (!_codeSent) ...[
                _buildLabel('CORREO ELECTRONICO'),
                _buildInput(
                  controller: _emailController,
                  hint: 'tu@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 28),
                _buildGradientButton(
                  label: 'Enviar codigo',
                  onPressed: _loading ? null : _sendCode,
                ),
              ] else ...[
                _buildLabel('CODIGO DE VERIFICACION'),
                _buildInput(
                  controller: _codeController,
                  hint: '123456',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildLabel('NUEVA CONTRASENA'),
                _buildInput(
                  controller: _passwordController,
                  hint: '........',
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppTheme.outline,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('CONFIRMAR CONTRASENA'),
                _buildInput(
                  controller: _confirmController,
                  hint: '........',
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppTheme.outline,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 28),
                _buildGradientButton(
                  label: 'Cambiar contrasena',
                  onPressed: _loading ? null : _resetPassword,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _codeSent = false),
                    child: Text(
                      'Reenviar codigo',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurfaceVariant,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
