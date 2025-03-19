class Item {
  final int id;
  final String name;
  final int cost;
  final int? flingPower;
  final ItemFlingEffect? flingEffect;
  final List<ItemAttribute>? attributes;
  final ItemCategory? category;
  final List<ItemEffectEntry>? effectEntries;
  final List<ItemFlavorText>? flavorTextEntries;
  final List<ItemName>? names;
  final List<ItemSprite>? sprites;
  final List<ItemHolderPokemon>? heldByPokemon;

  Item({
    required this.id,
    required this.name,
    required this.cost,
    this.flingPower,
    this.flingEffect,
    this.attributes,
    this.category,
    this.effectEntries,
    this.flavorTextEntries,
    this.names,
    this.sprites,
    this.heldByPokemon,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    List<ItemAttribute>? attributes;
    if (json['attributes'] != null) {
      attributes = (json['attributes'] as List)
          .map((attr) => ItemAttribute.fromJson(attr))
          .toList();
    }

    List<ItemEffectEntry>? effectEntries;
    if (json['effect_entries'] != null) {
      effectEntries = (json['effect_entries'] as List)
          .map((entry) => ItemEffectEntry.fromJson(entry))
          .toList();
    }

    List<ItemFlavorText>? flavorTextEntries;
    if (json['flavor_text_entries'] != null) {
      flavorTextEntries = (json['flavor_text_entries'] as List)
          .map((entry) => ItemFlavorText.fromJson(entry))
          .toList();
    }

    List<ItemName>? names;
    if (json['names'] != null) {
      names = (json['names'] as List)
          .map((name) => ItemName.fromJson(name))
          .toList();
    }

    List<ItemSprite>? sprites;
    if (json['sprites'] != null) {
      // Convert sprites object to list
      sprites = [ItemSprite.fromJson(json['sprites'])];
    }

    List<ItemHolderPokemon>? heldByPokemon;
    if (json['held_by_pokemon'] != null) {
      heldByPokemon = (json['held_by_pokemon'] as List)
          .map((pokemon) => ItemHolderPokemon.fromJson(pokemon))
          .toList();
    }

    return Item(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      flingPower: json['fling_power'],
      flingEffect: json['fling_effect'] != null
          ? ItemFlingEffect.fromJson(json['fling_effect'])
          : null,
      attributes: attributes,
      category: json['category'] != null
          ? ItemCategory.fromJson(json['category'])
          : null,
      effectEntries: effectEntries,
      flavorTextEntries: flavorTextEntries,
      names: names,
      sprites: sprites,
      heldByPokemon: heldByPokemon,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cost'] = cost;
    if (flingPower != null) data['fling_power'] = flingPower;
    if (flingEffect != null) data['fling_effect'] = flingEffect!.toJson();
    if (attributes != null) {
      data['attributes'] = attributes!.map((item) => item.toJson()).toList();
    }
    if (category != null) data['category'] = category!.toJson();
    if (effectEntries != null) {
      data['effect_entries'] =
          effectEntries!.map((item) => item.toJson()).toList();
    }
    if (flavorTextEntries != null) {
      data['flavor_text_entries'] =
          flavorTextEntries!.map((item) => item.toJson()).toList();
    }
    if (names != null) {
      data['names'] = names!.map((item) => item.toJson()).toList();
    }
    if (sprites != null && sprites!.isNotEmpty) {
      data['sprites'] = sprites![0].toJson();
    }
    if (heldByPokemon != null) {
      data['held_by_pokemon'] =
          heldByPokemon!.map((item) => item.toJson()).toList();
    }
    return data;
  }
}

class ItemFlingEffect {
  final String name;
  final String url;

  ItemFlingEffect({
    required this.name,
    required this.url,
  });

  factory ItemFlingEffect.fromJson(Map<String, dynamic> json) {
    return ItemFlingEffect(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class ItemAttribute {
  final String name;
  final String url;

  ItemAttribute({
    required this.name,
    required this.url,
  });

  factory ItemAttribute.fromJson(Map<String, dynamic> json) {
    return ItemAttribute(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class ItemCategory {
  final String name;
  final String url;

  ItemCategory({
    required this.name,
    required this.url,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class ItemEffectEntry {
  final String effect;
  final String shortEffect;
  final Language language;

  ItemEffectEntry({
    required this.effect,
    required this.shortEffect,
    required this.language,
  });

  factory ItemEffectEntry.fromJson(Map<String, dynamic> json) {
    return ItemEffectEntry(
      effect: json['effect'],
      shortEffect: json['short_effect'],
      language: Language.fromJson(json['language']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['effect'] = effect;
    data['short_effect'] = shortEffect;
    data['language'] = language.toJson();
    return data;
  }
}

class Language {
  final String name;
  final String url;

  Language({
    required this.name,
    required this.url,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class ItemFlavorText {
  final String text;
  final Language language;
  final Version version;

  ItemFlavorText({
    required this.text,
    required this.language,
    required this.version,
  });

  factory ItemFlavorText.fromJson(Map<String, dynamic> json) {
    return ItemFlavorText(
      text: json['text'],
      language: Language.fromJson(json['language']),
      version: Version.fromJson(json['version']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['language'] = language.toJson();
    data['version'] = version.toJson();
    return data;
  }
}

class Version {
  final String name;
  final String url;

  Version({
    required this.name,
    required this.url,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class ItemName {
  final String name;
  final Language language;

  ItemName({
    required this.name,
    required this.language,
  });

  factory ItemName.fromJson(Map<String, dynamic> json) {
    return ItemName(
      name: json['name'],
      language: Language.fromJson(json['language']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['language'] = language.toJson();
    return data;
  }
}

class ItemSprite {
  final String default_;

  ItemSprite({
    required this.default_,
  });

  factory ItemSprite.fromJson(Map<String, dynamic> json) {
    return ItemSprite(
      default_: json['default'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['default'] = default_;
    return data;
  }
}

class ItemHolderPokemon {
  final PokemonSpecies pokemon;
  final List<VersionDetail> versionDetails;

  ItemHolderPokemon({
    required this.pokemon,
    required this.versionDetails,
  });

  factory ItemHolderPokemon.fromJson(Map<String, dynamic> json) {
    return ItemHolderPokemon(
      pokemon: PokemonSpecies.fromJson(json['pokemon']),
      versionDetails: (json['version_details'] as List)
          .map((detail) => VersionDetail.fromJson(detail))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pokemon'] = pokemon.toJson();
    data['version_details'] =
        versionDetails.map((detail) => detail.toJson()).toList();
    return data;
  }
}

class PokemonSpecies {
  final String name;
  final String url;

  PokemonSpecies({
    required this.name,
    required this.url,
  });

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    return PokemonSpecies(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class VersionDetail {
  final int rarity;
  final Version version;

  VersionDetail({
    required this.rarity,
    required this.version,
  });

  factory VersionDetail.fromJson(Map<String, dynamic> json) {
    return VersionDetail(
      rarity: json['rarity'],
      version: Version.fromJson(json['version']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rarity'] = rarity;
    data['version'] = version.toJson();
    return data;
  }
}
