import 'package:easy_mock_server/easy_mock_server.dart';
import 'package:test/test.dart';

void main() {
  test('default resolver supports nested and fallback candidates', () {
    const resolver = DefaultMockRouteResolver();
    final candidates = resolver.resolveCandidates('/api/v1/profile?x=1');

    expect(
      candidates,
      equals(<String>[
        'api/v1/profile.json',
        'profile.json',
        'api/v1/profile/index.json',
        'profile/index.json',
      ]),
    );
  });

  test('mapped resolver prioritizes route map', () {
    final resolver = MappedRouteResolver(
      routeMap: <String, String>{
        '/users': 'custom/users-response.json',
      },
    );

    final candidates = resolver.resolveCandidates('/users');
    expect(candidates.first, 'custom/users-response.json');
  });

  test('parses route-map json', () {
    final routeMap = parseRouteMapJson('{"/a": "a.json", "/b": "b.json"}');

    expect(routeMap['/a'], 'a.json');
    expect(routeMap['/b'], 'b.json');
  });
}
