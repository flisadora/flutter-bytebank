import 'dart:convert';

import 'package:bytebank_persistence/models/contact.dart';
import 'package:bytebank_persistence/models/transaction.dart';
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

final Client client = InterceptedClient.build(interceptors: [
  LoggingInterceptor(),
]);

const String baseUrl = 'http://192.168.1.80:8080/transactions';

Future<List<Transaction>> findAll() async {
  final Response response =
      await client.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 5));
  final List<dynamic> decodedJson = jsonDecode(response.body);
  final List<Transaction> transactions = [];
  for (Map<String, dynamic> transactionJson in decodedJson) {
    final Map<String, dynamic> contactJason = transactionJson['contact'];
    final Transaction transaction = Transaction(transactionJson['value'],
        Contact(0, contactJason['name'], contactJason['accountNumber']));
    transactions.add(transaction);
  }
  return transactions;
}

Future<Transaction> save(Transaction transaction) async {
  final Map<String, dynamic> transactionMap = {
    'value' : transaction.value,
    'contact' : {
      'name' : transaction.contact.name,
      'accountNumber' : transaction.contact.accountNumber
    }
  };
  final String transactionJson = jsonEncode(transactionMap);

  final Response response = await client.post(
    Uri.parse(baseUrl),
    headers: {
      'Content-type': 'application/json',
      'password' : '1000',
    },
    body: transactionJson
  );
  
  Map<String, dynamic> json = jsonDecode(response.body);
  final Map<String, dynamic> contactJason = json['contact'];
  return Transaction(json['value'],
      Contact(0, contactJason['name'], contactJason['accountNumber']));
}
