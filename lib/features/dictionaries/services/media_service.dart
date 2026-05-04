// ============================================================
// Fichier : lib/features/dictionaries/services/media_service.dart
// Description : Service de gestion des médias locaux (images et audio).
//               Utilise image_picker pour les photos et record pour l'audio.
//               Tous les fichiers sont stockés dans getApplicationDocumentsDirectory().
//               100% hors ligne — aucun réseau.
// ============================================================

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Fournit le [MediaService] via Riverpod.
final mediaServiceProvider = Provider<MediaService>((_) => MediaService());

/// Service centralisé pour la gestion des images et des enregistrements audio.
/// Sauvegarde les fichiers dans le répertoire local de l'application.
class MediaService {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;

  // ---------------------------------------------------------------------------
  // Répertoires
  // ---------------------------------------------------------------------------

  /// Répertoire local dédié aux images (créé si absent).
  Future<Directory> _mediaDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docsDir.path, 'orphotonie', 'media'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Répertoire local dédié aux enregistrements audio.
  Future<Directory> _audioDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docsDir.path, 'orphotonie', 'audio'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  /// Ouvre la galerie, copie l'image sélectionnée localement.
  /// Retourne le chemin relatif stocké dans [Words.imagePath], ou null si annulé.
  Future<String?> pickImageFromGallery() =>
      _pickImage(ImageSource.gallery);

  /// Ouvre l'appareil photo, capture une photo et la copie localement.
  /// Retourne le chemin relatif, ou null si annulé.
  Future<String?> pickImageFromCamera() =>
      _pickImage(ImageSource.camera);

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (xFile == null) return null;

      final dir = await _mediaDir();
      final ext = p.extension(xFile.path).isNotEmpty
          ? p.extension(xFile.path)
          : '.jpg';
      final fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dest = File(p.join(dir.path, fileName));
      await dest.writeAsBytes(await xFile.readAsBytes());

      // Retourne le chemin relatif (par rapport aux documents)
      final docsDir = await getApplicationDocumentsDirectory();
      return p.relative(dest.path, from: docsDir.path);
    } catch (e) {
      throw Exception('Impossible de sélectionner l\'image : $e');
    }
  }

  /// Retourne le chemin absolu d'une image à partir de son chemin relatif.
  Future<String> absoluteImagePath(String relativePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, relativePath);
  }

  /// Supprime un fichier image local (chemin relatif). Ignore si absent.
  Future<void> deleteImage(String relativePath) async {
    try {
      final abs = await absoluteImagePath(relativePath);
      final file = File(abs);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Audio — enregistrement
  // ---------------------------------------------------------------------------

  /// Démarre l'enregistrement audio dans un fichier .m4a local.
  /// Lance une exception si le micro n'est pas disponible.
  Future<void> startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception(
        'Permission microphone refusée. Vérifiez les réglages de l\'appareil.',
      );
    }
    final dir = await _audioDir();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final path = p.join(dir.path, fileName);
    await _recorder.start(const RecordConfig(), path: path);
    _isRecording = true;
  }

  /// Arrête l'enregistrement et retourne le chemin relatif du fichier .m4a.
  /// Retourne null si aucun enregistrement n'était en cours.
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;
    if (path == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    return p.relative(path, from: docsDir.path);
  }

  /// Indique si un enregistrement est en cours.
  bool get isRecording => _isRecording;

  // ---------------------------------------------------------------------------
  // Audio — lecture
  // ---------------------------------------------------------------------------

  /// Joue l'enregistrement audio à partir de son chemin relatif.
  Future<void> playAudio(String relativePath) async {
    try {
      final abs = await absoluteAudioPath(relativePath);
      await _player.stop();
      await _player.play(DeviceFileSource(abs));
    } catch (e) {
      throw Exception('Impossible de lire l\'audio : $e');
    }
  }

  /// Arrête la lecture audio en cours.
  Future<void> stopAudio() async {
    await _player.stop();
  }

  /// Retourne le chemin absolu d'un fichier audio.
  Future<String> absoluteAudioPath(String relativePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, relativePath);
  }

  /// Supprime un fichier audio local (chemin relatif). Ignore si absent.
  Future<void> deleteAudio(String relativePath) async {
    try {
      final abs = await absoluteAudioPath(relativePath);
      final file = File(abs);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  /// Libère les ressources.
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
