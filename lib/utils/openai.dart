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

  static const int maxImageDimension = 1024;
  static const int maxFileSize = 4 * 1024 * 1024;

  OpenAIService._internal();

  Future<void> initialize(String apiKey) async {
    await _monitoring.trackOperation(
      name: 'openai_initialize',
      operation: () async {
        _apiKey = apiKey;
      },
    );
  }

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

          final processedImageBytes = await _processImage(imageFile);
          print('Processed image size: ${processedImageBytes.length} bytes');

          final decodedImage = img.decodeImage(processedImageBytes);
          if (decodedImage == null) {
            throw Exception('Failed to decode processed image');
          }

          final maskImage = img.Image(
            width: decodedImage.width,
            height: decodedImage.height,
            numChannels: 4,
          );

          for (var y = 0; y < maskImage.height; y++) {
            for (var x = 0; x < maskImage.width; x++) {
              maskImage.setPixel(x, y, img.ColorRgba8(255, 255, 255, 128));
            }
          }

          final maskBytes = Uint8List.fromList(img.encodePng(maskImage));
          print('Created mask image: ${maskBytes.length} bytes');

          final endpoint = Uri.parse(
            isVariation || prompt.isEmpty
                ? 'https://api.openai.com/v1/images/variations'
                : 'https://api.openai.com/v1/images/edits',
          );

          print('Using endpoint: $endpoint');
          print('Prompt: $prompt');

          final request = http.MultipartRequest('POST', endpoint);
          request.headers['Authorization'] = 'Bearer $_apiKey';

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              processedImageBytes,
              filename: 'image.png',
            ),
          );

          if (!isVariation && prompt.isNotEmpty) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'mask',
                maskBytes,
                filename: 'mask.png',
              ),
            );
          }

          request.fields['n'] = n.toString();
          request.fields['size'] = size;
          if (!isVariation && prompt.isNotEmpty) {
            request.fields['prompt'] = prompt;
          }

          print('Sending request to OpenAI API...');
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

  Future<Uint8List> generateEventFromImageAndImage({
    required File userImageFile,
    required File eventImageFile,
    required bool
        isPoster, // true for poster/pamphlet, false for real-life event
    String model = 'dall-e-2',
    String size = '512x512',
    int n = 1,
  }) async {
    if (_apiKey == null) {
      throw Exception('OpenAIService not initialized');
    }

    try {
      return await _monitoring.trackOperation(
        name: 'openai_generate_event_from_images',
        operation: () async {
          print('Starting event image generation process...');

          // Process both images
          print('Processing user image...');
          final processedUserImageBytes = await _processImage(userImageFile);
          print(
              'Processed user image size: ${processedUserImageBytes.length} bytes');

          print('Processing event image...');
          final processedEventImageBytes = await _processImage(eventImageFile);
          print(
              'Processed event image size: ${processedEventImageBytes.length} bytes');

          // Generate appropriate prompt based on type
          final prompt = isPoster
              ? "Seamlessly integrate the person from the first image into the event poster/banner, making them appear as a natural part of the design while maintaining their facial features and appearance"
              : "Naturally blend the person from the first image into the event scene, making them appear as if they were actually present at the event, maintaining realistic lighting, scale, and perspective";

          final endpoint = Uri.parse('https://api.openai.com/v1/images/edits');
          print('Using endpoint: $endpoint');
          print(
              'Integration type: ${isPoster ? "Poster/Banner" : "Real-life event"}');

          final request = http.MultipartRequest('POST', endpoint);
          request.headers['Authorization'] = 'Bearer $_apiKey';

          // Add the event image as the base image
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              processedEventImageBytes,
              filename: 'event.png',
            ),
          );

          // Create mask for the area where user should be integrated
          final decodedEventImage = img.decodeImage(processedEventImageBytes);
          if (decodedEventImage == null) {
            throw Exception('Failed to decode event image');
          }

          final maskImage = img.Image(
            width: decodedEventImage.width,
            height: decodedEventImage.height,
            numChannels: 4,
          );

          // Create a strategic mask based on the type of integration
          if (isPoster) {
            // For posters, create a mask in a suitable area for profile placement
            _createPosterMask(maskImage);
          } else {
            // For real-life events, create a mask in a natural position
            _createEventSceneMask(maskImage);
          }

          final maskBytes = Uint8List.fromList(img.encodePng(maskImage));
          print('Created mask image: ${maskBytes.length} bytes');

          request.files.add(
            http.MultipartFile.fromBytes(
              'mask',
              maskBytes,
              filename: 'mask.png',
            ),
          );

          request.fields['prompt'] = prompt;
          request.fields['n'] = n.toString();
          request.fields['size'] = size;

          print('Sending request to OpenAI API...');
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
        reason: 'Failed to generate event image',
        information: [
          'Integration type: ${isPoster ? "Poster" : "Real-life event"}',
          'Model: $model',
          'Size: $size',
        ],
      );
      throw Exception('Failed to generate event image: $e');
    }
  }

  void _createPosterMask(img.Image maskImage) {
    // Create a mask that covers approximately 20% of the image in a suitable position
    final maskWidth = (maskImage.width * 0.2).round();
    final maskHeight = (maskImage.height * 0.2).round();
    final startX = (maskImage.width * 0.1).round();
    final startY = (maskImage.height * 0.1).round();

    for (var y = startY; y < startY + maskHeight; y++) {
      for (var x = startX; x < startX + maskWidth; x++) {
        if (x < maskImage.width && y < maskImage.height) {
          maskImage.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
        }
      }
    }
  }

  void _createEventSceneMask(img.Image maskImage) {
    // Create a mask that covers a natural position in the scene
    final maskWidth = (maskImage.width * 0.3).round();
    final maskHeight = (maskImage.height * 0.5).round();
    final startX = (maskImage.width * 0.35).round();
    final startY = (maskImage.height * 0.3).round();

    for (var y = startY; y < startY + maskHeight; y++) {
      for (var x = startX; x < startX + maskWidth; x++) {
        if (x < maskImage.width && y < maskImage.height) {
          maskImage.setPixel(x, y, img.ColorRgba8(255, 255, 255, 128));
        }
      }
    }
  }

  Future<Uint8List> _processImage(File imageFile) async {
    try {
      print('Processing image: ${imageFile.path}');
      final bytes = await imageFile.readAsBytes();
      print('Original image bytes: ${bytes.length}');

      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }
      print(
        'Original image dimensions: ${originalImage.width}x${originalImage.height}, channels: ${originalImage.numChannels}',
      );

      final rgbaImage = img.Image(
        width: originalImage.width,
        height: originalImage.height,
        numChannels: 4,
      );

      for (var y = 0; y < originalImage.height; y++) {
        for (var x = 0; x < originalImage.width; x++) {
          final pixel = originalImage.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          rgbaImage.setPixelRgba(x, y, r, g, b, 255);
        }
      }
      print('Created RGBA image');

      final initialBytes = Uint8List.fromList(
        img.encodePng(rgbaImage, level: 6),
      );
      print('Initial PNG size: ${initialBytes.length} bytes');

      if (initialBytes.length <= maxFileSize) {
        print('Using initial PNG (under 4MB)');
        return initialBytes;
      }

      if (rgbaImage.width > maxImageDimension ||
          rgbaImage.height > maxImageDimension) {
        print('Image too large, resizing...');
        final resizedImage = img.copyResize(
          rgbaImage,
          width: rgbaImage.width > rgbaImage.height ? maxImageDimension : null,
          height: rgbaImage.height > rgbaImage.width ? maxImageDimension : null,
        );
        print('Resized to: ${resizedImage.width}x${resizedImage.height}');

        final resizedBytes = Uint8List.fromList(
          img.encodePng(resizedImage, level: 9),
        );
        print('Resized PNG size: ${resizedBytes.length} bytes');

        if (resizedBytes.length <= maxFileSize) {
          print('Using resized PNG (under 4MB)');
          return resizedBytes;
        }

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

      print('All resizing attempts failed, trying tiny image...');
      final tinyImage = img.copyResize(rgbaImage, width: 512, height: 512);
      print('Tiny image size: 512x512');

      final tinyBytes = Uint8List.fromList(img.encodePng(tinyImage, level: 9));
      print('Tiny PNG size: ${tinyBytes.length} bytes');

      if (tinyBytes.length <= maxFileSize) {
        print('Using tiny PNG (under 4MB)');
        return tinyBytes;
      }

      print('All attempts failed, image still too large');
      throw Exception('Image file is too large. Maximum size is 4MB.');
    } catch (e) {
      print('Error processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      return await _monitoring.trackOperation(
        name: 'openai_analyze_image',
        operation: () async {
          final processedImageBytes = await _processImage(imageFile);

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

  Future<Map<String, int>> _getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image for dimensions');
    }
    return {'width': image.width, 'height': image.height};
  }

  String buildDetailedPrompt(String prompt, String style, String featureType) {
    switch (featureType) {
      case 'convert':
        return '''
Transform the person in the input image into $style style while maintaining their identity.
Use the person's facial features and appearance from the input image as the base for the transformation.
Apply the artistic style while keeping their recognizable characteristics from the input image.
Create a unique and imaginative composition that showcases both the person and the style.
Ensure the person remains recognizable despite the artistic transformation.
''';

      case 'profile':
        return '''
Transform the person in the input image into a $style style profile picture avatar.
Preserve the person's facial features, expression, and identity from the input image.
Adapt the background, outfit, and lighting to match the chosen style while ensuring a flattering, well-lit, and confident appearance.
Apply styling consistent with modern avatar trends—whether it's professional, casual, creative, gaming, or artistic.
Maintain clean composition, clear facial detail, and visual polish appropriate for use as a display picture or resume profile.
''';

      case 'travel':
        return '''
Place the person from the input image at $prompt in $style visual style.
Retain the person's original facial features, posture, and clothing from the input image while blending them naturally into the travel scene.
Recreate the iconic elements of $prompt (e.g., landmarks, landscapes, cultural aesthetics) in a visually rich, scenic, and immersive way that reflects the chosen $style.
Ensure the background, lighting, and color palette align with both the location and the selected visual style.
The final image should feel like a dreamlike travel photo—vibrant, stylish, and shareable—while preserving the person's identity and enhancing the wanderlust vibe.
''';

      case 'celebrity':
        return '''
Create an image of the person from the input image standing next to $prompt in $style visual style.
Maintain the person's original facial features, expression, and overall appearance from the input image.
Ensure the celebrity is clearly recognizable and styled similarly to match the chosen visual style.
Use a clean, thematic background that suits both subjects and reflects the $style aesthetic (e.g., Ghibli forest, Cyberpunk city, Vintage set).
Both individuals should appear naturally posed—like a friendly or candid moment—while keeping them visually harmonized.
Preserve the identity of both subjects while transforming the scene into a shareable, artistic, celebrity-style image.
''';

      default:
        return '''
Create an image based entirely on the following user prompt:
"$prompt"
Interpret the prompt creatively while maintaining visual coherence, aesthetic quality, and engaging composition.
Do not apply any predefined style, structure, or constraints—fully adapt to the user's imagination.
''';
    }
  }
}
