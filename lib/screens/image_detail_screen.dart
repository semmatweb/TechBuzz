import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ImageDetailScreen extends StatelessWidget {
  const ImageDetailScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    Future<File> downloadImage() async {
      final Dio dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      String appPath = (await getTemporaryDirectory()).path;
      String imagePath = path.basename(imageUrl);

      String localPath = path.join(appPath, imagePath);

      File imageFile = await File(localPath).create();
      return imageFile.writeAsBytes(response.data);
    }

    void saveToGallery() async {
      downloadImage().then((value) async {
        await GallerySaver.saveImage(
          value.path,
          albumName: FlavorConfig.instance.variables['appName'],
        );
      }).catchError((onError) {
        debugPrint(onError);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.black.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              saveToGallery();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved to Gallery'),
                  backgroundColor: Colors.black,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: PhotoView(
        imageProvider: Image.network(imageUrl).image,
      ),
    );
  }
}
