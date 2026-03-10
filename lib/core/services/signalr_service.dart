import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  final void Function() onNewStory;
  HubConnection? _connection;

  SignalRService({required this.onNewStory});

  Future<void> connect(String token) async {
    final url =
        'https://api.thepetsocial.net/hubs/feed?access_token=$token';

    _connection = HubConnectionBuilder()
        .withUrl(url)
        .withAutomaticReconnect()
        .build();

    _connection!.on('NewStoryCreated', (_) => onNewStory());

    try {
      await _connection!.start();
    } catch (_) {
      // Silently fail — real-time is best-effort; polling isn't used.
    }
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
