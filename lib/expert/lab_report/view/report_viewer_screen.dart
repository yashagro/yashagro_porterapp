import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openPdf(String url) async {
  final dir = await getTemporaryDirectory();
  final filePath = '${dir.path}/report.pdf';

  await Dio().download(url, filePath);
  await OpenFile.open(filePath);
}
