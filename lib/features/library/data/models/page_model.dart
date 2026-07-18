class PageResponse<T> {
  final List<T> content;

  final int totalPages;

  final int totalElements;

  final int page;

  final int size;

  final bool last;

  const PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.last,
  });
}
