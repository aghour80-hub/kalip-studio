import 'package:material_ui/material_ui.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class SampleData {
  // Categories
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'women',
      nameEn: 'Women',
      nameKm: 'ម៉ូដនារី',
      imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=800&auto=format&fit=crop',
      itemCount: 48,
      gender: 'women',
      isFeatured: true,
    ),
    CategoryModel(
      id: 'men',
      nameEn: 'Men',
      nameKm: 'ម៉ូដបុរស',
      imageUrl: 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?q=80&w=800&auto=format&fit=crop',
      itemCount: 42,
      gender: 'men',
      isFeatured: true,
    ),
    CategoryModel(
      id: 'tailoring',
      nameEn: 'Atelier Tailoring',
      nameKm: 'ឈុតកាត់ដេរពិសេស',
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=800&auto=format&fit=crop',
      itemCount: 24,
      gender: 'all',
      isFeatured: true,
    ),
    CategoryModel(
      id: 'bags',
      nameEn: 'Leather Bags',
      nameKm: 'កាបូបស្បែកប្រណីត',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
      itemCount: 19,
      gender: 'all',
      isFeatured: true,
    ),
    CategoryModel(
      id: 'footwear',
      nameEn: 'Footwear & Loafers',
      nameKm: 'ស្បែកជើង និងឡូហ្វឺរ',
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=800&auto=format&fit=crop',
      itemCount: 16,
      gender: 'all',
    ),
    CategoryModel(
      id: 'accessories',
      nameEn: 'Silk & Accessories',
      nameKm: 'គ្រឿងតុបតែង & សូត្រ',
      imageUrl: 'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?q=80&w=800&auto=format&fit=crop',
      itemCount: 30,
      gender: 'all',
    ),
  ];

  // Products
  static const List<ProductModel> products = [
    ProductModel(
      id: 'sh-001',
      nameEn: 'Atelier Silk Wrap Midi Dress',
      nameKm: 'រ៉ូបសូត្រប្រណីតម៉ូដ Midi',
      descriptionEn:
          'Cut from pure mulberry silk with a lustrous sheen, this wrap midi dress embodies fluid movement and timeless sophistication. Features a tailored waist sash, French seams, and a cascading asymmetric drape.',
      descriptionKm:
          'កាត់ដេរពីសរសៃសូត្រធម្មជាតិ 100% ផ្តល់នូវភាពរលោងស្រទន់ និងភាពថ្លៃថ្នូរ។ មានខ្សែក្រវាត់ចង្កេះយ៉ាងផ្ចិតផ្ចង់ និងទម្រង់រ៉ូបទម្លាក់ដ៏ស្រស់ស្អាត។',
      priceUsd: 185.0,
      originalPriceUsd: 220.0,
      categoryId: 'women',
      gender: 'women',
      colors: [
        ProductColor(nameEn: 'Champagne Gold', nameKm: 'ពណ៌មាសស្រាល', color: Color(0xFFE5D5C0)),
        ProductColor(nameEn: 'Obsidian Black', nameKm: 'ពណ៌ខ្មៅរលោង', color: Color(0xFF141414)),
        ProductColor(nameEn: 'Olive Ochre', nameKm: 'ពណ៌អូលីវ', color: Color(0xFF706B54)),
      ],
      sizes: ['XS', 'S', 'M', 'L'],
      images: [
        'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 8,
      rating: 4.9,
      reviewCount: 38,
      isNewArrival: true,
      isBestSeller: true,
      isFeatured: true,
      detailsEn: [
        '100% Grade 6A Mulberry Silk',
        'Dry clean only or gentle hand wash cold with silk detergent',
        'True to size with an adjustable wrap closure',
        'Designed in Paris, handcrafted for KALIP studio Phnom Penh',
      ],
      detailsKm: [
        'សរសៃសូត្រធម្មជាតិ 100% កម្រិត 6A',
        'បោកគក់ស្ងួត ឬបោកដោយដៃថ្នមៗជាមួយសាប៊ូសូត្រ',
        'ទំហំស្តង់ដារ មានខ្សែចងកែប្រែសម្រួលបាន',
        'រចនាម៉ូដយ៉ាងពិសេសសម្រាប់ KALIP studio ភ្នំពេញ',
      ],
      materialEn: '100% Pure Mulberry Silk (19 Momme)',
      materialKm: 'សូត្រធម្មជាតិសុទ្ធ 100%',
    ),
    ProductModel(
      id: 'sh-002',
      nameEn: 'Relaxed Linen Camp Collar Overshirt',
      nameKm: 'អាវដៃខ្លីក្រណាត់កប្បាសលីនិនម៉ូដបុរស',
      descriptionEn:
          'Crafted from Normandy organic linen, this relaxed camp-collar overshirt delivers breathable luxury suited for Cambodia’s tropical climate and Phnom Penh evenings. Features genuine mother-of-pearl buttons.',
      descriptionKm:
          'ផលិតពីក្រណាត់លីនិនសរីរាង្គទន់ត្រជាក់ សមស្របបំផុតសម្រាប់អាកាសធាតុក្តៅ និងរាត្រីស្រស់ស្រាយក្នុងរាជធានីភ្នំពេញ។ បំពាក់ដោយលេវគុជខ្យងធម្មជាតិពិតៗ។',
      priceUsd: 115.0,
      originalPriceUsd: null,
      categoryId: 'men',
      gender: 'men',
      colors: [
        ProductColor(nameEn: 'Warm Sand', nameKm: 'ពណ៌ខ្សាច់កក់ក្តៅ', color: Color(0xFFE5DEC9)),
        ProductColor(nameEn: 'Ivory White', nameKm: 'ពណ៌សភ្លុក', color: Color(0xFFF9F7F1)),
        ProductColor(nameEn: 'Midnight Navy', nameKm: 'ពណ៌ខៀវចាស់', color: Color(0xFF1E2738)),
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      images: [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 14,
      rating: 4.8,
      reviewCount: 29,
      isNewArrival: true,
      isBestSeller: true,
      isFeatured: true,
      detailsEn: [
        '100% Pre-washed European Linen',
        'Relaxed boxy silhouette with side vents',
        'Real mother-of-pearl buttons',
        'Machine wash cold, hang dry in shade',
      ],
      detailsKm: [
        'ក្រណាត់លីនិនអឺរ៉ុប 100% មិនរួញ',
        'ម៉ូដរលុងទាន់សម័យ មានខ្យល់ចេញចូលស្រួល',
        'លេវគុជខ្យងពិតប្រណីត',
        'បោកគក់ជាមួយទឹកត្រជាក់ ហាលក្នុងម្លប់',
      ],
      materialEn: '100% European Certified Organic Linen (180 GSM)',
      materialKm: 'ក្រណាត់លីនិនសុទ្ធ 100%',
    ),
    ProductModel(
      id: 'sh-003',
      nameEn: 'Sculpted Tailored Wool Blazer',
      nameKm: 'អាវធំ Blazer កាត់ដេរប្រណីត',
      descriptionEn:
          'A modern masterclass in tailoring. Featuring padded structured shoulders, peaked lapels, and a nipped-in waistline for an effortless power silhouette. Finished with horn buttons and cupro lining.',
      descriptionKm:
          'ស្នាដៃកាត់ដេរកម្រិតខ្ពស់ជាមួយនឹងស្មាកាត់ស្អាត និងចង្កេះរាងស្អាត ឆ្លុះបញ្ចាំងពីភាពរឹងមាំ និងថ្លៃថ្នូរ។ ស្រទាប់ក្នុងរលោងស្រួលពាក់។',
      priceUsd: 260.0,
      originalPriceUsd: 310.0,
      categoryId: 'tailoring',
      gender: 'women',
      colors: [
        ProductColor(nameEn: 'Charcoal Black', nameKm: 'ពណ៌ខ្មៅធ្យូង', color: Color(0xFF1F1F1F)),
        ProductColor(nameEn: 'Camel Beige', nameKm: 'ពណ៌កាមែលបន៍', color: Color(0xFFC4A47C)),
      ],
      sizes: ['XS', 'S', 'M', 'L'],
      images: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 4,
      rating: 5.0,
      reviewCount: 16,
      isNewArrival: false,
      isBestSeller: true,
      isFeatured: true,
      detailsEn: [
        'Super 120s Virgin Wool blend',
        'Padded structured shoulders with peaked lapels',
        'Double-breasted front fastening',
        'Interior passport and phone pockets',
      ],
      detailsKm: [
        'ក្រណាត់រោមចៀម Virgin Wool កម្រិត Super 120s',
        'រចនាស្មាមានទ្រនាប់រឹងមាំ កបត់ស្រួច',
        'ម៉ូដលេវពីរជួរយ៉ាងប្រណីត',
        'មានហោប៉ៅខាងក្នុងសុវត្ថិភាព',
      ],
      materialEn: '96% Virgin Wool, 4% Elastane; Lining: 100% Cupro',
      materialKm: 'រោមចៀម Virgin Wool 96%, Elastane 4%',
    ),
    ProductModel(
      id: 'sh-004',
      nameEn: 'Pleated Straight-Leg Trousers',
      nameKm: 'ខោខូវប៊យក្រណាត់ផ្នត់ទាន់សម័យ',
      descriptionEn:
          'Impeccably tailored trousers with double front pleats, high-rise waist, and a fluid straight leg. Designed to pair with both casual tees and structured blazers.',
      descriptionKm:
          'ខោសាច់ក្រណាត់មានផ្នត់មុខពីរជួរ ចង្កេះខ្ពស់ ជើងត្រង់រលោងស្អាត អាចពាក់ជាមួយអាវយឺតធម្មតា ឬអាវធំ Blazer បានយ៉ាងស័ក្តិសម។',
      priceUsd: 140.0,
      originalPriceUsd: null,
      categoryId: 'men',
      gender: 'men',
      colors: [
        ProductColor(nameEn: 'Oatmeal', nameKm: 'ពណ៌អូដមីល', color: Color(0xFFDED8CE)),
        ProductColor(nameEn: 'Deep Espresso', nameKm: 'ពណ៌កាហ្វេក្រម៉ៅ', color: Color(0xFF2E231F)),
        ProductColor(nameEn: 'Black', nameKm: 'ពណ៌ខ្មៅ', color: Color(0xFF111111)),
      ],
      sizes: ['30', '32', '34', '36'],
      images: [
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 11,
      rating: 4.7,
      reviewCount: 22,
      isNewArrival: true,
      isBestSeller: false,
      isFeatured: false,
      detailsEn: [
        'High-waisted with concealed hook-and-eye closure',
        'Double reverse front pleats for drape',
        'Blind hemmed trousers',
      ],
      detailsKm: [
        'ចង្កេះខ្ពស់ មានគន្លឹះលាក់ខាងក្នុងយ៉ាងស្អាត',
        'ផ្នត់មុខពីរជួរផ្តល់នូវភាពរលោងស្រួលដើរ',
        'ថ្នេរបាតជើងដេរលាក់យ៉ាងផ្ចិតផ្ចង់',
      ],
      materialEn: '70% Wool, 30% Lyocell blend for breathability',
      materialKm: 'រោមចៀម 70%, លីអូសែល 30%',
    ),
    ProductModel(
      id: 'sh-005',
      nameEn: 'Monogram Flap Leather Crossbody Bag',
      nameKm: 'កាបូបស្បែកពិតស្ពាយចំហៀងម៉ូដ Monogram',
      descriptionEn:
          'Crafted from Italian full-grain vegetable-tanned calfskin. Features our signature gold-finished KALIP studio geometric clasp, an interior zip compartment, and an adjustable shoulder strap.',
      descriptionKm:
          'ផលិតពីស្បែកកូនគោអ៊ីតាលីគុណភាពលេខ១។ បំពាក់ដោយគន្លឹះចាក់សោលោហធាតុពណ៌មាសរលោង ថតខ្សែរូតខាងក្នុង និងខ្សែស្ពាយកែសម្រួលបាន។',
      priceUsd: 295.0,
      originalPriceUsd: 350.0,
      categoryId: 'bags',
      gender: 'women',
      colors: [
        ProductColor(nameEn: 'Saddle Tan', nameKm: 'ពណ៌ត្នោតស្បែកសត្វ', color: Color(0xFF9E5E32)),
        ProductColor(nameEn: 'Noir Black', nameKm: 'ពណ៌ខ្មៅប្រណីត', color: Color(0xFF111111)),
        ProductColor(nameEn: 'Cream White', nameKm: 'ពណ៌សក្រែម', color: Color(0xFFF5F3EC)),
      ],
      sizes: ['One Size (22x16x7 cm)'],
      images: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 3,
      rating: 5.0,
      reviewCount: 45,
      isNewArrival: false,
      isBestSeller: true,
      isFeatured: true,
      detailsEn: [
        'Full-grain vegetable tanned Italian leather',
        'Custom 24k gold-plated brass hardware',
        'Microfiber suede lining with card slots',
        'Dust bag and gift box included',
      ],
      detailsKm: [
        'ស្បែកកូនគោអ៊ីតាលី 100% មិនងាយឆ្កូត',
        'គ្រឿងលោហធាតុស្រោបមាស 24k មិនប្រែពណ៌',
        'ស្រទាប់ក្នុងស្បែក Suede ទន់ស្រួលដាក់ទូរស័ព្ទ',
        'រួមបញ្ចូលទាំងថង់ក្រណាត់ការពារ និងប្រអប់កាដូប្រណីត',
      ],
      materialEn: '100% Italian Full-Grain Calf Leather',
      materialKm: 'ស្បែកកូនគោអ៊ីតាលីសុទ្ធ 100%',
    ),
    ProductModel(
      id: 'sh-006',
      nameEn: 'Minimalist Suede Penny Loafers',
      nameKm: 'ស្បែកជើងឡូហ្វឺរស្បែក Suede ទាន់សម័យ',
      descriptionEn:
          'Hand-stitched in Florence with velvety Italian suede and Blake-stitched leather soles. Ultra-light, flexible, and comfortable with or without socks.',
      descriptionKm:
          'ដេរដោយដៃយ៉ាងប្រណីតពីស្បែក Suede អ៊ីតាលី និងបាតស្បែកសុទ្ធ។ ស្រាល ស្រួលពាក់ដើរ និងទន់ជើងបំផុត។',
      priceUsd: 195.0,
      originalPriceUsd: null,
      categoryId: 'footwear',
      gender: 'men',
      colors: [
        ProductColor(nameEn: 'Chestnut Brown', nameKm: 'ពណ៌ត្នោតគ្រាប់កាតាញ៉ា', color: Color(0xFF6B4423)),
        ProductColor(nameEn: 'Sand Taupe', nameKm: 'ពណ៌ខ្សាច់ប្រផេះ', color: Color(0xFF9E9282)),
      ],
      sizes: ['40', '41', '42', '43', '44'],
      images: [
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 7,
      rating: 4.8,
      reviewCount: 19,
      isNewArrival: true,
      isBestSeller: false,
      isFeatured: false,
      detailsEn: [
        'Italian reverse calf suede',
        'Traditional Blake stitch construction',
        'Cushioned memory foam insole',
      ],
      detailsKm: [
        'ស្បែកកូនគោ Suede នាំចូលពីអ៊ីតាលី',
        'ដេរភ្ជាប់បាតស្បែកតាមបែប Blake Stitch',
        'ទ្រនាប់បាតជើងទន់បែប Memory Foam មិនឈឺជើង',
      ],
      materialEn: 'Calf Suede Leather upper, Calfskin lining',
      materialKm: 'ស្បែកកូនគោ Suede និងស្រទាប់ស្បែកសុទ្ធ',
    ),
    ProductModel(
      id: 'sh-007',
      nameEn: 'Artisanal Handwoven Silk Scarf',
      nameKm: 'កន្សែងសូត្រត្បាញដោយដៃលក្ខណៈខ្មែរបុរាណ',
      descriptionEn:
          'Honoring Cambodian silk weaving heritage, this exquisite scarf is woven by master artisans in Takeo province, blending traditional golden thread accents with contemporary Parisian geometry.',
      descriptionKm:
          'លើកកម្ពស់សិល្បៈតម្បាញសូត្រខ្មែរ កន្សែងនេះត្បាញដោយដៃដោយជាងជំនាញក្នុងខេត្តតាកែវ រួមបញ្ចូលខ្សែសរសៃមាស និងក្បាច់រចនាបែបសម័យថ្មី។',
      priceUsd: 75.0,
      originalPriceUsd: 90.0,
      categoryId: 'accessories',
      gender: 'unisex',
      colors: [
        ProductColor(nameEn: 'Golden Sand', nameKm: 'ពណ៌ខ្សាច់មាស', color: Color(0xFFD4AF37)),
        ProductColor(nameEn: 'Lotus Pink', nameKm: 'ពណ៌ផ្កាឈូកស្រាល', color: Color(0xFFD6A2A8)),
      ],
      sizes: ['One Size (70x190 cm)'],
      images: [
        'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?q=80&w=800&auto=format&fit=crop',
      ],
      stockQuantity: 15,
      rating: 5.0,
      reviewCount: 31,
      isNewArrival: false,
      isBestSeller: true,
      isFeatured: true,
      detailsEn: [
        '100% Handspun Cambodian Golden Silk',
        'Naturally dyed with local botanicals',
        'Hand-rolled and hand-fringed hems',
      ],
      detailsKm: [
        'សូត្រមាសខ្មែរត្បាញដោយដៃ 100%',
        'ជ្រលក់ពណ៌ធម្មជាតិពីរុក្ខជាតិក្នុងស្រុក',
        'ដេរជាយដោយដៃយ៉ាងផ្ចិតផ្ចង់',
      ],
      materialEn: '100% Takeo Golden Silk',
      materialKm: 'សូត្រមាសខេត្តតាកែវសុទ្ធ 100%',
    ),
  ];

  // Initial Cart Items
  static List<CartItemModel> initialCart = [
    CartItemModel(
      id: 'cart-1',
      product: products[0], // Atelier Silk Wrap Midi Dress
      selectedColor: products[0].colors[0],
      selectedSize: 'S',
      quantity: 1,
    ),
    CartItemModel(
      id: 'cart-2',
      product: products[1], // Relaxed Linen Camp Collar Overshirt
      selectedColor: products[1].colors[0],
      selectedSize: 'M',
      quantity: 1,
    ),
  ];

  // Sample Orders
  static List<OrderModel> sampleOrders = [
    OrderModel(
      id: 'ord-1001',
      orderNumber: 'SH-2026-8941',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: OrderStatus.delivering,
      items: [
        CartItemModel(
          id: 'item-1',
          product: products[4], // Monogram Flap Bag
          selectedColor: products[4].colors[0],
          selectedSize: 'One Size',
          quantity: 1,
        ),
      ],
      subtotalUsd: 295.0,
      deliveryFeeUsd: 0.0,
      discountUsd: 29.5, // 10% promo
      totalUsd: 265.5,
      deliveryAddress: 'Street 302, Boeng Keng Kang 1, Chamkar Mon, Phnom Penh',
      paymentMethod: 'KHQR (Bakong Payment)',
      trackingCode: 'VET-PP-98231',
    ),
    OrderModel(
      id: 'ord-1002',
      orderNumber: 'SH-2026-7281',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      status: OrderStatus.delivered,
      items: [
        CartItemModel(
          id: 'item-2',
          product: products[1], // Linen shirt
          selectedColor: products[1].colors[1],
          selectedSize: 'L',
          quantity: 1,
        ),
        CartItemModel(
          id: 'item-3',
          product: products[6], // Silk scarf
          selectedColor: products[6].colors[0],
          selectedSize: 'One Size',
          quantity: 1,
        ),
      ],
      subtotalUsd: 190.0,
      deliveryFeeUsd: 0.0,
      discountUsd: 0.0,
      totalUsd: 190.0,
      deliveryAddress: 'Wat Bo Road, Sala Kamreuk, Siem Reap',
      paymentMethod: 'Cash on Delivery (COD)',
      trackingCode: 'JNT-KH-44109',
    ),
  ];
}
