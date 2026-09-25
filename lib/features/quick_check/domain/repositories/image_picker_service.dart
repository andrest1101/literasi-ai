import '../entities/image_attachment.dart';

/// Sumber pengambilan gambar.
enum ImagePickSource { gallery, camera }

/// Kontrak picker gambar Quick Check: dapat di-fake di widget test.
///
/// Implementasi nyata memakai `image_picker`; UI tidak pernah memanggil
/// plugin langsung agar tetap testable dan sesuai Clean Architecture.
abstract class ImagePickerService {
  Future<ImageAttachment?> pickImage(ImagePickSource source);
}
