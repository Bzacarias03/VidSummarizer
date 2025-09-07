import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FileProcessor {
  Directory? tempDirectory;

  FileProcessor() {
    _getTemporaryDirectory();
  }

  Future<void> _getTemporaryDirectory() async {
    tempDirectory = await getTemporaryDirectory();
  }

  Future<File> getThumbnailFile({required String url}) async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HttpException("Error fetching image");
    }
    File thumbnailFile = File("${tempDirectory!.path}/thumbnail.png");
    await thumbnailFile.writeAsBytes(response.bodyBytes);
    return thumbnailFile;
  }

  Future<File> getSummaryFile({required String summary}) async {
    File summaryFile = File("${tempDirectory!.path}/summary.txt");
    await summaryFile.writeAsBytes(utf8.encode(summary));
    return summaryFile;
  }

  Future<File> getCaptionsFile({required String captions}) async {
    File captionsFile = File("${tempDirectory!.path}/captions.txt");
    await captionsFile.writeAsBytes(utf8.encode(captions));
    return captionsFile;
  }

  Future<String> getSummaryBody({required String summaryUrl}) async {
    http.Response response = await http.get(Uri.parse(summaryUrl));
    if (response.statusCode != 200) {
      throw HttpException("Error fetching summary");
    }
    return response.body;
  }
}