import 'package:flutter/material.dart';
import 'package:flutter_test_sample/repository/posts/posts_repository.dart';
import 'package:flutter_test_sample/screens/posts/widgets/item_list.dart';
import '../../core/connectivity.dart';
import '../../core/snackbar_utils.dart';
import '../../model/sample_response.dart';
import '../../network/error_handler.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen(
      {super.key, required this.repository, required this.connectivityService});

  final PostsRepository repository;
  final ConnectivityService connectivityService;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  //loader flag whether to determine show the loader
  bool _isLoading = true;

  //list of posts
  final List<SampleResponse> _mPostList = [];

  // only triggers in the initial time of application
  @override
  void initState() {
    super.initState();

    // ensure all widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPost();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ))
          : SafeArea(
              child: ListView.builder(
                key: const Key("listview_builder"),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                itemCount: _mPostList.length,
                itemBuilder: (BuildContext context, int index) {
                  SampleResponse? item = _mPostList[index];
                  return ItemList(item: item);
                },
              ),
            ),
    );
  }

  //calling the sample API
  getPost() {
    //checking the connection
    widget.connectivityService.checkConnection().then((isConnected) {
      if (isConnected) {
        widget.repository.getPosts().then((value) {
          List<SampleResponse>? response = value.data;
          if (value.getException != null) {
            //if there is any error ,it will trigger here and shown in snack-bar
            ErrorHandler errorHandler = value.getException;
            String msg = errorHandler.getErrorMessage();
            //got the exception and disabling the loader
            setState(() {
              _isLoading = false;
            });
            SnackBarUtils.showErrorSnackBar(context, msg);
          } else if (response != null) {
            //got the response and disabling the loader
            setState(() {
              _isLoading = false;
              _mPostList.addAll(response);
            });
          } else {
            //when response is null most cases are when status code becomes 204
            //disabling the loader
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        //when there is no connection
        //disabling the loader
        setState(() {
          _isLoading = false;
        });
        SnackBarUtils.showErrorSnackBar(context, "No internet connection");
      }
    });
  }
}
