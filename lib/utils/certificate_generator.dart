import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> generateCertificateOfEnrollmentPdf({
  required String studentName,
  required String lrn,
  required String grade,
  required String schoolYear,
  required DateTime dateIssued,
  String principalName = 'KIICHE P. NIETES, EdD',
  String principalTitle = 'School Principal',
  String? bannerLogoUrl, // Optional dynamic banner logo URL
}) async {
  final pdf = pw.Document();

  // Load the banner image - try dynamic logo first, then fallback to static
  pw.MemoryImage bannerImage;
  try {
    if (bannerLogoUrl != null && bannerLogoUrl.isNotEmpty) {
      // Try to load dynamic logo from URL
      final response = await http.get(Uri.parse(bannerLogoUrl));
      if (response.statusCode == 200) {
        bannerImage = pw.MemoryImage(response.bodyBytes);
      } else {
        throw Exception('Failed to load dynamic logo');
      }
    } else {
      throw Exception('No dynamic logo URL provided');
    }
  } catch (e) {
    // Fallback to static asset
    bannerImage = pw.MemoryImage(
      (await rootBundle.load('assets/logos/banner.png')).buffer.asUint8List(),
    );
  }

  final formattedDate =
      DateFormat("d'th' day of MMMM, yyyy").format(dateIssued);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Top content
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(bannerImage, width: 350),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Certificate of Enrollment',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 28),
                pw.Text('TO WHOM IT MAY CONCERN:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 24),
                pw.Text(
                  'This is certify that ',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: studentName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: ' with LRN: $lrn is a bonafide '),
                      pw.TextSpan(
                          text: grade,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      const pw.TextSpan(
                          text:
                              ' pupil of the above mentioned school for the '),
                      pw.TextSpan(
                          text: 'School Year $schoolYear',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      const pw.TextSpan(text: ' at '),
                      pw.TextSpan(
                        text: 'Oroquieta Seventh-Day Adventist School, Inc.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  'This certification is issued upon request of the individual concern for whatever purpose it may serve him/her best.',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 28),
                pw.Text(
                  'Issued on the $formattedDate at Oroquieta Seventh-Day Adventist School, Inc.',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
              ],
            ),
            // Bottom signature
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 24, right: 24),
              child: pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(principalName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(principalTitle,
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
