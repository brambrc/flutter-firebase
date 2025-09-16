import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  Map<String, int> _todoStats = {'total': 0, 'completed': 0, 'pending': 0};
  String? _fcmToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (_currentUser != null) {
        // Load user profile from Firestore
        _userProfile = await DatabaseService.getUserProfile();
        
        // Load todo statistics
        _todoStats = await DatabaseService.getTodoStats();
        
        // Get FCM token
        _fcmToken = await NotificationService.getFCMToken();
        
        // Save user profile if it doesn't exist
        if (_userProfile == null) {
          await DatabaseService.saveUserProfile(
            name: _currentUser!.displayName ?? '',
            email: _currentUser!.email ?? '',
            photoUrl: _currentUser!.photoURL,
          );
          _userProfile = await DatabaseService.getUserProfile();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats Cards
                      _buildStatsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Account Info Section
                      _buildAccountInfoSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Firebase Features Section
                      _buildFirebaseFeaturesSection(),
                      
                      const SizedBox(height: 24),
                      
                      // App Info Section
                      _buildAppInfoSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Sign Out Button
                      _buildSignOutButton(),
                      
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFFF6B35),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
                      : null,
                  child: _currentUser?.photoURL == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: const Color(0xFFFF6B35),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // User Name
                Text(
                  _currentUser?.displayName ?? 
                  _userProfile?['name'] ?? 
                  'Pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                
                // Email
                Text(
                  _currentUser?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Todos',
            '${_todoStats['total']}',
            Icons.list_alt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Selesai',
            '${_todoStats['completed']}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '${_todoStats['pending']}',
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return _buildSection(
      title: 'Informasi Akun',
      icon: Icons.account_circle,
      children: [
        _buildInfoTile(
          'Nama',
          _currentUser?.displayName ?? _userProfile?['name'] ?? 'Tidak ada',
          Icons.person,
        ),
        _buildInfoTile(
          'Email',
          _currentUser?.email ?? 'Tidak ada',
          Icons.email,
        ),
        _buildInfoTile(
          'UID',
          _currentUser?.uid ?? 'Tidak ada',
          Icons.fingerprint,
          isMonospace: true,
        ),
        _buildInfoTile(
          'Provider',
          _getAuthProvider(),
          Icons.security,
        ),
        _buildInfoTile(
          'Bergabung Sejak',
          _formatDate(_currentUser?.metadata.creationTime),
          Icons.calendar_today,
        ),
        _buildInfoTile(
          'Login Terakhir',
          _formatDate(_currentUser?.metadata.lastSignInTime),
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildFirebaseFeaturesSection() {
    return _buildSection(
      title: 'Fitur Firebase',
      icon: Icons.local_fire_department,
      children: [
        _buildFeatureTile(
          'Authentication Status',
          _currentUser != null ? 'Terautentikasi' : 'Tidak terautentikasi',
          _currentUser != null ? Colors.green : Colors.red,
          Icons.verified_user,
        ),
        _buildFeatureTile(
          'FCM Token',
          _fcmToken != null ? 'Terdaftar' : 'Tidak terdaftar',
          _fcmToken != null ? Colors.green : Colors.orange,
          Icons.notifications,
          onTap: () => _showFCMTokenDialog(),
        ),
        _buildFeatureTile(
          'Database Access',
          'Firestore & Realtime DB',
          Colors.blue,
          Icons.storage,
        ),
        _buildFeatureTile(
          'Test Notification',
          'Kirim notifikasi test',
          const Color(0xFFFF6B35),
          Icons.send,
          onTap: () {
            NotificationService.sendTestNotification();
            NotificationService.showSuccessNotification(
              context,
              'Test notification berhasil dikirim! 🔔',
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return _buildSection(
      title: 'Tentang Aplikasi',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          'Versi',
          '1.0.0',
          Icons.settings,
        ),
        _buildInfoTile(
          'Build',
          'Flutter + Firebase',
          Icons.build,
        ),
        _buildInfoTile(
          'Tujuan',
          'Pembelajaran Firebase',
          Icons.school,
        ),
        ListTile(
          leading: const Icon(Icons.help_outline, color: Color(0xFFFF6B35)),
          title: Text(
            'Panduan Penggunaan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showHelpDialog,
        ),
        ListTile(
          leading: const Icon(Icons.refresh, color: Color(0xFFFF6B35)),
          title: Text(
            'Refresh Data',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _loadUserData,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF6B35), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon, {
    bool isMonospace = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600], size: 20),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: isMonospace 
            ? TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontFamily: 'monospace',
              )
            : GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
      ),
    );
  }

  Widget _buildFeatureTile(
    String title,
    String subtitle,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
        ),
      ),
      trailing: onTap != null 
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Keluar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getAuthProvider() {
    if (_currentUser == null) return 'Tidak ada';
    
    final providers = _currentUser!.providerData.map((p) => p.providerId).join(', ');
    return providers.isNotEmpty ? providers : 'Email/Password';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tidak ada';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showFCMTokenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'FCM Token',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firebase Cloud Messaging Token:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _fcmToken ?? 'Tidak ada token',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Token ini digunakan untuk mengirim push notifications ke perangkat ini.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Panduan Penggunaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firebase Learning App',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...{
                '🔐 Authentication': 'Login dengan email/password atau Google Sign-In',
                '📊 Database': 'Kelola todos dengan Realtime Database dan Firestore',
                '🔔 Push Notifications': 'Terima notifikasi real-time dengan FCM',
                '👤 Profile': 'Lihat informasi akun dan statistik penggunaan',
              }.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(color: Colors.grey[800]),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: entry.value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar Akun',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService.signOut();
        if (mounted) {
          // Navigate to login screen will be handled by AuthWrapper
        }
      } catch (e) {
        if (mounted) {
          NotificationService.showErrorNotification(context, e.toString());
        }
      }
    }
  }
}
