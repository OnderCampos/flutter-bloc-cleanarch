import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/network/api_endpoints.dart';
import 'package:app_template/core/network/dio_client.dart';
import 'package:app_template/features/auth/data/datasources/auth_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late AuthRemoteDataSourceImpl dataSource;

  const email = 'person@example.com';
  const password = 'secure-password';

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    when(() => dioClient.dio).thenReturn(dio);
    dataSource = AuthRemoteDataSourceImpl(dioClient: dioClient);
  });

  test('AC-1.1 Successful login POST and response passthrough', () async {
    final responseData = <String, dynamic>{
      'token': 'token-123',
      'user': <String, dynamic>{'id': '42'},
    };
    final requestOptions = RequestOptions(path: ApiEndpoints.login);
    when(
      () => dio.post<dynamic>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: responseData,
        requestOptions: requestOptions,
        statusCode: 200,
      ),
    );

    final result = await dataSource.login(email: email, password: password);

    expect(result, responseData);
    verify(
      () => dio.post<dynamic>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      ),
    ).called(1);
  });

  test('AC-1.2 Dio HTTP error translation', () async {
    final requestOptions = RequestOptions(path: ApiEndpoints.login);
    final exception = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        data: {'message': 'Invalid credentials'},
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => throw exception);

    await expectLater(
      dataSource.login(email: email, password: password),
      throwsA(
        isA<ServerException>()
            .having((error) => error.message, 'message', 'Invalid credentials')
            .having((error) => error.statusCode, 'statusCode', 401),
      ),
    );
  });

  test('AC-1.3 Dio timeout translation', () async {
    final exception = DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.login),
      type: DioExceptionType.connectionTimeout,
    );
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => throw exception);

    await expectLater(
      dataSource.login(email: email, password: password),
      throwsA(
        isA<ServerException>()
            .having(
              (error) => error.message,
              'message',
              'The request took too long. Please try again.',
            )
            .having((error) => error.statusCode, 'statusCode', 408),
      ),
    );
  });

  test('AC-1.4 Unexpected non-Dio failure translation', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => throw StateError('mock failure'));

    await expectLater(
      dataSource.login(email: email, password: password),
      throwsA(
        isA<ServerException>()
            .having((error) => error.statusCode, 'statusCode', 500)
            .having(
              (error) => error.message,
              'message',
              startsWith('Unexpected error: Bad state: mock failure'),
            ),
      ),
    );
  });
}
