import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentEditorUserProvider = StateProvider<List<String>>((ref) {
  return [];
});