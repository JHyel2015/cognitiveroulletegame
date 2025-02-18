import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/image_dao.dart';
import 'package:cognitiveroulletegame/models/saved_image.dart';

class ImageNotifier extends ChangeNotifier {
  final ImageDao _imageDao = ImageDao();
  List<SavedImage> _images = [];

  List<SavedImage> get images => _images;

  Future<void> init() async {
    _images = await _imageDao.getAllImages();
    notifyListeners();
  }

  Future<SavedImage?> getImageByName(String name) async {
    return await _imageDao.getImageByName(name);
  }

  Future<void> addImage(SavedImage image) async {
    await _imageDao.insert(image);
    _images = await _imageDao.getAllImages();
    notifyListeners();
  }

  Future<void> updateImage(SavedImage image) async {
    await _imageDao.updateImage(image);
    _images = await _imageDao.getAllImages();
    notifyListeners();
  }

  // get images list
  List<SavedImage> getAllImagesList() {
    return _images;
  }

  // delete image
  Future<void> deleteImageItem(SavedImage image) async {
    await _imageDao.deleteImage(image.name);
    _images = await _imageDao.getAllImages();
    notifyListeners();
  }

  Future<void> clearData() async {
    await _imageDao.clearData();

    notifyListeners();
  }

  Future<void> sync() async {
    notifyListeners();
  }
}
