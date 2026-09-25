import 'package:image_picker/image_picker.dart';

import '../errors/failures.dart';

/// Wrapper `image_picker` untuk mode Gambar (PRD §4.1: screenshot WA/medsos).
class ImageProcessor {
  ImageProcessor({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile> pickFromGallery() => _pick(ImageSource.gallery);

  Future<XFile> pickFromCamera() => _pick(ImageSource.camera);

  Future<XFile> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) {
        throw const UnknownFailure('Pemilihan gambar dibatalkan.');
      }
      return file;
    } catch (e) {
      if (e is Failure) rethrow;
      throw const UnknownFailure(
        'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
      );
    }
  }
}
