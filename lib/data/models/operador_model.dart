class OperadorModel {
  final String id;
  final String? idVehiculo;
  final String nombre;
  final String? licencia;
  final double? calificacion;
  final String estado;

  OperadorModel({
    required this.id,
    this.idVehiculo,
    required this.nombre,
    this.licencia,
    this.calificacion,
    required this.estado,
  });

  // Para recibir datos de Supabase
  factory OperadorModel.fromJson(Map<String, dynamic> json) {
    return OperadorModel(
      id: json['id_operador'],
      idVehiculo: json['id_vehiculo'],
      nombre: json['nombre'],
      licencia: json['licencia_de_conducir'],
      calificacion: json['calificacion']?.toDouble(),
      estado: json['estado'],
    );
  }

  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_operador': id,
      'id_vehiculo': idVehiculo,
      'nombre': nombre,
      'licencia_de_conducir': licencia,
      'estado': estado,
    };
  }
}