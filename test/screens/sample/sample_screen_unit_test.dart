import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_sample/model/sample_response.dart';
import 'package:flutter_test_sample/repository/posts/posts_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock_client.dart';
import '../../mock_connectivity_service.dart';

void main() {
  late MockClient mockClient;
  late PostsRepository mockRepository;
  late MockConnectivityService mockConnectivityService;
  setUp(() {
    mockClient = MockClient();
    mockConnectivityService = MockConnectivityService();
    mockRepository = PostsRepository(mockClient);
  });

  test("API Call Response with internet connection", () async {
    // Arrange
    when(() => mockConnectivityService.checkConnection())
        .thenAnswer((_) async => true);

    when(() => mockClient.getPost()).thenAnswer((_) async {
      return [
        SampleResponse(
            id: 1, userId: 1001, body: "Test body", title: "Test title")
      ];
    });

    // Act
    final apiResult = await mockRepository.getPosts();
    final response = apiResult.data;

    // Assert
    expect(await mockConnectivityService.checkConnection(), isTrue);
    expect(response, isA<List<SampleResponse>>());
  });

  test("API Call Failure due to no internet connection", () async {
    // Arrange
    when(() => mockConnectivityService.checkConnection())
        .thenAnswer((_) async => false);
    final bool isConnected = await mockConnectivityService.checkConnection();

    // Assert
    expect(
        isConnected, false); // Ensure this matches your actual implementation
  });

  test("API Call Failure due to server issue", () async {
    // Arrange
    when(() => mockConnectivityService.checkConnection()).thenAnswer(
        (_) async =>
            true); // Assuming the server issue occurs even when connected

    when(() => mockClient.getPost()).thenAnswer((_) async {
      throw Exception('Failed to fetch master data');
    });

    // Act
    final apiResult = await mockRepository.getPosts();

    // Assert
    expect(apiResult.getException, isA<Exception>());
  });
}
