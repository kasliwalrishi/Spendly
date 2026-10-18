import 'dart:io';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  XFile? _imageFile;
  String _extractedText = '';
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  late final GoogleGemini googleGemini;

  bool _isAnalyzing = false;
  Map<String, dynamic>? _analyzedData;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      AppLogger.error('GEMINI_API_KEY not found in environment');
      throw Exception('GEMINI_API_KEY not configured');
    }
    googleGemini = GoogleGemini(apiKey: apiKey);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _extractedText = '';
        });
        _performOcr();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _performOcr() async {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(_imageFile!.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Combine all text blocks
      final StringBuffer extractedText = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText.writeln(line.text);
        }
      }

      setState(() {
        _extractedText = extractedText.toString();
      });

      // Add this line to analyze the extracted text
      await _analyzeWithGemini(_extractedText);

      // Don't forget to close the recognizer
      await textRecognizer.close();
    } catch (e) {
      print('OCR Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR processing failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _analyzeWithGemini(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analyzedData = null;
    });

    try {
      AppLogger.debug('Sending request to Gemini API...');
      AppLogger.debug(
          'API Key length: ${dotenv.env['GEMINI_API_KEY']?.length ?? 0}');

      const prompt = '''
You are a receipt analyzer from OCR text. Extract the following information from the receipt text:
1. Store name
2. Date of purchase
3. Total amount
4. Items purchased with their individual prices and quantities
5. Payment method used

Return the data in the following JSON format:
{
  "store": "store name or null if not found",
  "date": "purchase date or null if not found",
  "total": "total amount or null if not found",
  "items": [
    {
      "name": "item name",
      "price": "item price",
      "quantity": "quantity or null if not specified"
    }
  ],
  "paymentMethod": "payment method or null if not found"
}

If any field is not found in the receipt, use null for that field.
Only return valid JSON, no additional text.
Receipt text to analyze:
''';

      final response = await googleGemini.generateFromText(
        '''$prompt\n$text''',
      );

      final jsonResponse = json.decode(response.text);
      AppLogger.success('Gemini API Response: $jsonResponse');

      setState(() {
        _analyzedData = jsonResponse;
      });
    } catch (e) {
      AppLogger.error('Gemini API error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Text Extractor'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_imageFile != null)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight * 0.4,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Image Pick Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera),
                          label: const Text('Camera'),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text('Gallery'),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Processing Indicator
                  if (_isProcessing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Extracted Text Section
                  if (_extractedText.isNotEmpty || !_isProcessing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Extracted Text:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _extractedText.isEmpty
                                ? 'No text extracted yet'
                                : _extractedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                  // Add this new widget inside the Column in build method, after the extracted text section
                  if (_analyzedData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Card(
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _analyzedData!['store'] ??
                                          'Unknown Store',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 2),

                                // Date and Receipt Info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date: ${_analyzedData!['date'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Items List
                                const Text(
                                  'Items:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...(_analyzedData!['items'] as List)
                                    .map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              // Quantity
                                              if (item['quantity'] != null)
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    item['quantity'].toString(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),

                                              // Item name
                                              Expanded(
                                                child: Text(
                                                  item['name'] ??
                                                      'Unknown Item',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),

                                              // Price
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 80,
                                                child: Text(
                                                  item['price'] ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),

                                // Add a summary section before the total
                                if (_analyzedData!['items']
                                    .any((item) => item['quantity'] != null))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Items: ${_analyzedData!['items'].fold(0, (sum, item) => sum + (int.tryParse(item['quantity']?.toString() ?? '1') ?? 1))}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(thickness: 1),
                                ),

                                // Total and Payment Method
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _analyzedData!['total'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.payment, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _analyzedData!['paymentMethod'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Add loading indicator while analyzing
                  if (_isAnalyzing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Analyzing receipt...'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
