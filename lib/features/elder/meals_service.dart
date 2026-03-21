import 'package:dio/dio.dart';
import 'package:caregiver/core/network/dio_client.dart';

import 'meal_item.dart';

class MealsService {
  Future<List<MealItem>> getTodayMeals(int elderId) async {
    try {
      final response = await DioClient.dio.get(
        '/api/v1/elder/meals/today/$elderId',
      );

      final List items = response.data['items'] ?? [];

      return items
          .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }
}