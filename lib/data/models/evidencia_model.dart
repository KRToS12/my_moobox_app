class EvidenciaModel {
  final String? id;
  final String pedidoId;
  final String autorId;
  final String tipoEvidencia; // 'CARGA' o 'ENTREGA'
  final String url;
  final String? coordenadas;

  EvidenciaModel({
    this.id,
    required this.pedidoId,
    required this.autorId,
    required this.tipoEvidencia,
    required this.url,
    this.coordenadas,
  });

  factory EvidenciaModel.fromJson(Map<String, dynamic> json) => EvidenciaModel(
    id: json['id_evidencia'],
    pedidoId: json['id_pedido'],
    autorId: json['id_autor'],
    tipoEvidencia: json['tipo_evidencia'],
    url: json['url'],
    coordenadas: json['coordenadas_gps'],
  );

  Map<String, dynamic> toJson() => {
    'id_pedido': pedidoId,
    'id_autor': autorId,
    'tipo_evidencia': tipoEvidencia,
    'url': url,
    'coordenadas_gps': coordenadas,
  };
}