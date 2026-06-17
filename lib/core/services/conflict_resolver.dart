class ConflictResolver {
  /// Compares local and remote updated_at timestamps.
  /// Returns true if the remote version is newer and should override local.
  static bool shouldRemoteOverrideLocal({
    required DateTime? localUpdatedAt,
    required DateTime? remoteUpdatedAt,
  }) {
    if (remoteUpdatedAt == null) return false;
    if (localUpdatedAt == null) return true;
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }
}
