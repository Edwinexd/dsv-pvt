enum Role {
  ADMIN,
  MODERATOR,
  NORMAL;

  static Role parse(int roleValue) {
    switch (roleValue) {
      case 0:
        return Role.ADMIN;
      case 1:
        return Role.MODERATOR;
      case 2:
        return Role.NORMAL;
      default:
        throw ArgumentError('Invalid role value: $roleValue');
    }
  }
}