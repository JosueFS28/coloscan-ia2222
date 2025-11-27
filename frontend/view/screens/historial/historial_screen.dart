import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/historial_controller.dart';
import '../../../models/historial.dart';
import '../../widgets/bottom_nav.dart';
import '../home/principal_screen.dart';
import '../info/informacion_screen.dart';
import '../profile/perfiles_screen.dart';
import 'detalle_historial_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  int _currentIndex = 1;
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
    // Cargar historial al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialController>().loadHistorial();
    });
  }

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
        screen = const HistorialScreen();
    }

    if (index != 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Análisis"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PrincipalScreen()),
            );
          },
        ),
        actions: [
          // Botón refrescar
          Consumer<HistorialController>(
            builder: (context, controller, child) {
              return IconButton(
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: controller.isLoading
                    ? null
                    : () => controller.refresh(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          _buildStatsCard(),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar por diagnóstico o fecha",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
            ),
          ),

          // Lista de historial
          Expanded(
            child: Consumer<HistorialController>(
              builder: (context, controller, child) {
                // Loading
                if (controller.isLoading && controller.historial.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (controller.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.loadHistorial(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Sin datos
                if (controller.historial.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No hay análisis en el historial',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Realiza tu primer análisis',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar resultados
                final filtered = controller.historialOrdenado.where((h) {
                  final prediccion = h.prediccion;
                  if (prediccion == null) return false;

                  final matchDiagnosis = prediccion.resultado
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase());
                  final matchDate = _formatDate(h.fechaPrediccion)
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase());

                  return matchDiagnosis || matchDate;
                }).toList();

                // Sin resultados de búsqueda
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Lista de resultados
                return RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final historial = filtered[index];
                      return _buildHistorialCard(historial);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<HistorialController>(
      builder: (context, controller, child) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEBF4FF), Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.analytics,
                label: 'Total',
                value: controller.total.toString(),
                color: Colors.blue,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.blue.shade200,
              ),
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Benignos',
                value: controller.totalBenignos.toString(),
                color: Colors.green,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.blue.shade200,
              ),
              _buildStatItem(
                icon: Icons.warning,
                label: 'Malignos',
                value: controller.totalMalignos.toString(),
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialCard(HistorialPrediccion historial) {
    final prediccion = historial.prediccion;
    if (prediccion == null) return const SizedBox.shrink();

    final isMaligno = prediccion.esMaligno;
    final color = isMaligno ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetalleHistorialScreen(
                historial: historial,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono de estado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMaligno ? Icons.warning : Icons.check_circle,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediccion.resultado,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confianza: ${prediccion.confianzaPorcentaje}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(historial.fechaPrediccion),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}