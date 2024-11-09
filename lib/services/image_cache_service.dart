import 'dart:io';
import 'package:cognitiveroulletegame/data/image_dao.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cognitiveroulletegame/models/saved_image.dart';

class ImageCacheService with ChangeNotifier {
  ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
  final ImageDao _imageDao = ImageDao();
  List<SavedImage> _cachedImage = [];

  List<SavedImage> get cachedImage => _cachedImage;
  final Map<String, String> _cachedImages = {};
  // Map para almacenar rutas locales

  Future<void> init() async {
    _cachedImage = await _imageDao.getAllImages();
    notifyListeners();
  }

  Future<void> getFiles({bool sync = false}) async {
    try {
      ListResult result = await FirebaseStorage.instance.ref().listAll();

      await downloadAndCacheImagesInParallel(result.items, sync: sync);
    } catch (e) {
      print('Error al obtener los archivos del bucket de Firebase Storage: $e');
    }
    print('Termino la descarga');
  }

  // Descargar y almacenar una imagen
  Future<void> downloadAndCacheImage(String url, String imageName,
      {bool sync = false}) async {
    try {
      // Obtener el directorio local
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$imageName';
      SavedImage savedImage = SavedImage(
        name: imageName,
        imagePath: savePath,
      );

      // Verificar si la imagen ya está almacenada localmente
      if (_cachedImage.contains(savedImage)) {
        if (sync) {
          print('Descargando $imageName en $savePath');
          Dio dio = Dio();
          await dio.download(url, savePath);
        }
        return;
      }

      print('Descargando $imageName en $savePath');
      // if (_cachedImages.containsKey(url)) return;

      // Descargar el enlace de Firebase
      // String url =
      //     await FirebaseStorage.instance.ref(firebasePath).getDownloadURL();

      // Descargar la imagen con Dio y almacenarla localmente
      Dio dio = Dio();
      await dio.download(url, savePath);

      // Agregar la ruta local al Map
      _cachedImages[imageName] = savePath;
      await _imageDao.insert(savedImage);
      _cachedImage = await _imageDao.getAllImages();
      notifyListeners();
    } catch (e) {
      print('Error al descargar imagen: $e');
    }
  }

  // Descargar y almacenar imágenes en paralelo con progreso
  Future<void> downloadAndCacheImagesInParallel(List<Reference> firebasePaths,
      {bool sync = false}) async {
    int totalImages = firebasePaths.length;
    int downloadedImages = 0;

    await Future.wait(firebasePaths.map((entry) async {
      String downloadURL = await entry.getDownloadURL();
      await downloadAndCacheImage(downloadURL, entry.name, sync: sync);

      // Actualizar el progreso después de descargar cada imagen
      downloadedImages++;
      progressNotifier.value = downloadedImages / totalImages;
    }));

    // Restablecer el progreso al completar todas las descargas
    progressNotifier.value = 1.0;
  }

  // Obtener la imagen en caché
  String? getCachedImage(String imageName) {
    return _cachedImage
        .firstWhere((savedImage) => savedImage.name == imageName)
        .imagePath;
  }

  SavedImage? getImage(String name) {
    return _cachedImage.firstWhere((image) => image.name == name);
  }

  Future<SavedImage?> getImageByName(String name) async {
    return await _imageDao.getImageByName(name);
  }

  List<SavedImage> getFilteredImages(String filter) {
    List<SavedImage> filteredImages = [];

    filteredImages = _cachedImage
        .where(
            (image) => image.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    return filteredImages;
  }
}
