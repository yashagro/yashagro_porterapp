class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) => PaginationModel(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        limit: json["limit"] ?? 20,
        totalPages: json["total_pages"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "limit": limit,
        "total_pages": totalPages,
      };
}

class PaginatedResult<T> {
  final List<T> data;
  final PaginationModel? pagination;

  PaginatedResult({required this.data, this.pagination});
}
