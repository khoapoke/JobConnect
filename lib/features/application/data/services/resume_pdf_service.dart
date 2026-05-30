import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/resume_content.dart';
import '../../domain/usecases/create_builder_resume_usecase.dart';

class ResumePdfService implements ResumePdfBuilder {
  const ResumePdfService();

  @override
  Future<Uint8List> buildPdf({
    required String title,
    required ResumeContent content,
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          pw.Text(
            content.fullName.isNotEmpty ? content.fullName : title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          if (content.professionalTitle.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child: pw.Text(
                content.professionalTitle,
                style: const pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          if (content.headline.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                content.headline,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (content.contactEmail.trim().isNotEmpty)
                pw.Text(content.contactEmail),
              if (content.location.trim().isNotEmpty) pw.Text(content.location),
            ],
          ),
          pw.SizedBox(height: 18),
          if (content.summary.trim().isNotEmpty) ...[
            _sectionTitle('Tóm tắt'),
            pw.Text(
              content.summary,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            pw.SizedBox(height: 14),
          ],
          if (content.skills.isNotEmpty) ...[
            _sectionTitle('Kỹ năng'),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: content.skills
                  .map(
                    (skill) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(999),
                        color: PdfColors.teal50,
                      ),
                      child: pw.Text(
                        skill,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 14),
          ],
          if (content.workExperiences.isNotEmpty) ...[
            _sectionTitle('Kinh nghiệm làm việc'),
            _bulletList(content.workExperiences),
            pw.SizedBox(height: 14),
          ],
          if (content.educations.isNotEmpty) ...[
            _sectionTitle('Học vấn'),
            _bulletList(content.educations),
            pw.SizedBox(height: 14),
          ],
          if (content.certificates.isNotEmpty) ...[
            _sectionTitle('Chứng chỉ'),
            _bulletList(content.certificates),
          ],
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.teal800,
        ),
      ),
    );
  }

  pw.Widget _bulletList(List<String> values) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child: pw.Text(
                      value,
                      style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
