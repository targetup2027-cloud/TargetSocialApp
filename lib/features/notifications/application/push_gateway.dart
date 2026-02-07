abstract class PushGateway {
  Future<void> onPushReceived(Map<String, dynamic> payload);

  Future<void> registerToken(String userId, String token);

  Future<void> unregisterToken(String userId);
}

class PushGatewayStub implements PushGateway {
  PushGatewayStub();

  @override
  Future<void> onPushReceived(Map<String, dynamic> payload) async {
    throw UnimplementedError(
      'Push notifications not integrated. '
      'Implement this method when adding Firebase/OneSignal.'
    );
  }

  @override
  Future<void> registerToken(String userId, String token) async {
    throw UnimplementedError(
      'Push token registration not integrated. '
      'Implement this method when adding Firebase/OneSignal.'
    );
  }

  @override
  Future<void> unregisterToken(String userId) async {
    throw UnimplementedError(
      'Push token unregistration not integrated. '
      'Implement this method when adding Firebase/OneSignal.'
    );
  }
}
