class ServiceModel {
  final String id;
  final String nameRu;
  final String nameKk;
  final String nameEn;
  final String icon;
  final String? description;

  const ServiceModel({
    required this.id,
    required this.nameRu,
    required this.nameKk,
    required this.nameEn,
    required this.icon,
    this.description,
  });

  factory ServiceModel.fromMap(Map<String, String> data) {
    return ServiceModel(
      id: data['id'] ?? '',
      nameRu: data['nameRu'] ?? '',
      nameKk: data['nameKk'] ?? '',
      nameEn: data['nameEn'] ?? '',
      icon: data['icon'] ?? '',
    );
  }

  String localizedName(String locale) {
    switch (locale) {
      case 'kk':
        return nameKk;
      case 'en':
        return nameEn;
      default:
        return nameRu;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ServiceModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
