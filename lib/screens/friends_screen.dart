import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/friend_request.dart';
import '../services/social_api.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  late Future<List<Member>> _membersFuture;
  late Future<List<FriendRequestModel>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _membersFuture = SocialApi.instance.fetchMembers();
    _requestsFuture = SocialApi.instance.fetchFriendRequests(scope: 'received');
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _membersFuture = SocialApi.instance.fetchMembers();
      _requestsFuture =
          SocialApi.instance.fetchFriendRequests(scope: 'received');
    });
  }

  List<Member> _filter(List<Member> list) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((m) =>
            m.displayName.toLowerCase().contains(q) ||
            m.email.toLowerCase().contains(q) ||
            m.username.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _sendRequest(Member m) async {
    try {
      await SocialApi.instance.sendFriendRequest(m.id);
      _snack('Solicitud enviada a ${m.displayName}');
      await _reload();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _acceptRequest(FriendRequestModel r) async {
    try {
      await SocialApi.instance.acceptFriendRequest(r.id);
      _snack('Solicitud aceptada');
      await _reload();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _rejectRequest(FriendRequestModel r) async {
    try {
      await SocialApi.instance.rejectFriendRequest(r.id);
      _snack('Solicitud rechazada');
      await _reload();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _removeFriend(Member m) async {
    final requestId = m.friendRequestId;
    if (requestId == null) return;
    try {
      await SocialApi.instance.removeFriend(requestId);
      _snack('${m.displayName} eliminado de amigos');
      await _reload();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _openChat(Member m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(otherUserId: m.id, otherName: m.displayName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
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
                    'Comunidad',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.onSurface,
                  unselectedLabelColor: AppTheme.onSurfaceVariant,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: AppTheme.subtleLift,
                  ),
                  tabs: const [
                    Tab(text: 'Comunidad'),
                    Tab(text: 'Amigos'),
                    Tab(text: 'Solicitudes'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o correo',
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 20, color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersList(onlyFriends: false),
                  _buildMembersList(onlyFriends: true),
                  _buildRequestsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList({required bool onlyFriends}) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No se pudo cargar.',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.onSurfaceVariant),
                ),
                TextButton(
                    onPressed: _reload, child: const Text('Reintentar')),
              ],
            ),
          );
        }
        var list = snapshot.data ?? const <Member>[];
        if (onlyFriends) {
          list = list.where((m) => m.isFriend).toList();
        }
        list = _filter(list);
        if (list.isEmpty) {
          return Center(
            child: Text(
              onlyFriends
                  ? 'Aun no tienes amigos agregados.'
                  : 'No hay resultados.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.onSurfaceVariant),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final m = list[index];
              return _memberTile(m);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    return FutureBuilder<List<FriendRequestModel>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('No se pudo cargar solicitudes.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.onSurfaceVariant)),
          );
        }
        final list = snapshot.data ?? const <FriendRequestModel>[];
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceContainerLow,
                  ),
                  child: Icon(Icons.mail_outline_rounded,
                      size: 32, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text('No tienes solicitudes pendientes',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
            itemCount: list.length,
            itemBuilder: (_, i) => _requestTile(list[i]),
          ),
        );
      },
    );
  }

  Widget _memberTile(Member m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _avatar(m.displayName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${m.points} puntos',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (m.isFriend) ...[
            _pillButton('Chat', () => _openChat(m), accent: false),
            const SizedBox(width: 6),
            _pillButton('Quitar', () => _removeFriend(m), accent: true),
          ] else ...[
            _pillButton('Agregar', () => _sendRequest(m), accent: true),
          ],
        ],
      ),
    );
  }

  Widget _requestTile(FriendRequestModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _avatar(r.fromUser.displayName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.fromUser.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quiere ser tu amigo',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          _pillButton('Rechazar', () => _rejectRequest(r), accent: false),
          const SizedBox(width: 6),
          _pillButton('Aceptar', () => _acceptRequest(r), accent: true),
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.secondaryContainer, AppTheme.pastelPeach],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _pillButton(String label, VoidCallback onTap, {required bool accent}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accent ? AppTheme.pastelPeach : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: accent ? AppTheme.onPastelPeach : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
