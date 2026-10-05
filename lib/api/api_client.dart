import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if(kDebugMode) {
      log('Token: $token');
    }
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(_) {}
    updateHeader(
        token, addressModel?.zoneIds,
        sharedPreferences.getString(AppConstants.languageCode), addressModel?.latitude,
        addressModel?.longitude
    );
  }

  Map<String, String> updateHeader(String? token, List<int>? zoneIDs, String? languageCode, String? latitude, String? longitude, {bool setHeader = true}) {
    Map<String, String> header = {};
    if(zoneIDs != null) {
      header.addAll({AppConstants.zoneId: jsonEncode(zoneIDs)});
    }
    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.latitude: latitude != null ? jsonEncode(latitude) : '0',
      AppConstants.longitude: longitude != null ? jsonEncode(longitude) : '0',
      'Authorization': 'Bearer $token',
      // "ngrok-skip-browser-warning": 'true', ///TODO: Remove this when the backend will be in production
    });
    if(setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Map<String, String> getHeader() => _mainHeaders;

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers, bool handleError = true, bool showToaster = false}) async {
    try {
      if(kDebugMode) {
        debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      }
      log(token ?? '');
      http.Response response = await http.get(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError, showToaster: showToaster);
    } catch (e) {
      if (kDebugMode) {
        print('----------------${e.toString()}');
      }
      return  Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if(kDebugMode) {
        debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
        log('====> API Body: $body');
      }
      http.Response response = await http.post(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, List<MultipartDocument> otherFile, {Map<String, String>? headers, bool handleError = true, bool fromChat = false}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body with ${multipartBody.length} and multipart ${otherFile.length}');
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          if(foundation.kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            http.MultipartFile part = http.MultipartFile(
              multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
              filename: basename(multipart.file!.path), contentType: MediaType('image', 'jpg'),
            );
            request.files.add(part);
          }else {
            File file = File(multipart.file!.path.toString());
            request.files.add(http.MultipartFile(
              multipart.key, file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last,
            ));
          }
        }
      }

      if(otherFile.isNotEmpty){
        for(MultipartDocument file in otherFile){

          if(foundation.kIsWeb) {

            if(fromChat) {
              PlatformFile platformFile = file.file!.files.first;
              request.files.add(
                http.MultipartFile.fromBytes(
                  'image[]',
                  platformFile.bytes!,
                  filename: platformFile.name,
                ),
              );
            } else {
              PlatformFile platformFile = file.file!.files.first;

              if(platformFile.bytes != null) {
                request.files.add(
                  http.MultipartFile.fromBytes(
                    file.key,
                    platformFile.bytes!,
                    filename: platformFile.name,
                    contentType: _getMediaType(platformFile.name),
                  ),
                );
                log('====> Added file using bytes: ${platformFile.name}');
              }
              else if(platformFile.readStream != null) {
                try {
                  List<int> bytes = [];
                  await for (var chunk in platformFile.readStream!) {
                    bytes.addAll(chunk);
                  }

                  Uint8List fileBytes = Uint8List.fromList(bytes);

                  request.files.add(
                    http.MultipartFile.fromBytes(
                      file.key,
                      fileBytes,
                      filename: platformFile.name,
                      contentType: _getMediaType(platformFile.name),
                    ),
                  );
                  log('====> Added file using stream (converted to bytes): ${platformFile.name}, size: ${fileBytes.length}');
                } catch (e) {
                  log('ERROR reading stream for ${platformFile.name}: $e');
                }
              }
            }
          } else {
            File other = File(file.file!.files.single.path!);
            Uint8List list0 = await other.readAsBytes();
            var part = http.MultipartFile(file.key, other.readAsBytes().asStream(), list0.length, filename: basename(other.path));
            request.files.add(part);
          }
        }
      }

      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  MediaType? _getMediaType(String filename) {
    String extension = filename.split('.').last.toLowerCase();

    Map<String, String> mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };

    String? mimeType = mimeTypes[extension];
    if (mimeType != null) {
      List<String> parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }

    return null;
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if(kDebugMode) {
        debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
        debugPrint('====> API Body: $body');
      }
      http.Response response = await http.put(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if(kDebugMode) {
        debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri, bool handleError, {bool showToaster = false}) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    }catch(_) {}
    Response response0 = Response(
      body: body ?? response.body, bodyString: response.body.toString(),
      request: Request(headers: response.request!.headers, method: response.request!.method, url: response.request!.url),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(response0.statusCode != 200 && response0.body != null && response0.body is !String) {
      if(response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: errorResponse.errors![0].message);
      }else if(response0.body.toString().startsWith('{message')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      }else if(response0.body.toString().startsWith('{errors: {message:')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['errors']['message']);
      }
    }else if(response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if(kDebugMode) {
      if(response0.statusCode == 500) {
        debugPrint('====> API Response: [${response0.statusCode}] $uri\n${(response0.body.toString().substring(0, 500))}');
      } else {
        debugPrint('====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
      }
    }
    if(handleError) {
      if(response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0, showToaster: showToaster);
        return response0;
      }
    } else {
      return response0;
    }
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class MultipartDocument {
  String key;
  FilePickerResult? file;
  MultipartDocument(this.key, this.file);
}


class ErrorResponse {
  List<Errors>? _errors;

  List<Errors>? get errors => _errors;

  ErrorResponse({
    List<Errors>? errors}){
    _errors = errors;
  }

  ErrorResponse.fromJson(dynamic json) {
    if (json["errors"] != null) {
      _errors = [];
      json["errors"].forEach((v) {
        _errors!.add(Errors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_errors != null) {
      map["errors"] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}


class Errors {
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Errors({
    String? code,
    String? message}){
    _code = code;
    _message = message;
  }

  Errors.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    return map;
  }

}