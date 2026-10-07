import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/shop_store.dart';

/// Helper to download, view, or share Athirai Gold & Jewellery Tax Receipt PDFs
class AthiraiReceiptHelper {
  /// Fetches backend ReportLab PDF or generates high-fidelity local luxury certificate & invoice
  static Future<Uint8List> getOrGenerateReceiptPdf(
    Map<String, dynamic> order,
  ) async {
    final orderId = order['order_id']?.toString() ?? 'ATH-ORD';

    // 1. Try fetching high-res official backend PDF
    try {
      final backendBytes = await ShopStore.session.downloadReceiptPdf(orderId);
      if (backendBytes != null && backendBytes.isNotEmpty) {
        return Uint8List.fromList(backendBytes);
      }
    } catch (e) {
      debugPrint('ReceiptHelper: Backend PDF fetch error: $e. Falling back to local PDF generator.');
    }

    // 2. Client-side fallback PDF generator with exact Royal Athirai styling
    return await _generateClientPdf(order);
  }

  /// Downloads & triggers device print/save dialog
  static Future<void> downloadAndPrintReceipt(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final invoiceNo = order['invoice_number']?.toString() ?? order['order_id']?.toString() ?? 'ATH-INV';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF041814),
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Preparing Receipt $invoiceNo...',
              style: const TextStyle(color: Color(0xFFF7F2E8), fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );

    try {
      final pdfBytes = await getOrGenerateReceiptPdf(order);

      await Printing.layoutPdf(
        name: '$invoiceNo.pdf',
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Could not open receipt: $e'),
        ),
      );
    }
  }

  /// High fidelity client-side luxury PDF generator
  static Future<Uint8List> _generateClientPdf(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final invoiceNo = order['invoice_number']?.toString() ?? 'INV-ATH-${order['order_id']}';
    final orderId = order['order_id']?.toString() ?? 'ATH-ORD';
    final productName = order['product_name']?.toString() ?? 'Royal Heritage Jewellery';
    final purity = order['metal_purity']?.toString() ?? '22K Gold (916 Hallmarked)';
    final weight = (order['weight_grams'] as num?)?.toDouble() ?? 10.0;
    final totalAmount = (order['total_amount'] as num?)?.toInt() ?? 0;
    final coinsUsed = (order['coins_used'] as num?)?.toInt() ?? (totalAmount * 100);
    final deliveryName = order['delivery_name']?.toString() ?? 'Royal Patron';
    final deliveryPhone = order['delivery_phone']?.toString() ?? '+91 98765 43210';
    final deliveryAddress = order['delivery_address']?.toString() ?? 'Athirai Vault Delivery';
    final createdAt = order['created_at']?.toString() ?? DateTime.now().toIso8601String();

    final goldPdfColor = PdfColor.fromInt(0xFFC7A45B);
    final darkGreenPdfColor = PdfColor.fromInt(0xFF07211B);
    final creamBg = PdfColor.fromInt(0xFFFCFBF7);
    final mutedText = PdfColor.fromInt(0xFF55605C);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: creamBg,
              border: pw.Border.all(color: goldPdfColor, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header: Royal Temple Crest & Title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ATHIRAI',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: darkGreenPdfColor,
                            letterSpacing: 3,
                          ),
                        ),
                        pw.Text(
                          'TIMELESS JEWELS  *  HERITAGE ATELIER',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: goldPdfColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'T. Nagar, Chennai - 600017, Tamil Nadu, India',
                          style: pw.TextStyle(fontSize: 8, color: mutedText),
                        ),
                        pw.Text(
                          'GSTIN: 33AAACA0101M1Z1 | BIS Hallmark Lic: HM/TN/2026/089',
                          style: pw.TextStyle(fontSize: 8, color: mutedText),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: darkGreenPdfColor,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            'ORIGINAL TAX INVOICE',
                            style: pw.TextStyle(
                              color: goldPdfColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text('Invoice: $invoiceNo', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Order ID: $orderId', style: pw.TextStyle(fontSize: 9, color: mutedText)),
                        pw.Text('Date: ${createdAt.substring(0, 10)}', style: pw.TextStyle(fontSize: 9, color: mutedText)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(color: goldPdfColor, thickness: 1),
                pw.SizedBox(height: 12),

                // Patron & Delivery Address
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DELIVERY DESTINATION / PATRON',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: darkGreenPdfColor,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(deliveryName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Phone: $deliveryPhone', style: pw.TextStyle(fontSize: 8.5, color: mutedText)),
                          pw.Text(deliveryAddress, style: pw.TextStyle(fontSize: 8.5, color: mutedText)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'PAYMENT SETTLEMENT',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: darkGreenPdfColor,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Settlement Method: AUG Coins', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Coin Rate: 1 Rupee = 100 AUG Coins', style: pw.TextStyle(fontSize: 8.5, color: goldPdfColor)),
                          pw.Text('Status: Confirmed & Paid in Full', style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF1E7E34))),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                // Table of purchased jewellery
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0DDD5), width: 0.8),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: darkGreenPdfColor),
                      children: [
                        _tableHeader('Item Description'),
                        _tableHeader('Purity / Hallmark'),
                        _tableHeader('Gross Wt'),
                        _tableHeader('AUG Coins Paid'),
                        _tableHeader('Amount (INR)'),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _tableCell(productName, isBold: true),
                        _tableCell(purity),
                        _tableCell('${weight.toStringAsFixed(2)} g'),
                        _tableCell('$coinsUsed AUG Coins'),
                        _tableCell('INR ${totalAmount.toString()}'),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 14),

                // Summary Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 240,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFF4EFE6),
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: goldPdfColor, width: 0.8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total AUG Coins:', style: pw.TextStyle(fontSize: 9)),
                              pw.Text('$coinsUsed Coins', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('INR Valuation:', style: pw.TextStyle(fontSize: 9)),
                              pw.Text('INR $totalAmount', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Divider(color: goldPdfColor, thickness: 0.5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Paid:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkGreenPdfColor)),
                              pw.Text('INR $totalAmount (100% AUG Coins)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: darkGreenPdfColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // Authenticity Hallmark Certificate footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF07211B),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'GUARANTEE OF AUTHENTICITY & PURITY',
                            style: pw.TextStyle(
                              color: goldPdfColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Every Athirai jewel is laser hallmarked under Bureau of Indian Standards (BIS) regulations.',
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 7),
                          ),
                        ],
                      ),
                      pw.Text(
                        '[BIS HALLMARK CERTIFIED]',
                        style: pw.TextStyle(
                          color: goldPdfColor,
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _tableHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColor.fromInt(0xFFD4AF37),
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
