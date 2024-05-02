class GroupInvite {
  final String userId;
  final int groupId;
  final String invitedBy;

  const GroupInvite ({
    required this.userId,
    required this.groupId,
    required this.invitedBy,
  });

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      "user_id": String userId,
      "group_id": int groupId,
      "invited_by": String invitedBy,
    } => 
      GroupInvite(
        userId: userId,
        groupId: groupId,
        invitedBy: invitedBy,
    ),
    _ => throw const FormatException('Failed to build Profile.'),
  };

    
  }
}