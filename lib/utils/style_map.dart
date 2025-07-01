final Map<String, Map<String, Map<String, String>>> styleExplanations = {
  'text': {
    'Classic Oil Painting': {
      'prompt':
          'This style transforms any text prompt into a detailed oil painting inspired by the 18th century, complete with dramatic lighting, visible brush textures, and timeless composition.',
      'image': 'assets/styles/text/classic_oil_painting.png',
    },
    'Ghibli': {
      'prompt':
          'Creates a soft, whimsical world with dreamy skies, pastel tones, and charming fantasy elements, mimicking the storytelling feel of Studio Ghibli.',
      'image': 'assets/styles/text/ghibli.png',
    },
    '8-Bit Pixel Art': {
      'prompt':
          'Generates low-resolution, pixel-style art with sharp edges and a nostalgic video game vibe, ideal for retro or game-themed prompts.',
      'image': 'assets/styles/text/8bit_pixel_art.png',
    },
    'Sci - Fi': {
      'prompt':
          'Produces futuristic environments with sleek tech, neon glows, cybernetic details, and vast space settings to match your sci-fi prompt.',
      'image': 'assets/styles/text/sci_fi.png',
    },
    '3D Cartoon': {
      'prompt':
          'Renders playful, rounded 3D characters and objects with vibrant colors and a glossy Pixar-style finish, great for animated and joyful ideas.',
      'image': 'assets/styles/text/3d_cartoon.png',
    },
    'Anime': {
      'prompt':
          'Delivers dynamic visuals with stylized eyes, energetic poses, and vivid colors, ideal for storytelling, emotion, or fantasy prompts.',
      'image': 'assets/styles/text/anime.png',
    },
    'Geometric': {
      'prompt':
          'Converts prompts into abstract designs made of polygons, sharp lines, and balanced symmetry with bold or minimal color schemes.',
      'image': 'assets/styles/text/geometric.png',
    },
    'Watercolor': {
      'prompt':
          'Applies flowing paint textures, delicate gradients, and organic blending, perfect for nature, mood, or fantasy-themed prompts.',
      'image': 'assets/styles/text/watercolor.png',
    },
    'Epic & Grand': {
      'prompt':
          'Transforms scenes into large-scale cinematic visuals with wide angles, grand landscapes, and powerful lighting — fit for fantasy or myth.',
      'image': 'assets/styles/text/epic_grand.png',
    },
    'Simple & Clean': {
      'prompt':
          'Turns your ideas into minimalistic visuals with clean lines, soft colors, and elegant balance, ideal for modern, aesthetic scenes.',
      'image': 'assets/styles/text/simple_clean.png',
    },
    'Fun': {
      'prompt':
          'Injects humor and playfulness into your prompt, with bold shapes, bouncy characters, and a cheerful color palette.',
      'image': 'assets/styles/text/fun.png',
    },
    'Claymation': {
      'prompt':
          'Gives your scene a handcrafted look with clay textures, subtle imperfections, and stop-motion-style shadows.',
      'image': 'assets/styles/text/claymation.png',
    },
    'Professional': {
      'prompt':
          'Creates highly polished, sharp, and clean visuals with controlled lighting and balance, best for modern or formal prompts.',
      'image': 'assets/styles/text/professional.png',
    },
  },

  // Repeat this same structure for the other categories below 👇

  'convert': {
    'Ghibli': {
      'prompt':
          'Applies a Ghibli-inspired animation overlay to your image, softening colors, adding dreamy skies, nature, and emotional warmth.',
      'image': 'assets/styles/convert/ghibli.png',
    },
    'Brush Painting': {
      'prompt':
          'Converts your image into a traditional brush painting with flowing ink strokes and textured brush details on natural paper.',
      'image': 'assets/styles/convert/brush_painting.png',
    },
    'Sketch': {
      'prompt':
          'Turns your image into a pencil sketch with rough outlines, shading, and hand-drawn imperfections.',
      'image': 'assets/styles/convert/sketch.png',
    },
    'Watercolor': {
      'prompt':
          'Blends the image into a soft watercolor style, with pigment textures, washed-out edges, and gentle transitions.',
      'image': 'assets/styles/convert/watercolor.png',
    },
    'Neon Retro': {
      'prompt':
          'Overlays your image with 80s-inspired neon lights, VHS textures, digital grids, and retro-futuristic color schemes.',
      'image': 'assets/styles/convert/neon_retro.png',
    },
    'Comic Book': {
      'prompt':
          'Stylizes the image into comic book form with bold outlines, halftone dots, action strokes, and dramatic color blocking.',
      'image': 'assets/styles/convert/comic_book.png',
    },
    'Color Splash': {
      'prompt':
          'Applies grayscale to most of the image while selectively coloring key elements to create contrast and focus.',
      'image': 'assets/styles/convert/color_splash.png',
    },
    'Graffiti': {
      'prompt':
          'Converts visuals into urban street art using bold sprays, stencils, drips, and rebellious style fonts.',
      'image': 'assets/styles/convert/graffiti.png',
    },
    'Paper Cut Collage': {
      'prompt':
          'Transforms visuals into layered paper art with drop shadows, textured cut-outs, and collage composition.',
      'image': 'assets/styles/convert/paper_cut_collage.png',
    },
    'Cyberpunk': {
      'prompt':
          'Gives the image a futuristic, neon-drenched look with digital overlays, city glow, and dystopian ambiance.',
      'image': 'assets/styles/convert/cyberpunk.png',
    },
  },

  'profile': {
    'Ghibli': {
      'prompt':
          'Creates a dreamy, animated-style portrait with large eyes, soft shading, and gentle background — perfect for a fantasy-themed profile.',
      'image': 'assets/styles/profile/ghibli.png',
    },
    'Passport Photo': {
      'prompt':
          'Generates a formal, front-facing, well-lit headshot with a neutral background, ideal for official or ID-style profiles.',
      'image': 'assets/styles/profile/passport_photo.png',
    },
    '3D Cartoon': {
      'prompt':
          'Builds a rounded 3D avatar with glossy features, expressive eyes, and bold, colorful design for playful digital personas.',
      'image': 'assets/styles/profile/3d_cartoon.png',
    },
    'Anime': {
      'prompt':
          'Creates a stylized anime portrait with expressive eyes, vibrant hair, and energetic character presence.',
      'image': 'assets/styles/profile/anime.png',
    },
    'Watercolor': {
      'prompt':
          'Designs a soft, painterly avatar with brush-blended features and a dreamy artistic tone.',
      'image': 'assets/styles/profile/watercolor.png',
    },
    'Minecraft Avatar': {
      'prompt':
          'Generates a blocky, pixel-style character headshot resembling the Minecraft universe, great for gaming profiles.',
      'image': 'assets/styles/profile/minecraft_avatar.png',
    },
    'Cyberpunk': {
      'prompt':
          'Crafts a futuristic avatar with neon accents, digital accessories, and edgy fashion perfect for sci-fi lovers.',
      'image': 'assets/styles/profile/cyberpunk.png',
    },
    'Epic & Grand': {
      'prompt':
          'Presents a heroic, cinematic avatar with dramatic lighting, strong pose, and mythic background elements.',
      'image': 'assets/styles/profile/epic_grand.png',
    },
    'Simple & Clean': {
      'prompt':
          'Provides a neat, modern avatar with flat colors, clean outlines, and minimal distractions.',
      'image': 'assets/styles/profile/simple_clean.png',
    },
    'Fun': {
      'prompt':
          'Creates a cheerful, energetic avatar with bright colors and exaggerated features to match a bubbly personality.',
      'image': 'assets/styles/profile/fun.png',
    },
    'Claymation': {
      'prompt':
          'Builds a clay-textured character portrait with soft lighting and handcrafted realism.',
      'image': 'assets/styles/profile/claymation.png',
    },
    'Professional': {
      'prompt':
          'Designs a business-like portrait with balanced lighting, subtle shadows, and a tidy appearance.',
      'image': 'assets/styles/profile/professional.png',
    },
    'Geometric': {
      'prompt':
          'Shapes the avatar with angular features, polygons, and abstract styling for a modern-artistic feel.',
      'image': 'assets/styles/profile/geometric.png',
    },
    '8-Bit Pixel Art': {
      'prompt':
          'Produces a pixel-art avatar with small grid-based design and retro charm.',
      'image': 'assets/styles/profile/8bit_pixel_art.png',
    },
  },

  'travel': {
    'Ghibli': {
      'prompt':
          'Generates a whimsical travel landscape with nature, flying elements, and magical lighting that feels straight out of a Ghibli world.',
      'image': 'assets/styles/travel/ghibli.png',
    },
    'Realistic': {
      'prompt':
          'Creates a photorealistic travel shot with true-to-life lighting, textures, and detail — like a professional vacation photograph.',
      'image': 'assets/styles/travel/realistic.png',
    },
    'Golden Hour': {
      'prompt':
          'Simulates sunset travel scenes with warm orange tones, soft flares, and long shadows, giving a cinematic mood.',
      'image': 'assets/styles/travel/golden_hour.png',
    },
    '3D Toy World': {
      'prompt':
          'Transforms travel locations into miniature, toy-like environments with plastic textures and colorful proportions.',
      'image': 'assets/styles/travel/3d_toy_world.png',
    },
    'Adventure Poster': {
      'prompt':
          'Designs a travel shot like a movie poster with dramatic typography, wide angles, and stylized excitement.',
      'image': 'assets/styles/travel/adventure_poster.png',
    },
    'Magic World': {
      'prompt':
          'Creates fantastical landscapes with floating elements, glowing flora, and mythical structures — pure wonder.',
      'image': 'assets/styles/travel/magic_world.png',
    },
    'Cyberpunk': {
      'prompt':
          'Builds a futuristic travel scene in a glowing neon city with flying cars, holograms, and digital signage.',
      'image': 'assets/styles/travel/cyberpunk.png',
    },
  },

  'celebrity': {
    'Ghibli': {
      'prompt':
          'Presents a celebrity in an animated fantasy world with warm lighting, soft features, and a whimsical vibe.',
      'image': 'assets/styles/celebrity/ghibli.png',
    },
    'Realistic': {
      'prompt':
          'Creates a high-quality, photorealistic celebrity image with professional lighting and lifelike expressions.',
      'image': 'assets/styles/celebrity/realistic.png',
    },
    'Red Carpet': {
      'prompt':
          'Designs a glamorous shot of a celebrity on a red carpet with flashing cameras, velvet ropes, and formal attire.',
      'image': 'assets/styles/celebrity/red_carpet.png',
    },
    'Candid Cafe': {
      'prompt':
          'Shows a relaxed, casual moment of the celebrity in a cozy café setting with soft lighting and natural expressions.',
      'image': 'assets/styles/celebrity/candid_cafe.png',
    },
    'Podcast': {
      'prompt':
          'Places the celebrity in a studio setup with a mic, headphones, and a modern tech vibe, like a podcast shoot.',
      'image': 'assets/styles/celebrity/podcast.png',
    },
    'Magazine Cover': {
      'prompt':
          'Stylizes the image like a magazine cover with dramatic poses, editorial lighting, and title overlays.',
      'image': 'assets/styles/celebrity/magazine_cover.png',
    },
    'Cyberpunk': {
      'prompt':
          'Visualizes the celebrity in a futuristic setting with neon lighting, cyber implants, and a high-tech city backdrop.',
      'image': 'assets/styles/celebrity/cyberpunk.png',
    },
  },
};
