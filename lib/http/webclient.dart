import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/models/request_data.dart';
import 'package:http_interceptor/models/response_data.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print(data.statusCode);
    return data;
  }
}

void findAll() async {
  Client client = InterceptedClient.build(interceptors: [
        LoggingInterceptor(),
  ]);
  final Response response =
      await client.get(Uri.parse('http://192.168.1.80:8080/transactions'));
}
