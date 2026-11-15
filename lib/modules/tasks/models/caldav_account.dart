/// A CalDAV server plus the credentials used to read and write its tasks.
///
/// The password only lives in memory: it is never written to the repo or to
/// `SharedPreferences`.
class CaldavAccount {
  const CaldavAccount({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  final String id;
  final String label;
  final String baseUrl;
  final String username;
  final String password;
}
