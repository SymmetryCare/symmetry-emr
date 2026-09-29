import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<String> extractTextFromPdf(String url) async {
  final response = await http.get(Uri.parse(url));
  final document = PdfDocument(inputBytes: response.bodyBytes);
  final extractor = PdfTextExtractor(document);

  String text = '';
  for (int i = 0; i < document.pages.count; i++) {
    text += await extractor.extractText(startPageIndex: i, endPageIndex: i);
  }
  document.dispose();

  return text;
}