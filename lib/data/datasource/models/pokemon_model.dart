class Pokemon {
  final int id;
  final String name;
  final String url;
  final int? height;
  final int? weight;
  final List<PokemonType>? types;
  final List<PokemonAbility>? abilities;
  final List<PokemonStat>? stats;
  final List<PokemonMove>? moves;
  final PokemonSprites? sprites;
  final String? species;

  Pokemon({
    required this.id,
    required this.name,
    required this.url,
    this.height,
    this.weight,
    this.types,
    this.abilities,
    this.stats,
    this.moves,
    this.sprites,
    this.species,
  });

  // Factory constructor to convert from JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      url: json['url'] ?? 'https://pokeapi.co/api/v2/pokemon/${json['id']}/',
      height: json['height'],
      weight: json['weight'],
      types: json['types'] != null
          ? List<PokemonType>.from(
              json['types'].map((type) => PokemonType.fromJson(type)))
          : null,
      abilities: json['abilities'] != null
          ? List<PokemonAbility>.from(json['abilities']
              .map((ability) => PokemonAbility.fromJson(ability)))
          : null,
      stats: json['stats'] != null
          ? List<PokemonStat>.from(
              json['stats'].map((stat) => PokemonStat.fromJson(stat)))
          : null,
      moves: json['moves'] != null
          ? List<PokemonMove>.from(
              json['moves'].map((move) => PokemonMove.fromJson(move)))
          : null,
      sprites: json['sprites'] != null
          ? PokemonSprites.fromJson(json['sprites'])
          : null,
      species: json['species'] != null ? json['species']['url'] : null,
    );
  }

  // Factory constructor for list response
  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    return Pokemon(
      id: int.parse(json['url'].split('/')[6]),
      name: json['name'],
      url: json['url'],
    );
  }

  // To get Pokemon image URL based on ID
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // Higher quality alternative
  String get dreamWorldImageUrl =>
      sprites?.other?.dreamWorld?.frontDefault ?? '';

  // Get the Home artwork if available
  String get homeImageUrl => sprites?.other?.home?.frontDefault ?? '';

  // Get official artwork if available
  String get officialArtworkImageUrl =>
      sprites?.other?.officialArtwork?.frontDefault ?? '';

  // Get formatted ID (e.g., #001, #025, #150)
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  // Get formatted height in meters
  String get formattedHeight =>
      height != null ? '${(height! / 10).toStringAsFixed(1)} m' : 'Unknown';

  // Get formatted weight in kg
  String get formattedWeight =>
      weight != null ? '${(weight! / 10).toStringAsFixed(1)} kg' : 'Unknown';

  // Get capitalized name
  String get capitalizedName =>
      name.substring(0, 1).toUpperCase() + name.substring(1);
}

class PokemonType {
  final int slot;
  final TypeInfo type;

  PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      slot: json['slot'],
      type: TypeInfo.fromJson(json['type']),
    );
  }
}

class TypeInfo {
  final String name;
  final String url;

  TypeInfo({required this.name, required this.url});

  factory TypeInfo.fromJson(Map<String, dynamic> json) {
    return TypeInfo(
      name: json['name'],
      url: json['url'],
    );
  }
}

class PokemonAbility {
  final bool isHidden;
  final int slot;
  final AbilityInfo ability;

  PokemonAbility({
    required this.isHidden,
    required this.slot,
    required this.ability,
  });

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      isHidden: json['is_hidden'],
      slot: json['slot'],
      ability: AbilityInfo.fromJson(json['ability']),
    );
  }
}

class AbilityInfo {
  final String name;
  final String url;

  AbilityInfo({required this.name, required this.url});

  factory AbilityInfo.fromJson(Map<String, dynamic> json) {
    return AbilityInfo(
      name: json['name'],
      url: json['url'],
    );
  }
}

class PokemonStat {
  final int baseStat;
  final int effort;
  final StatInfo stat;

  PokemonStat({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      baseStat: json['base_stat'],
      effort: json['effort'],
      stat: StatInfo.fromJson(json['stat']),
    );
  }
}

class StatInfo {
  final String name;
  final String url;

  StatInfo({required this.name, required this.url});

  factory StatInfo.fromJson(Map<String, dynamic> json) {
    return StatInfo(
      name: json['name'],
      url: json['url'],
    );
  }

  // Get formatted stat name (e.g., "HP", "Attack", "Defense")
  String get formattedName {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name.substring(0, 1).toUpperCase() + name.substring(1);
    }
  }
}

class PokemonMove {
  final MoveInfo move;

  PokemonMove({required this.move});

  factory PokemonMove.fromJson(Map<String, dynamic> json) {
    return PokemonMove(
      move: MoveInfo.fromJson(json['move']),
    );
  }
}

class MoveInfo {
  final String name;
  final String url;

  MoveInfo({required this.name, required this.url});

  factory MoveInfo.fromJson(Map<String, dynamic> json) {
    return MoveInfo(
      name: json['name'],
      url: json['url'],
    );
  }
}

class PokemonSprites {
  final String frontDefault;
  final String? backDefault;
  final Other? other;

  PokemonSprites({
    required this.frontDefault,
    this.backDefault,
    this.other,
  });

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'] ?? '',
      backDefault: json['back_default'],
      other: json['other'] != null ? Other.fromJson(json['other']) : null,
    );
  }
}

class Other {
  final DreamWorld? dreamWorld;
  final Home? home;
  final OfficialArtwork? officialArtwork;

  Other({
    this.dreamWorld,
    this.home,
    this.officialArtwork,
  });

  factory Other.fromJson(Map<String, dynamic> json) {
    return Other(
      dreamWorld: json['dream_world'] != null
          ? DreamWorld.fromJson(json['dream_world'])
          : null,
      home: json['home'] != null ? Home.fromJson(json['home']) : null,
      officialArtwork: json['official-artwork'] != null
          ? OfficialArtwork.fromJson(json['official-artwork'])
          : null,
    );
  }
}

class DreamWorld {
  final String? frontDefault;

  DreamWorld({this.frontDefault});

  factory DreamWorld.fromJson(Map<String, dynamic> json) {
    return DreamWorld(
      frontDefault: json['front_default'],
    );
  }
}

class Home {
  final String? frontDefault;

  Home({this.frontDefault});

  factory Home.fromJson(Map<String, dynamic> json) {
    return Home(
      frontDefault: json['front_default'],
    );
  }
}

class OfficialArtwork {
  final String? frontDefault;

  OfficialArtwork({this.frontDefault});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) {
    return OfficialArtwork(
      frontDefault: json['front_default'],
    );
  }
}
