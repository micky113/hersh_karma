enum AssetCategory {
  environmental, // Carbon credits, Renewable-energy certificates, Water, Biodiversity
  human,         // Education projects, Health clinics, Food-security
  animal,        // Wildlife conservation, Animal welfare
  knowledge,     // Open-source contributions, Public tech
}

class ExchangeAsset {
  final String id;
  final String name;
  final String symbol;
  final AssetCategory category;
  final int exchangeRate; // KGC required for 1.0 unit of this asset
  final String icon;
  final String description;

  const ExchangeAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.category,
    required this.exchangeRate,
    required this.icon,
    required this.description,
  });
}
