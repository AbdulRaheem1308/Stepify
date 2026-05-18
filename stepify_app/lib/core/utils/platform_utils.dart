export 'src/platform_stub.dart'
    if (dart.library.io) 'src/platform_io.dart'
    if (dart.library.js_interop) 'src/platform_web.dart';
