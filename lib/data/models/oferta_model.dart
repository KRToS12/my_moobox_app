class OfertaModel {
  final String? id;
  final String pedidoId;
  final String operadorId;
  final double montoOfertado;
  final String? comentario;
  final String estadoOferta;

  OfertaModel({
    this.id,
    required this.pedidoId,
    required this.operadorId,
    required this.montoOfertado,
    this.comentario,
    required this.estadoOferta,
  });

  factory OfertaModel.fromJson(Map<String, dynamic> json) => OfertaModel(
    id: json['id_oferta'],
    pedidoId: json['id_pedido'],
    operadorId: json['id_operador'],
    montoOfertado: json['monto_ofertado'].toDouble(),
    comentario: json['comentario_oferta'],
    estadoOferta: json['estado_oferta'],
  );

  Map<String, dynamic> toJson() => {
    'id_pedido': pedidoId,
    'id_operador': operadorId,
    'monto_ofertado': montoOfertado,
    'comentario_oferta': comentario,
    'estado_oferta': estadoOferta,
  };
}