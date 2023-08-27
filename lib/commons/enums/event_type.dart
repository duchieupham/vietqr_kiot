enum EventTypes {
  refreshListTransaction,
  updateCountNotification,
  refreshListAccountBank,
}

class EventType {
  final dynamic data;
  final EventTypes eventType;
  EventType(this.eventType, this.data);
}
