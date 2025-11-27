import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/auth_controller.dart';
import '../home/principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regLastNameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regConfirmController = TextEditingController();
  final TextEditingController regPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    regNameController.dispose();
    regLastNameController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    regConfirmController.dispose();
    regPhoneController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    // Validaciones básicas
    if (loginEmailController.text.isEmpty || 
        loginPasswordController.text.isEmpty) {
      _showErrorSnackBar('Por favor completa todos los campos');
      return;
    }

    final authController = context.read<AuthController>();

    bool success = await authController.login(
      loginEmailController.text.trim(),
      loginPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navegar a inicio
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PrincipalScreen()),
      );
    } else {
      _showErrorSnackBar(
        authController.errorMessage ?? 'Error al iniciar sesión'
      );
    }
  }

  Future<void> handleRegister() async {
    // Validaciones
    if (regNameController.text.isEmpty ||
        regLastNameController.text.isEmpty ||
        regEmailController.text.isEmpty ||
        regPasswordController.text.isEmpty) {
      _showErrorSnackBar('Por favor completa todos los campos');
      return;
    }

    if (!regEmailController.text.contains('@')) {
      _showErrorSnackBar('Ingresa un correo válido');
      return;
    }

    if (regPasswordController.text.length < 6) {
      _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (regPasswordController.text != regConfirmController.text) {
      _showErrorSnackBar('Las contraseñas no coinciden');
      return;
    }

    final authController = context.read<AuthController>();

    bool success = await authController.register(
      nombres: regNameController.text.trim(),
      apellidos: regLastNameController.text.trim(),
      correo: regEmailController.text.trim(),
      password: regPasswordController.text,
      telefono: regPhoneController.text.isNotEmpty 
          ? regPhoneController.text.trim() 
          : null,
    );

    if (!mounted) return;

    if (success) {
      // Navegar a inicio
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PrincipalScreen()),
      );
    } else {
      _showErrorSnackBar(
        authController.errorMessage ?? 'Error al crear cuenta'
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF4FF), Color(0xFFEDE9FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.blue),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Acceso",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card principal
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Logo/Título
                            const Icon(
                              Icons.biotech,
                              size: 60,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "ColoScan IA",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Inicia sesión o crea una cuenta para continuar",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 16),

                            // Tabs
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.blue,
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.black54,
                              tabs: const [
                                Tab(text: "Iniciar Sesión"),
                                Tab(text: "Registrarse"),
                              ],
                            ),

                            // TabBar Views
                            SizedBox(
                              height: 450,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // ==================== TAB LOGIN ====================
                                  _buildLoginTab(),

                                  // ==================== TAB REGISTRO ====================
                                  _buildRegisterTab(),
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
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGIN TAB ====================
  Widget _buildLoginTab() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              TextField(
                controller: loginEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: loginPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authController.isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.blue.shade300,
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Iniciar Sesión",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== REGISTRO TAB ====================
  Widget _buildRegisterTab() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              TextField(
                controller: regNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Nombres",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regLastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Apellidos",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Teléfono (opcional)",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  helperText: 'Mínimo 6 caracteres',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirmar Contraseña",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authController.isLoading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.purple,
                  disabledBackgroundColor: Colors.purple.shade300,
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Crear Cuenta",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}