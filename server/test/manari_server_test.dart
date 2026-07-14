import 'dart:convert';

import 'package:manari_server/manari_server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('GET /health returns ok', () async {
    final router = buildRouter();
    final response = await router.call(Request('GET', Uri.parse('http://localhost/health')));

    expect(response.statusCode, 200);
    final body = jsonDecode(await response.readAsString());
    expect(body['status'], 'ok');
  });
}
