import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('Apariencia'),
          _settingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            label: 'Modo oscuro',
            trailing: Switch(
              value: themeProvider.isDark,
              onChanged: (value) => themeProvider.toggleTheme(value),
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.language,
            label: 'Idioma',
            trailing: DropdownButton<String>(
              value: _language,
              underline: const SizedBox(),
              items: ['Espanol', 'English'].map((l) {
                return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Idioma cambiado a $value'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.volume_up_outlined,
            label: 'Sonidos',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
              activeThumbColor: AppTheme.primaryBlue,
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
              onChanged: (value) => setState(() => _gpsEnabled = value),
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.visibility_outlined,
            label: 'Perfil visible',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Visibilidad del perfil'),
                  content: const Text(
                    'Aqui se configurara la visibilidad del perfil para otros usuarios. Funcionalidad pendiente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('Cuenta'),
          _settingsTile(
            context,
            icon: Icons.person_outline,
            label: 'Editar perfil',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Editar perfil'),
                  content: const Text(
                    'Se abrira el editor de perfil para cambiar nombre, foto y biografia. Funcionalidad pendiente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
          _settingsTile(
            context,
            icon: Icons.lock_outline,
            label: 'Cambiar contrasena',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Cambiar contrasena'),
                  content: const Text(
                    'Se abrira el formulario para cambiar la contrasena. Funcionalidad pendiente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
          _settingsTile(
            context,
            icon: Icons.delete_outline,
            label: 'Eliminar cuenta',
            isDestructive: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Eliminar cuenta'),
                  content: const Text(
                    'Se eliminara la cuenta de forma permanente. Esta accion no se puede deshacer. Funcionalidad pendiente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
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
            icon: Icons.info_outline,
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
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Terminos y condiciones'),
                  content: const Text(
                    'Se mostraran los terminos y condiciones del servicio. Funcionalidad pendiente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'BadgeUp v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 0.5,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppTheme.errorRed : AppTheme.primaryBlue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? AppTheme.errorRed : null,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
