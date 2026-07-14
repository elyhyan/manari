import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router buildRouter() {
  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({'status': 'ok'}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
