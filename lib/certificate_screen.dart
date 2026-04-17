import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'api_service.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _loading = true;
  String _userName = 'Patient';
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _loadUserAndGeneratePdf();
  }

  Future<void> _loadUserAndGeneratePdf() async {
    try {
      final me = await ApiService.getMe();
      if (me['success'] == true && me['user'] != null) {
        _userName = me['user']['name']?.toString() ?? 'Patient';
      }
    } catch (e) {
      // Ignore API error, default to 'Patient'
    }

    final pdfBytes = await _generateCertificatePdf(_userName);

    if (mounted) {
      setState(() {
        _pdfBytes = pdfBytes;
        _loading = false;
      });
    }
  }

  Future<Uint8List> _generateCertificatePdf(String userName) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.blue800,
                width: 10,
              ),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.blue400,
                  width: 3,
                ),
              ),
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'CERTIFICATE OF APPRECIATION',
                    style: pw.TextStyle(
                      fontSize: 42,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'This is proudly presented to',
                    style: pw.TextStyle(
                      fontSize: 24,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 25),
                  pw.Text(
                    userName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 38,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 400,
                    child: pw.Divider(color: PdfColors.grey400, thickness: 1),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'For taking the initial step towards prioritizing mental health and\nwell-being by downloading and engaging with ManoVeda.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 20,
                      lineSpacing: 5,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                  pw.SizedBox(height: 50),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 180,
                            child: pw.Divider(color: PdfColors.black, thickness: 1.5),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Team ManoVeda',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificate'),
        backgroundColor: const Color(0xFF4A148C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pdfBytes != null
              ? SfPdfViewer.memory(_pdfBytes!)
              : const Center(child: Text('Failed to generate certificate')),
    );
  }
}
