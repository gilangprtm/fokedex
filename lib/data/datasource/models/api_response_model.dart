class PaginatedApiResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedApiResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedApiResponse<T>(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<T>.from(
        json['results'].map((item) => fromJsonT(item)),
      ),
    );
  }

  // Check if there are more items to load
  bool get hasMore => next != null;

  // Extract the offset from the next URL
  int? get nextOffset {
    if (next == null) return null;
    final uri = Uri.parse(next!);
    final offsetParam = uri.queryParameters['offset'];
    return offsetParam != null ? int.tryParse(offsetParam) : null;
  }

  // Extract the limit from the next URL
  int? get nextLimit {
    if (next == null) return null;
    final uri = Uri.parse(next!);
    final limitParam = uri.queryParameters['limit'];
    return limitParam != null ? int.tryParse(limitParam) : null;
  }
}

class ResourceListItem {
  final String name;
  final String url;

  ResourceListItem({
    required this.name,
    required this.url,
  });

  factory ResourceListItem.fromJson(Map<String, dynamic> json) {
    return ResourceListItem(
      name: json['name'],
      url: json['url'],
    );
  }

  // Extract ID from URL
  int get id {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    // The ID is typically the last path segment before the trailing slash
    return int.parse(pathSegments[pathSegments.length - 2]);
  }

  String get normalizedName {
    return name.replaceAll('-', ' ');
  }
}
