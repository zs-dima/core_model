/// A UUID carried as its string form.
typedef Guid = String;

/// Sentinels for a [Guid].
extension GuidX on Guid {
  /// The client-side "no id".
  static Guid get empty => '';

  /// The nil UUID (RFC 9562 §5.9), all 128 bits zero: the "no id" a server sends. [empty] is the
  /// client-side equivalent. Const, so it works in const constructors.
  static const Guid nil = '00000000-0000-0000-0000-000000000000';
}
