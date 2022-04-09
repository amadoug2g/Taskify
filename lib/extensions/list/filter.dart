extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) condition) =>
      map((items) => items.where(condition).toList());
}
