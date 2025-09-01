import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api/common_api.dart';

class HttpRequest {
  static final HttpRequest _instance = HttpRequest._internal();
  late final Dio _dio;

  factory HttpRequest() => _instance;

  HttpRequest._internal() {
    // 初始化Dio实例
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 添加日志拦截器
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => debugPrint('🌐 $log'),
      ),
    );

    // 添加错误处理拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('❌ 请求错误: ${_handleError(error)}');
          handler.next(error);
        },
      ),
    );
  }

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // 添加默认User-Agent到headers中（仅当未设置时）
      final opts = options ?? Options();
      opts.headers ??= {};
      if (!opts.headers!.containsKey('User-Agent')) {
        opts.headers!['User-Agent'] = CommonApi.bangumiUserAgent;
      }

      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // 添加默认User-Agent到headers中（仅当未设置时）
      final opts = options ?? Options();
      opts.headers ??= {};
      if (!opts.headers!.containsKey('User-Agent')) {
        opts.headers!['User-Agent'] = CommonApi.bangumiUserAgent;
      }

      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // 添加默认User-Agent到headers中（仅当未设置时）
      final opts = options ?? Options();
      opts.headers ??= {};
      if (!opts.headers!.containsKey('User-Agent')) {
        opts.headers!['User-Agent'] = CommonApi.bangumiUserAgent;
      }

      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // 添加默认User-Agent到headers中（仅当未设置时）
      final opts = options ?? Options();
      opts.headers ??= {};
      if (!opts.headers!.containsKey('User-Agent')) {
        opts.headers!['User-Agent'] = CommonApi.bangumiUserAgent;
      }

      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      // 添加默认User-Agent到headers中（仅当未设置时）
      final opts = options ?? Options();
      opts.headers ??= {};
      if (!opts.headers!.containsKey('User-Agent')) {
        opts.headers!['User-Agent'] = CommonApi.userAgent;
      }

      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: opts,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 错误处理
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '请求超时';
      case DioExceptionType.receiveTimeout:
        return '响应超时';
      case DioExceptionType.badResponse:
        return '服务器错误: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      default:
        return '未知错误: ${error.message}';
    }
  }

  /// 获取Dio实例（用于高级配置）
  Dio get dio => _dio;
}

// 全局实例
final httpRequest = HttpRequest();
