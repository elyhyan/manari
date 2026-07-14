import 'dart:io';

import 'package:manari_server/manari_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main(List<String> arguments) async {
  final router = buildRouter();
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(router.call, InternetAddress.anyIPv4, port);
  print('manari_server listening on port ${server.port}');
}
