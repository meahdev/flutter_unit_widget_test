import 'package:flutter/material.dart';
import 'package:flutter_test_sample/core/connectivity.dart';
import 'package:flutter_test_sample/network/api_client.dart';
import 'package:flutter_test_sample/repository/posts/posts_repository.dart';
import 'package:flutter_test_sample/screens/posts/posts_screen.dart';


void main() async {
  ///ensures that the Flutter framework's bindings are properly initialized before proceeding with the rest of your application code.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (_) => PostsScreen(
              repository: PostsRepository(ApiClient()),
              connectivityService: ConnectivityService(),
            ),
      },
    );
  }
}
