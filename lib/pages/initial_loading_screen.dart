import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/on_boarding_page.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/services/image_cache_service.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  final userPreferences = UserPreferences();

  final List<String> imageUrls = [];
  // Map<String, String> _imageName = Map<String, String>();
  // Map<String, String> _imageNameTmp = Map<String, String>();

  final List<Map<String, String>> imagesToCache = [
    // {'url': 'images/image1.jpg', 'imageName': 'image1.jpg'},
    // {'url': 'images/image2.jpg', 'imageName': 'image2.jpg'},
    // Añadir más imágenes según sea necesario
  ];

  Future<void> _getFiles() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref().listAll();
      for (var ref in result.items) {
        String downloadURL = await ref.getDownloadURL();
        Map<String, String> imageName = Map<String, String>();
        imageName['url'] = downloadURL;
        imageName['imageName'] = ref.name;
        imagesToCache.add(imageName);
        // imageUrls.add(downloadURL);
        // _imageName[ref.name] = downloadURL;
      }
    } catch (e) {
      print('Error al obtener los archivos del bucket de Firebase Storage: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getFiles().whenComplete(() {
    //   _cacheImagesOnStartup();
    //   print('Termino la descarga');
    // });
    _cacheImagesGetFiles();

    print(imagesToCache);
  }

  Future<void> _cacheImagesGetFiles() async {
    final imageCacheService =
        Provider.of<ImageCacheService>(context, listen: false);

    await imageCacheService.getFiles();

    userPreferences.areImagesDownloaded = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            userPreferences.firstTime ? OnBoardingPage() : AuthPage(),
      ),
    );
  }

  Future<void> _cacheImagesOnStartup() async {
    final imageCacheService =
        Provider.of<ImageCacheService>(context, listen: false);

    for (var image in imagesToCache) {
      await imageCacheService.downloadAndCacheImage(
        image['url']!,
        image['imageName']!,
      );
    }

    userPreferences.areImagesDownloaded = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            userPreferences.firstTime ? OnBoardingPage() : AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedImageNotifier = Provider.of<ImageCacheService>(
      context,
    );

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 25,
            ),
            Text('Estamos preparando todo para ti'),
            Text("Descargando archivos..."),
            SizedBox(height: 20),
            ValueListenableBuilder<double>(
              valueListenable: savedImageNotifier.progressNotifier,
              builder: (context, progress, child) {
                return LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.0,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     future: userPreferences.firstTime
  //         ? _getFiles().whenComplete(() =>
  //             Provider.of<ImageCacheService>(context, listen: false)
  //                 .loadImages(_imageName))
  //         : Provider.of<ImageCacheService>(context).loadImages(_imageName),
  //     // Provider.of<ImageCacheService>(context, listen: false)
  //     //     .loadImages(imageUrls, context);

  //     builder: (context, snapshot) {
  //       print(snapshot.connectionState);
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Scaffold(
  //           body: Center(
  //               child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               CircularProgressIndicator(),
  //               SizedBox(
  //                 height: 25,
  //               ),
  //               Text('Estamos preparando todo para ti')
  //             ],
  //           )),
  //         );
  //       } else {
  //         return userPreferences.firstTime ? OnBoardingPage() : AuthPage();
  //       }
  //     },
  //   );
  // }
}
