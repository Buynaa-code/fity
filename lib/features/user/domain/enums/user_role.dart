enum UserRole {
  member,
  receptionist,
  trainer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Гишүүн';
      case UserRole.receptionist:
        return 'Ресепшн';
      case UserRole.trainer:
        return 'Дасгалжуулагч';
      case UserRole.admin:
        return 'Админ';
    }
  }

  static UserRole fromString(String? value) {
    switch (value) {
      case 'receptionist':
        return UserRole.receptionist;
      case 'trainer':
        return UserRole.trainer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.member;
    }
  }
}
