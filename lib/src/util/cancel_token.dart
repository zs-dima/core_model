import 'dart:async';

import 'package:meta/meta.dart';

/// A token used to cancel one or more in-flight operations.
///
/// Pass the same token to several operations to cancel them together. Backed by a [Completer]:
/// [cancel] completes it, signalling anything awaiting [whenCancel]. Transport-agnostic: an HTTP
/// client wires [whenCancel] into the request's abort trigger, a session cancels on logout.
class CancelToken {
  final Completer<void> _completer = Completer<void>();

  /// Child tokens that cancel with this one. Created lazily and holds only active children: each
  /// detaches on completion (see [link]), so it never grows with the total number of requests.
  Set<CancelToken>? _children;

  /// Whether [cancel] has already been called.
  bool get isCancelled => _completer.isCompleted;

  /// Future that completes when the token is cancelled.
  Future<void> get whenCancel => _completer.future;

  /// Number of currently-linked child tokens (for tests/diagnostics).
  @visibleForTesting
  int get debugLinkedCount => _children?.length ?? 0;

  Object? _reason;

  /// The reason passed to [cancel], if any.
  Object? get reason => _reason;

  /// Cancels this token (and any linked children, transitively). Idempotent.
  void cancel([Object? reason]) {
    if (_completer.isCompleted) return;
    // Iterative traversal (no recursion) over this token and its linked children.
    final pending = <CancelToken>[this];
    while (pending.isNotEmpty) {
      final token = pending.removeLast();
      if (token._completer.isCompleted) continue;
      token._reason = reason;
      token._completer.complete();
      final children = token._children;
      token._children = null;
      if (children != null) pending.addAll(children);
    }
  }

  /// Links [child] so it cancels with this token; returns a callback that detaches it. A child
  /// linked to an already-cancelled token is cancelled at once.
  // `void Function()` and not `VoidCallback`: pure Dart package, the Flutter typedef is absent.
  // ignore: prefer-void-callback
  void Function() link(CancelToken child) {
    if (isCancelled) {
      child.cancel(_reason);
      return () {};
    }
    (_children ??= <CancelToken>{}).add(child);
    return () => _children?.remove(child);
  }
}
