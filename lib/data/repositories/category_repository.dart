import 'package:style_house/core/config/supabase_config.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/category_model.dart';

class CategoryRepository {
  Future<List<CategoryModel>> getCategories({String? gender}) async {
    final client = SupabaseConfig.client;

    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        var query = client.from('categories').select('*').order('display_order');
        if (gender != null && gender != 'all') {
          query = client.from('categories').select('*').or('gender.eq.$gender,gender.eq.all').order('display_order');
        }
        final response = await query;
        return (response as List<dynamic>)
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback to sample data on error
      }
    }

    // Fallback/Mock mode
    var list = SampleData.categories;
    if (gender != null && gender != 'all') {
      list = list.where((c) => c.gender == gender || c.gender == 'all').toList();
    }
    return list;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final response = await client.from('categories').select('*').eq('id', id).maybeSingle();
        if (response != null) {
          return CategoryModel.fromJson(response);
        }
      } catch (_) {}
    }

    try {
      return SampleData.categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
