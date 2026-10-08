import 'dart:async';
import 'dart:developer';

import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/network/cookie_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;

  final _newMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _newMessageController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    try {
      final cookieJar = await CookieStorage.getInstance();
      final cookies = await cookieJar.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );
      final cookieString = cookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');

      log('🔌 Connecting socket with cookies: $cookieString');

      _socket = io.io(
        ApiConstants.socketUrl,
        io.OptionBuilder()
            // .setTransports(['websocket'])
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setExtraHeaders({
              'Cookie': cookieString,
              'Host': ApiConstants.hostHeader,
            })
            .setAuth({'cookie': cookieString})
            .enableReconnection()
            .build(),
      );

      _registerListeners();
      _socket!.connect();
    } catch (e) {
      // log('❌ Socket connect error: $e');
    }
  }

  void _registerListeners() {
    _socket!.onConnect((_) {
      // log('🟢 Socket connected: ${_socket!.id}');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      // log('🔴 Socket disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      // log('❌ Socket connect error: $err');
      _isConnected = false;
      _connectionController.add(false);
    });

    //   Live chat updates
    _socket!.on('new_message', (data) {
      // log('📩 new_message: $data');
      if (data is Map<String, dynamic>) {
        _newMessageController.add(data);
      } else if (data is Map) {
        _newMessageController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void joinChannel(String channelId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('join_channel', {'channel_id': channelId});
    // log('👥 Joined channel: $channelId');
  }

  void leaveChannel(String channelId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('leave_channel', {'channel_id': channelId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    _newMessageController.close();
    _connectionController.close();
    disconnect();
  }
}
