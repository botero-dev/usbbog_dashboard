/// Which backend an account belongs to. Decides who validates the credentials
/// on "Connect" and which service later consumes them.
enum AccountKind { immich, caldav }

class Account {
  const Account({
    required this.id,
    required this.kind,
    required this.label,
    required this.server,
    required this.user,
  });

  final String id;
  final AccountKind kind;
  final String label;
  final String server;
  final String user;
}
