import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aadi/utils/firebase_monitoring_services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class OpenAIService {
  static final OpenAIService instance = OpenAIService._internal();
  final _monitoring = FirebaseMonitoringService.instance;
  String? _apiKey;

  // Maximum dimensions for input images
  static const int maxImageDimension = 1024;
  static const int maxFileSize = 4 * 1024 * 1024; // 4MB

  OpenAIService._internal();

  Future<void> initialize(String apiKey) async {
    await _monitoring.trackOperation(
      name: 'openai_initialize',
      operation: () async {
        _apiKey = apiKey;
      },
    );
  }

  /// Generate an image from a text prompt
  Future<Uint8List> generateImageFromText({
    required String prompt,
    String model = 'dall-e-2',
    String size = '512x512',
    String quality = 'standard',
    String style = 'vivid',
    int n = 1,
  }) async {
    if (_apiKey == null) {
      throw Exception('OpenAIService not initialized');
    }

    if (prompt.isEmpty) {
      throw Exception('Prompt cannot be empty');
    }

    try {
      return await _monitoring.trackOperation(
        name: 'openai_generate_image_from_text',
        operation: () async {
          final Map<String, dynamic> requestPayload = {
            'model': model,
            'prompt': prompt,
            'n': n,
            'size': size,
            'quality': quality,
            'style': style,
          };

          final response = await http.post(
            Uri.parse('https://api.openai.com/v1/images/generations'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: json.encode(requestPayload),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to generate image: ${response.body}');
          }

          final responseData = json.decode(response.body);
          final imageUrl = responseData['data'][0]['url'];
          if (imageUrl == null) {
            throw Exception('No image URL in OpenAI API response');
          }

          // Fetch the image bytes from the URL
          final imageResponse = await http.get(Uri.parse(imageUrl));
          if (imageResponse.statusCode != 200) {
            throw Exception('Failed to fetch generated image');
          }

          return imageResponse.bodyBytes;
        },
      );
    } catch (e, stackTrace) {
      await _monitoring.logError(
        e,
        stackTrace,
        reason: 'Failed to generate image from text',
        information: ['Prompt: $prompt', 'Model: $model', 'Size: $size'],
      );
      throw Exception('Failed to generate image from text: $e');
    }
  }

  /// Generate an image variation or edit based on an existing image and text prompt
  Future<Uint8List> generateImageFromImageAndText({
    required File imageFile,
    required String prompt,
    String model = 'dall-e-2',
    String size = '512x512',
    int n = 1,
    bool isVariation = false,
  }) async {
    if (_apiKey == null) {
      throw Exception('OpenAIService not initialized');
    }

    try {
      return await _monitoring.trackOperation(
        name: 'openai_generate_image_from_image_and_text',
        operation: () async {
          print('Starting image generation process...');
          print('Original image path: ${imageFile.path}');
          print('Original image size: ${await imageFile.length()} bytes');

          // Process the image and encode it as base64
          final processedImageBytes = await _processImage(imageFile);
          print('Processed image size: ${processedImageBytes.length} bytes');

          // Create a transparent mask of the same size as the processed image
          final decodedImage = img.decodeImage(processedImageBytes);
          if (decodedImage == null) {
            throw Exception('Failed to decode processed image');
          }

          // Create a mask image (white with transparent areas where we want changes)
          final maskImage = img.Image(
            width: decodedImage.width,
            height: decodedImage.height,
            numChannels: 4,
          );

          // Fill with semi-transparent white to allow for partial edits
          for (var y = 0; y < maskImage.height; y++) {
            for (var x = 0; x < maskImage.width; x++) {
              // RGBA: White with 50% transparency
              maskImage.setPixel(x, y, img.ColorRgba8(255, 255, 255, 128));
            }
          }

          // Encode mask as PNG
          final maskBytes = Uint8List.fromList(img.encodePng(maskImage));
          print('Created mask image: ${maskBytes.length} bytes');

          // Choose endpoint based on whether we're doing an edit or variation
          final endpoint = Uri.parse(
            isVariation || prompt.isEmpty
                ? 'https://api.openai.com/v1/images/variations'
                : 'https://api.openai.com/v1/images/edits',
          );

          print('Using endpoint: $endpoint');
          print('Prompt: $prompt');

          // Create a multipart request
          final request = http.MultipartRequest('POST', endpoint);
          request.headers['Authorization'] = 'Bearer $_apiKey';

          // Add the image file
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              processedImageBytes,
              filename: 'image.png',
            ),
          );

          // Add mask for edits endpoint
          if (!isVariation && prompt.isNotEmpty) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'mask',
                maskBytes,
                filename: 'mask.png',
              ),
            );
          }

          // Add other parameters
          request.fields['n'] = n.toString();
          request.fields['size'] = size;
          if (!isVariation && prompt.isNotEmpty) {
            request.fields['prompt'] = prompt;
          }

          print('Sending request to OpenAI API...');
          // Send the request
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode != 200) {
            print('API error response: ${response.body}');
            throw Exception('Failed to generate image: ${response.body}');
          }

          print('Received successful response from OpenAI API');
          final responseData = json.decode(response.body);
          final imageUrl = responseData['data'][0]['url'];
          if (imageUrl == null) {
            throw Exception('No image URL in OpenAI API response');
          }

          print('Generated image URL: $imageUrl');
          // Fetch the image bytes from the URL
          final imageResponse = await http.get(Uri.parse(imageUrl));
          if (imageResponse.statusCode != 200) {
            throw Exception('Failed to fetch generated image');
          }

          print(
            'Downloaded generated image: ${imageResponse.bodyBytes.length} bytes',
          );
          return imageResponse.bodyBytes;
        },
      );
    } catch (e, stackTrace) {
      await _monitoring.logError(
        e,
        stackTrace,
        reason: 'Failed to generate image from image and text',
        information: ['Prompt: $prompt', 'Model: $model', 'Size: $size'],
      );
      throw Exception('Failed to generate image from image and text: $e');
    }
  }

  /// Process an image to meet OpenAI API requirements
  Future<Uint8List> _processImage(File imageFile) async {
    try {
      print('Processing image: ${imageFile.path}');
      // Read and decode the original image
      final bytes = await imageFile.readAsBytes();
      print('Original image bytes: ${bytes.length}');

      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }
      print(
        'Original image dimensions: ${originalImage.width}x${originalImage.height}, channels: ${originalImage.numChannels}',
      );

      // Create a new RGBA image
      final rgbaImage = img.Image(
        width: originalImage.width,
        height: originalImage.height,
        numChannels: 4,
      );

      // Copy pixels with alpha channel
      for (var y = 0; y < originalImage.height; y++) {
        for (var x = 0; x < originalImage.width; x++) {
          final pixel = originalImage.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          rgbaImage.setPixelRgba(x, y, r, g, b, 255); // Full opacity
        }
      }
      print('Created RGBA image');

      // First try with medium compression
      final initialBytes = Uint8List.fromList(
        img.encodePng(rgbaImage, level: 6),
      );
      print('Initial PNG size: ${initialBytes.length} bytes');

      if (initialBytes.length <= maxFileSize) {
        print('Using initial PNG (under 4MB)');
        return initialBytes;
      }

      // If still too large, try resizing while maintaining RGBA format
      if (rgbaImage.width > maxImageDimension ||
          rgbaImage.height > maxImageDimension) {
        print('Image too large, resizing...');
        // Resize image while maintaining aspect ratio
        final resizedImage = img.copyResize(
          rgbaImage,
          width: rgbaImage.width > rgbaImage.height ? maxImageDimension : null,
          height: rgbaImage.height > rgbaImage.width ? maxImageDimension : null,
        );
        print('Resized to: ${resizedImage.width}x${resizedImage.height}');

        // Encode as PNG with high compression
        final resizedBytes = Uint8List.fromList(
          img.encodePng(resizedImage, level: 9),
        );
        print('Resized PNG size: ${resizedBytes.length} bytes');

        if (resizedBytes.length <= maxFileSize) {
          print('Using resized PNG (under 4MB)');
          return resizedBytes;
        }

        // If still too large, try more aggressive resizing
        print('Still too large, trying more aggressive resizing...');
        final smallerImage = img.copyResize(
          resizedImage,
          width: (resizedImage.width * 0.75).round(),
          height: (resizedImage.height * 0.75).round(),
        );
        print(
          'More aggressively resized to: ${smallerImage.width}x${smallerImage.height}',
        );

        final smallerBytes = Uint8List.fromList(
          img.encodePng(smallerImage, level: 9),
        );
        print('Smaller PNG size: ${smallerBytes.length} bytes');

        if (smallerBytes.length <= maxFileSize) {
          print('Using smaller PNG (under 4MB)');
          return smallerBytes;
        }
      }

      // If all else fails, try a very small image
      print('All resizing attempts failed, trying tiny image...');
      final tinyImage = img.copyResize(rgbaImage, width: 512, height: 512);
      print('Tiny image size: 512x512');

      final tinyBytes = Uint8List.fromList(img.encodePng(tinyImage, level: 9));
      print('Tiny PNG size: ${tinyBytes.length} bytes');

      if (tinyBytes.length <= maxFileSize) {
        print('Using tiny PNG (under 4MB)');
        return tinyBytes;
      }

      // If we still can't get a small enough PNG, throw an exception
      print('All attempts failed, image still too large');
      throw Exception('Image file is too large. Maximum size is 4MB.');
    } catch (e) {
      print('Error processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  /// Analyze an image and return metadata
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      return await _monitoring.trackOperation(
        name: 'openai_analyze_image',
        operation: () async {
          // Use existing _processImage method to handle the image
          final processedImageBytes = await _processImage(imageFile);

          // Create basic image analysis
          final analysis = {
            'fileSize': await imageFile.length(),
            'processedSize': processedImageBytes.length,
            'isProcessed':
                await imageFile.length() != processedImageBytes.length,
            'dimensions': await _getImageDimensions(imageFile),
          };

          return analysis;
        },
      );
    } catch (e, stackTrace) {
      await _monitoring.logError(
        e,
        stackTrace,
        reason: 'Failed to analyze image',
      );
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Get the dimensions of an image
  Future<Map<String, int>> _getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image for dimensions');
    }
    return {'width': image.width, 'height': image.height};
  }
}
