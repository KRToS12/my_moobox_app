class PedidoModel {
  final String? id;
  final String usuarioId;
  final String? operadorId;
  final double? costoCotizado;
  final double? costoFinal;
  final int estibadores;
  final int pisoOrigen;
  final int pisoDestino;
  final DateTime? fechaSolicitud;
  final DateTime? fechaServicio;
  final String estadoPedido;

  PedidoModel({
    this.id,
    required this.usuarioId,
    this.operadorId,
    this.costoCotizado,
    this.costoFinal,
    this.estibadores = 0,
    this.pisoOrigen = 0,
    this.pisoDestino = 0,
    this.fechaSolicitud,
    this.fechaServicio,
    required this.estadoPedido,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) => PedidoModel(
    id: json['id_pedido'],
    usuarioId: json['id_usuario'],
    operadorId: json['id_operador'],
    costoCotizado: json['costo_cotizado']?.toDouble(),
    costoFinal: json['costo_final']?.toDouble(),
    estibadores: json['estibadores'] ?? 0,
    pisoOrigen: json['piso_origen'] ?? 0,
    pisoDestino: json['piso_destino'] ?? 0,
    fechaSolicitud: json['fecha_solicitud'] != null ? DateTime.parse(json['fecha_solicitud']) : null,
    fechaServicio: json['fecha_servicio'] != null ? DateTime.parse(json['fecha_servicio']) : null,
    estadoPedido: json['estado_pedido'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id_pedido': id,
    'id_usuario': usuarioId,
    'id_operador': operadorId,
    'costo_cotizado': costoCotizado,
    'costo_final': costoFinal,
    'estibadores': estibadores,
    'piso_origen': pisoOrigen,
    'piso_destino': pisoDestino,
    'fecha_servicio': fechaServicio?.toIso8601String(),
    'estado_pedido': estadoPedido,
  };
}