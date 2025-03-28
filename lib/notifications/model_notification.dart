class MessageNotif {
  final String id;
  final String message;
  final DateTime dateCreation;
  final bool isRead;
  final String userId;
  final String? commandId;

  MessageNotif({
    required this.id,
    required this.message,
    required this.dateCreation,
    required this.isRead,
    required this.userId,
    this.commandId,
  });

  factory MessageNotif.fromJson(Map<String, dynamic> json) {
    return MessageNotif(
      id: json['id'],
      message: json['message'],
      dateCreation: DateTime.parse(json['dateCreation']),
      isRead: json['lue'],
      userId: json['utilisateur']['id'],
      commandId: json['commandes']?['id'],
    );
  }
}
