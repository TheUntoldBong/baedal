



class OrderHelper{
  static const Set<String> closedStatuses = <String>{
    'delivered', 'canceled', 'refund_requested', 'refund_request_canceled', 'refunded', 'failed',
  };

  static bool canContact(String? orderStatus) {
    return !closedStatuses.contains((orderStatus ?? '').toLowerCase());
  }

}