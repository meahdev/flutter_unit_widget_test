
import 'package:dio/dio.dart';
import 'package:flutter_test_sample/network/api_client.dart';

import '../../model/sample_response.dart';
import '../../network/api_result.dart';
import '../../network/error_handler.dart';

class PostsRepository {
  final ApiClient apiClient;

PostsRepository(this.apiClient);

Future<ApiResult<List<SampleResponse>?>> getPosts() async {
  List<SampleResponse>? response;
  try {
    response = await apiClient.getPost();

    return ApiResult()
      ..setData(response);
  } catch (e, _) {
    //checking if the exception from dio then set the dio otherwise set other exception
    if (e is DioException) {
      return ApiResult()
        ..setException(ErrorHandler.dioException(error: e),);
    }
    return ApiResult()
      ..setException(ErrorHandler.otherException(),);
  }
}}