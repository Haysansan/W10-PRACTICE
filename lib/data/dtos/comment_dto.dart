import '../../model/comment/comment.dart';

class CommentDto {
  static const String textKey = 'text';
  static const String artistIdKey = 'artistId';

  static Comment fromJson(String id, Map<String, dynamic> json) {
    assert(json[textKey] is String);
    assert(json[artistIdKey] is String);

    return Comment(id: id, text: json[textKey], artistId: json[artistIdKey]);
  }

  static Map<String, dynamic> toJson(String artistId, String text) {
    return {artistIdKey: artistId, textKey: text};
  }
}
