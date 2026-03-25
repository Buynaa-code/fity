enum UserRole {
  member,
  receptionist,
  trainer,
  coach,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Гишүүн';
      case UserRole.receptionist:
        return 'Ресепшн';
      case UserRole.trainer:
        return 'Дасгалжуулагч';
      case UserRole.coach:
        return 'Марафон багш';
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
      case 'coach':
        return UserRole.coach;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.member;
    }
  }
}
