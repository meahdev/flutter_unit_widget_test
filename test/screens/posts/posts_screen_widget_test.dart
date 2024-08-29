import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_sample/repository/posts/posts_repository.dart';
import 'package:flutter_test_sample/screens/posts/posts_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test_sample/model/sample_response.dart';

import '../../mock_client.dart';
import '../../mock_connectivity_service.dart';

void main() {
  late MockClient mockClient;
  late PostsRepository mockRepository;
  late MockConnectivityService mockConnectivityService;
  late List<SampleResponse>? mockItems;
  group("Test - Basic loading and scrolling behavior", () {
    // Set up mock data and services
    setUp(() async {
      mockClient = MockClient();
      mockRepository = PostsRepository(mockClient);
      mockConnectivityService = MockConnectivityService();
      mockItems = List.generate(
          100,
          (index) => SampleResponse(
              id: index,
              title: 'Item $index',
              body: 'Item Body $index',
              userId: double.parse("00$index")));

      when(() => mockClient.getPost()).thenAnswer((invocation) async {
        return Future.value(mockItems);
      });
    });
    // Test if the mock service is working as expected
    test('Test - Mock Service', () async {
      expect(await mockClient.getPost(), equals(mockItems));
    });
    testWidgets("Test - No internet connection", (tester) async {
      // Use runAsync to handle asynchronous operations and pending timers properly
      // This ensures that all async tasks complete and are managed correctly during the test
      await tester.runAsync(() async {
        // Simulate no internet connection
        when(() => mockConnectivityService.checkConnection())
            .thenAnswer((_) async => false);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostsScreen(
                repository: mockRepository,
                connectivityService: mockConnectivityService,
              ),
            ),
          ),
        );
        // Verify that the loading indicator is shown initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Simulate the delay to allow the connection check to complete
        await tester.pumpAndSettle();
        // Verify that the loading indicator is no longer visible
        expect(find.byType(CircularProgressIndicator), findsNothing);
        // Check that the "No internet connection" snack bar is displayed
        expect(find.text("No internet connection"), findsOneWidget);
      });
    });
    testWidgets("Test - Loading indicator with internet connection",
        (tester) async {
      // Simulate a valid internet connection
      when(() => mockConnectivityService.checkConnection())
          .thenAnswer((_) async => true);

      // Mock API call
      when(() => mockClient.getPost()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return Future.value(mockItems);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostsScreen(
              repository: mockRepository,
              connectivityService: mockConnectivityService,
            ),
          ),
        ),
      );
      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Simulate the delay to hide the loader and show the content
      await tester.pump(const Duration(seconds: 2));
      // Wait for the widget tree to settle
      await tester.pumpAndSettle();
      // Check that the loading indicator is no longer visible
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Ensure the SafeArea is now visible
      expect(find.byType(SafeArea), findsOneWidget);
      // Ensure the ListView is now visible
      expect(find.byType(ListView), findsOneWidget);
    });
    testWidgets('Test - Scrolling', (WidgetTester tester) async {
      // Mocking the API response
      final mockItems = List.generate(
          100,
          (index) => SampleResponse(
                id: index,
                title: 'Item $index',
                body: 'Item Body $index',
                userId: double.parse("00$index"),
              ));
      when(() => mockConnectivityService.checkConnection())
          .thenAnswer((_) async => true);
      when(() => mockClient.getPost()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return Future.value(mockItems);
      });
      await tester.pumpWidget(
        MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: PostsScreen(
              repository: mockRepository,
              connectivityService: mockConnectivityService,
            ),
          ),
        ),
      );
      // Wait for the loading to complete
      await tester.pumpAndSettle();
      // Check if the ListView is present in the widget tree
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
      // Check initial items are rendered correctly
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 99'), findsNothing);
      // Perform a scroll to reveal the last item
      await tester.drag(
          listViewFinder, const Offset(0, -10000)); // Larger offset
      // Wait for any remaining animations and frames
      await tester.pumpAndSettle();
      // Verify that the last item is now in view
      expect(find.text('Item 99'), findsOneWidget);
    });
  });
}
