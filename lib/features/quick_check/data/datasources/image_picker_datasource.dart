import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/repositories/image_picker_service.dart';

/// Implementasi picker gambar Quick Check memakai `image_picker`.
///
/// Batal memilih mengembalikan `null` agar UI tetap di state idle tanpa error.
/// File dibaca ke bytes di sini supaya domain hanya menerima value object yang
/// sudah tervalidasi sebagian.
class ImagePickerDatasource implements ImagePickerService {
  ImagePickerDatasource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ImageAttachment?> pickImage(ImagePickSource source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          ImagePickSource.gallery => ImageSource.gallery,
          ImagePickSource.camera => ImageSource.camera,
        },
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const UnknownFailure(
          'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
        );
      }
      return ImageAttachment(
        bytes: bytes,
        mimeType: _mimeFromPath(file.path),
        fileName: _fileNameFromPath(file.path),
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw const UnknownFailure(
        'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
      );
    }
  }

  String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized
        .split('/')
        .lastWhere((part) => part.isNotEmpty, orElse: () => 'gambar.png');
    return name;
  }
}
