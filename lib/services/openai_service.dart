import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class OpenAIService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1';

  OpenAIService({required this.apiKey});

  /// Generate an image from a text prompt
  Future<Uint8List> generateImageFromText({
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
    String quality = 'standard',
    String style = 'vivid',
    int n = 1,
  }) async {
    final Uri endpoint = Uri.parse('$baseUrl/images/generations');

    final Map<String, dynamic> body = {
      'model': model,
      'prompt': prompt,
      'n': n,
      'size': size,
      'quality': quality,
      'style': style,
    };

    final response = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageUrl = data['data'][0]['url'];

      // Fetch the image bytes from the URL
      final imageResponse = await http.get(Uri.parse(imageUrl));
      if (imageResponse.statusCode != 200) {
        throw Exception('Failed to fetch generated image');
      }

      return imageResponse.bodyBytes;
    } else {
      throw Exception('Failed to generate image: ${response.body}');
    }
  }

  /// Generate an image variation or edit based on an existing image and text prompt
  Future<Uint8List> generateImageFromImageAndText({
    required File imageFile,
    required String prompt,
    String model = 'dall-e-2',
    String size = '1024x1024',
    int n = 1,
    bool isVariation = false,
  }) async {
    // Process the image to meet OpenAI requirements
    final processedImageBytes = await _processImage(imageFile);

    // For image editing, we use the /images/edits endpoint
    final endpoint = Uri.parse('$baseUrl/images/edits');

    // Create a multipart request
    final request = http.MultipartRequest('POST', endpoint);
    request.headers['Authorization'] = 'Bearer $apiKey';

    // Add the image file
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        processedImageBytes,
        filename: 'image.png',
      ),
    );

    // Add other parameters
    request.fields['n'] = n.toString();
    request.fields['size'] = size;
    request.fields['prompt'] = prompt;

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageUrl = data['data'][0]['url'];

      // Fetch the image bytes from the URL
      final imageResponse = await http.get(Uri.parse(imageUrl));
      if (imageResponse.statusCode != 200) {
        throw Exception('Failed to fetch generated image');
      }

      return imageResponse.bodyBytes;
    } else {
      throw Exception('Failed to generate image: ${response.body}');
    }
  }

  /// Process an image to meet OpenAI API requirements
  Future<Uint8List> _processImage(File imageFile) async {
    // Maximum dimensions for input images
    const int maxImageDimension = 1024;
    const int maxFileSize = 4 * 1024 * 1024; // 4MB

    // Check file size
    final fileSize = await imageFile.length();
    if (fileSize > maxFileSize) {
      throw Exception('Image file is too large. Maximum size is 4MB.');
    }

    // Read image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Check dimensions
    if (image.width > maxImageDimension || image.height > maxImageDimension) {
      // Resize image while maintaining aspect ratio
      final resizedImage = img.copyResize(
        image,
        width: image.width > image.height ? maxImageDimension : null,
        height: image.height > image.width ? maxImageDimension : null,
      );
      return Uint8List.fromList(img.encodePng(resizedImage));
    }

    // Convert to PNG format if not already
    if (!_isPngFormat(bytes)) {
      return Uint8List.fromList(img.encodePng(image));
    }

    return bytes;
  }

  /// Check if the image is in PNG format
  bool _isPngFormat(Uint8List bytes) {
    if (bytes.length < 8) return false;
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }

  /// Generate a detailed prompt based on the feature type and style
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
