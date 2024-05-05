class GroupInvite {
  final String userId;
  final int groupId;
  final String invitedBy;

  const GroupInvite({
    required this.userId,
    required this.groupId,
    required this.invitedBy,
  });

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    try {
      return GroupInvite(
        userId: json["user_id"] as String,
        groupId: json["group_id"] as int,
        invitedBy: json["invited_by"] as String,
      );
    } on FormatException {
      throw const FormatException("Failed to build Group Invite.");
    }
  }
}
