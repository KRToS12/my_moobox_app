class DireccionModel {
  final String? id;
  final String pedidoId;
  final String tipoDireccion; // 'origen' o 'destino'
  final String calle;
  final String ciudad;
  final double latitud;
  final double longitud;
  final String? idOferta;
  final String? descripcion;

  DireccionModel({
    this.id,
    required this.pedidoId,
    required this.tipoDireccion,
    required this.calle,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    this.idOferta,
    this.descripcion,
  });

  factory DireccionModel.fromJson(Map<String, dynamic> json) => DireccionModel(
    id: json['id_direccion'],
    pedidoId: json['id_pedido'],
    tipoDireccion: json['tipo_direccion'],
    calle: json['calle'],
    ciudad: json['ciudad'],
    latitud: json['latitud'].toDouble(),
    longitud: json['longitud'].toDouble(),
    idOferta: json['id_oferta'],
    descripcion: json['descripcion'],
  );

  Map<String, dynamic> toJson() => {
    'id_pedido': pedidoId,
    'tipo_direccion': tipoDireccion,
    'calle': calle,
    'ciudad': ciudad,
    'latitud': latitud,
    'longitud': longitud,
    'id_oferta': idOferta,
    'descripcion': descripcion,
  };
}