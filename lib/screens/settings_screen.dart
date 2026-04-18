import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'scan_logs_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _gpsEnabled = true;
  bool _soundEnabled = true;
  String _language = 'Espanol';
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = PreferencesService.instance;
    final sound = await prefs.soundEnabled;
    final gps = await prefs.gpsEnabled;
    if (!mounted) return;
    setState(() {
      _soundEnabled = sound;
      _gpsEnabled = gps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 60),
          children: [
            Row(
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
                const SizedBox(width: 12),
                Text(
                  'Ajustes',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Preferencias',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),
            _sectionTitle('Apariencia'),
            _settingsTile(
              context,
              icon: Icons.dark_mode_outlined,
              label: 'Modo oscuro',
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeThumbColor: AppTheme.primaryContainer,
              ),
            ),
            _settingsTile(
              context,
              icon: Icons.language_rounded,
              label: 'Idioma',
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(),
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600),
                items: ['Espanol', 'English'].map((l) {
                  return DropdownMenuItem(value: l, child: Text(l));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _language = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Idioma cambiado a $value'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Notificaciones'),
            _settingsTile(
              context,
              icon: Icons.notifications_outlined,
              label: 'Notificaciones push',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
                activeThumbColor: AppTheme.primaryContainer,
              ),
            ),
            _settingsTile(
              context,
              icon: Icons.volume_up_outlined,
              label: 'Sonidos',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  PreferencesService.instance.setSoundEnabled(value);
                },
                activeThumbColor: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Privacidad'),
            _settingsTile(
              context,
              icon: Icons.location_on_outlined,
              label: 'Compartir ubicacion GPS',
              trailing: Switch(
                value: _gpsEnabled,
                onChanged: (value) {
                  setState(() => _gpsEnabled = value);
                  PreferencesService.instance.setGpsEnabled(value);
                },
                activeThumbColor: AppTheme.primaryContainer,
              ),
            ),
            _settingsTile(
              context,
              icon: Icons.visibility_outlined,
              label: 'Perfil visible',
              onTap: () => _infoDialog(
                context,
                'Visibilidad del perfil',
                'Aqui se configurara la visibilidad del perfil para otros usuarios. Funcionalidad pendiente.',
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Cuenta'),
            _settingsTile(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Editar perfil',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
                if (updated == true) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Perfil actualizado'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  );
                }
              },
            ),
            _settingsTile(
              context,
              icon: Icons.lock_outline_rounded,
              label: 'Cambiar contrasena',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              ),
            ),
            _settingsTile(
              context,
              icon: Icons.document_scanner_outlined,
              label: 'Scan Logs',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanLogsScreen(),
                ),
              ),
            ),
            _settingsTile(
              context,
              icon: Icons.logout_rounded,
              label: 'Cerrar sesion',
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    title: Text('Cerrar sesion',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                    content: Text(
                      'Seguro que quieres cerrar sesion?',
                      style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancelar',
                            style: GoogleFonts.inter(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await AuthService.instance.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        },
                        child: Text('Cerrar sesion',
                            style: GoogleFonts.inter(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                );
              },
            ),
            _settingsTile(
              context,
              icon: Icons.delete_outline_rounded,
              label: 'Eliminar cuenta',
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    title: Text('Eliminar cuenta',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                    content: Text(
                      'Se eliminara la cuenta de forma permanente. Esta accion no se puede deshacer. Funcionalidad pendiente.',
                      style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar',
                            style: GoogleFonts.inter(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Eliminar',
                            style: GoogleFonts.inter(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Informacion'),
            _settingsTile(
              context,
              icon: Icons.info_outline_rounded,
              label: 'Acerca de BadgeUp',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'BadgeUp',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Colecciona stickers de carros en el mundo real.',
                );
              },
            ),
            _settingsTile(
              context,
              icon: Icons.description_outlined,
              label: 'Terminos y condiciones',
              onTap: () => _infoDialog(
                context,
                'Terminos y condiciones',
                'Se mostraran los terminos y condiciones del servicio. Funcionalidad pendiente.',
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'BadgeUp v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _infoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(body,
            style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.onSurfaceVariant,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.error : AppTheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.pastelPeach
                    : AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? AppTheme.onPastelPeach : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
