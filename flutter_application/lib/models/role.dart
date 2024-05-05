enum Role {
  zero,
  one,
  two;

  static Role parse(int roleValue) {
    switch (roleValue) {
      case 0:
        return Role.zero;
      case 1:
        return Role.one;
      case 2:
        return Role.two;
      default:
        throw ArgumentError('Invalid role value: $roleValue');
    }
  }
}