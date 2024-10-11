class Notification {
  final String id;                  
  final String title;               
  final String message;             
  final DateTime timestamp;         
  final bool isRead;                

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}