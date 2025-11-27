import 'historial.dart';
import 'prediction.dart';

class HistorialList {
  final List<HistorialPrediccion> historial;

  HistorialList({required this.historial});

  factory HistorialList.fromJson(Map<String, dynamic> json) {
    var list = json['historial'] as List? ?? [];
    List<HistorialPrediccion> historial = 
        list.map((item) => HistorialPrediccion.fromJson(item)).toList();
    
    return HistorialList(historial: historial);
  }

  Map<String, dynamic> toJson() {
    return {
      'historial': historial.map((h) => h.toJson()).toList(),
    };
  }

  int get total => historial.length;
  
  int get totalMalignos => historial
      .where((h) => h.prediccion?.esMaligno ?? false)
      .length;
  
  int get totalBenignos => historial
      .where((h) => h.prediccion?.esBenigno ?? false)
      .length;

  List<HistorialPrediccion> get ordenadoPorFecha {
    var lista = List<HistorialPrediccion>.from(historial);
    lista.sort((a, b) => b.fechaPrediccion.compareTo(a.fechaPrediccion));
    return lista;
  }
  List<HistorialPrediccion> filtrarPorFechas(DateTime inicio, DateTime fin) {
    return historial.where((h) {
      return h.fechaPrediccion.isAfter(inicio) && 
             h.fechaPrediccion.isBefore(fin);
    }).toList();
  }

  @override
  String toString() => 'HistorialList(total: $total, malignos: $totalMalignos, benignos: $totalBenignos)';
}