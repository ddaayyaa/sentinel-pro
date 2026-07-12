import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUser = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  final LocalAuthentication _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();
  }

  void _showNetworkDialog() {
    final api = context.read<ApiService>();
    final controller = TextEditingController(text: api.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Diagnostic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Consumer<AuthProvider>(builder: (context, auth, _) => Text(auth.isServerOnline ? 'CONNECTED' : 'UNREACHABLE', style: TextStyle(color: auth.isServerOnline ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            const Text('Troubleshooting:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Text('1. Ensure Phone & PC are on SAME Wi-Fi.', style: TextStyle(fontSize: 11)),
            const Text('2. Disable Firewall on PC port 5000.', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Update API Address', 
                hintText: 'http://192.168.x.x:5000',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await api.updateBaseUrl(controller.text.trim());
              if (mounted) {
                Navigator.pop(context);
                _checkServer();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text('Save & Reconnect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSavedCredentials() async {
    // Feature disabled by request to prevent pre-filling admin credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    await _storage.delete(key: 'saved_email');
    await _storage.delete(key: 'saved_password');
    
    if (mounted) {
      setState(() {
        _rememberMe = false;
        _emailController.clear();
        _passwordController.clear();
      });
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    // Feature disabled by request
    return;
  }

  Future<void> _handleBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not available')));
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to sign in to Sentinel Pro',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true));

      if (didAuthenticate) {
        final email = await _storage.read(key: 'saved_email');
        final pass = await _storage.read(key: 'saved_password');
        if (email != null && pass != null) {
          _emailController.text = email;
          _passwordController.text = pass;
          _handleLogin();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No saved credentials for biometric login')));
        }
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
    }
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all credentials')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(email, password);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        await _saveCredentials(email, password);
        if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/user-dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Login Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<AuthProvider>(
          builder: (context, auth, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: auth.isServerOnline ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(color: (auth.isServerOnline ? Colors.green : Colors.red).withOpacity(0.4), blurRadius: 4, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                auth.isServerOnline ? 'SERVER ONLINE' : 'SERVER OFFLINE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: auth.isServerOnline ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_suggest, color: AppTheme.primaryPurple),
            onPressed: _showNetworkDialog,
            tooltip: 'Server Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.shield_outlined, size: 64, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sentinel Pro Login',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure Access Management System',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),
              const SizedBox(height: 40),
              Container(
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isUser = true),
                        child: Container(
                          decoration: BoxDecoration(color: isUser ? AppTheme.primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text('USER PORTAL', style: TextStyle(color: isUser ? Colors.white : AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isUser = false),
                        child: Container(
                          decoration: BoxDecoration(color: !isUser ? AppTheme.primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text('ADMIN CORE', style: TextStyle(color: !isUser ? Colors.white : AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Identity Identifier', style: TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Username or Email',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Security Code', style: TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          activeColor: AppTheme.primaryPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember ID', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                    },
                    child: const Text('Forgot Credentials?', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('AUTHORIZE ACCESS'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint, color: AppTheme.primaryPurple, size: 32),
                      onPressed: _handleBiometric,
                      tooltip: 'Biometric Login',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New Operator? ", style: TextStyle(color: AppTheme.textLight)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text('Register Here', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
