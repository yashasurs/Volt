import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class OCRRemoteDataSource {
  Future<TransactionModel> extractTransactionFromImage({
    required String token,
    required File imageFile,
  });
}

class OCRRemoteDataSourceImpl implements OCRRemoteDataSource {
  final Dio dio;

  OCRRemoteDataSourceImpl(this.dio);

  @override
  Future<TransactionModel> extractTransactionFromImage({
    required String token,
    required File imageFile,
  }) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiConstants.ocrImagesToTextEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        try {
          return TransactionModel.fromJson(response.data);
        } catch (e) {
          throw ServerException('Failed to parse OCR response: $e');
        }
      } else {
        throw const ServerException('Failed to extract transaction from image');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 400) {
        throw ServerException(
          e.response?.data['detail'] ?? 'Invalid image file',
        );
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }
}

