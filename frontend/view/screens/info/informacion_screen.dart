import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/bottom_nav.dart';
import '../home/principal_screen.dart';
import '../historial/historial_screen.dart';
import '../profile/perfiles_screen.dart';

class InformacionScreen extends StatefulWidget {
  const InformacionScreen({super.key});

  @override
  State<InformacionScreen> createState() => _InformacionScreenState();
}

class _InformacionScreenState extends State<InformacionScreen> {
  int _currentIndex = 2;

  static const List<Map<String, String>> symptoms = [
    {
      "title": "Sangrado rectal",
      "description": "Presencia de sangre en las heces o en el papel higiénico",
    },
    {
      "title": "Dolor abdominal",
      "description": "Molestias o calambres persistentes en el abdomen",
    },
    {
      "title": "Pérdida de peso inexplicada",
      "description": "Disminución de peso sin causa aparente",
    },
    {
      "title": "Cambios en los hábitos intestinales",
      "description": "Diarrea, estreñimiento o cambios en la consistencia de las heces",
    },
    {
      "title": "Fatiga constante",
      "description": "Cansancio persistente sin razón aparente",
    },
  ];

  static const List<Map<String, String>> riskFactors = [
    {
      "title": "Edad mayor a 50 años",
      "description": "El riesgo aumenta significativamente después de los 50",
    },
    {
      "title": "Antecedentes familiares",
      "description": "Historial de cáncer de colon en familiares directos",
    },
    {
      "title": "Dieta rica en grasas y baja en fibra",
      "description": "Alimentación inadecuada puede aumentar el riesgo",
    },
    {
      "title": "Tabaquismo y alcohol",
      "description": "El consumo de tabaco y alcohol incrementa el riesgo",
    },
    {
      "title": "Sedentarismo",
      "description": "Falta de actividad física regular",
    },
  ];

  static const List<Map<String, String>> resources = [
    {
      "title": "Organización Mundial de la Salud",
      "url": "https://www.who.int/es",
      "description": "Información global sobre salud y enfermedades",
    },
    {
      "title": "Instituto Nacional del Cáncer (EE.UU.)",
      "url": "https://www.cancer.gov/espanol",
      "description": "Recursos sobre prevención y tratamiento del cáncer",
    },
    {
      "title": "Sociedad Americana Contra el Cáncer",
      "url": "https://www.cancer.org/es",
      "description": "Información sobre detección temprana y tratamiento",
    },
  ];

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);

    Widget screen;
    switch (index) {
      case 0:
        screen = const PrincipalScreen();
        break;
      case 1:
        screen = const HistorialScreen();
        break;
      case 2:
        screen = const InformacionScreen();
        break;
      case 3:
        screen = const PerfilesScreen();
        break;
      default:
        screen = const InformacionScreen();
    }

    if (index != 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Información sobre Cáncer de Colon"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PrincipalScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introducción
            _buildIntroCard(),
            const SizedBox(height: 20),

            // Síntomas
            _buildSectionTitle("Síntomas Comunes", Icons.warning),
            const SizedBox(height: 12),
            ...symptoms.map((s) => _buildSymptomCard(s)),
            const SizedBox(height: 20),

            // Factores de Riesgo
            _buildSectionTitle("Factores de Riesgo", Icons.error_outline),
            const SizedBox(height: 12),
            ...riskFactors.map((r) => _buildRiskCard(r)),
            const SizedBox(height: 20),

            // Prevención
            _buildPreventionCard(),
            const SizedBox(height: 20),

            // Recursos
            _buildSectionTitle("Recursos Útiles", Icons.link),
            const SizedBox(height: 12),
            ...resources.map((res) => _buildResourceCard(res)),
            const SizedBox(height: 20),

            // Disclaimer
            _buildDisclaimerCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBF4FF), Color(0xFFEDE9FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 32),
                SizedBox(width: 12),
                Text(
                  "Sobre el Cáncer de Colon",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "El cáncer de colon es una enfermedad que se desarrolla en el intestino grueso. "
              "La detección temprana es clave para un tratamiento exitoso.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCard(Map<String, String> symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning, color: Colors.red),
        ),
        title: Text(
          symptom["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(symptom["description"]!),
      ),
    );
  }

  Widget _buildRiskCard(Map<String, String> risk) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.error_outline, color: Colors.orange),
        ),
        title: Text(
          risk["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(risk["description"]!),
      ),
    );
  }

  Widget _buildPreventionCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text(
                  "Prevención",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPreventionItem("Mantén una dieta rica en fibra y baja en grasas"),
            _buildPreventionItem("Realiza actividad física regularmente"),
            _buildPreventionItem("Evita el consumo de tabaco y alcohol"),
            _buildPreventionItem("Realiza chequeos médicos periódicos después de los 50"),
            _buildPreventionItem("Mantén un peso saludable"),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Map<String, String> resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.link, color: Colors.blue),
        ),
        title: Text(
          resource["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(resource["description"]!),
            const SizedBox(height: 4),
            Text(
              resource["url"]!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.open_in_new, color: Colors.blue),
        onTap: () => _launchUrl(resource["url"]!),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade300),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Importante",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Esta información es solo educativa. Siempre consulta con un "
                    "profesional médico para diagnóstico y tratamiento adecuado.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}