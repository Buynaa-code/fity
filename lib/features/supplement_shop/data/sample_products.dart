import '../domain/entities/product.dart';

final List<Product> sampleProducts = [
  // Protein
  const Product(
    id: 'p1',
    name: 'Whey Protein Gold Standard',
    price: 189000,
    image: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400',
    description:
        'Дэлхийд хамгийн их борлуулалттай whey уураг. 24г уураг, 5.5г BCAA, 4г глютамин агуулсан. Амт: Шоколад, Ванил, Гүзээлзгэнэ.',
    category: ProductCategory.protein,
    rating: 4.8,
    reviewCount: 1250,
  ),
  const Product(
    id: 'p2',
    name: 'Casein Protein',
    price: 175000,
    image: 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400',
    description:
        'Удаан шингэдэг казейн уураг. Унтахын өмнө хэрэглэхэд тохиромжтой. 24г уураг агуулсан.',
    category: ProductCategory.protein,
    rating: 4.6,
    reviewCount: 420,
  ),
  const Product(
    id: 'p3',
    name: 'ISO 100 Hydrolyzed',
    price: 245000,
    image: 'https://images.unsplash.com/photo-1594498653385-d5172c532c00?w=400',
    description:
        'Хамгийн цэвэр изолейт уураг. 25г уураг, 0г нүүрс ус, 0г өөх тос. Түргэн шингэдэг.',
    category: ProductCategory.protein,
    rating: 4.9,
    reviewCount: 890,
  ),

  // Vitamins
  const Product(
    id: 'v1',
    name: 'Multivitamin Daily',
    price: 45000,
    image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
    description:
        'Өдөр тутмын витамин, эрдэс бодисын цогц бүтээгдэхүүн. 23 төрлийн витамин, эрдэс агуулсан.',
    category: ProductCategory.vitamins,
    rating: 4.5,
    reviewCount: 678,
  ),
  const Product(
    id: 'v2',
    name: 'Vitamin D3 5000IU',
    price: 35000,
    image: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=400',
    description:
        'D3 витамин. Ясны эрүүл мэнд, дархлаа дэмжих. 120 ширхэг шахмал.',
    category: ProductCategory.vitamins,
    rating: 4.7,
    reviewCount: 445,
  ),
  const Product(
    id: 'v3',
    name: 'Omega-3 Fish Oil',
    price: 55000,
    image: 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=400',
    description:
        'Цэвэр загасны тос. Зүрх судас, тархины эрүүл мэндэд тустай. EPA 360mg, DHA 240mg.',
    category: ProductCategory.vitamins,
    rating: 4.6,
    reviewCount: 320,
  ),

  // Pre-workout
  const Product(
    id: 'pw1',
    name: 'C4 Original Pre-Workout',
    price: 85000,
    image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
    description:
        'Дасгалын өмнө хэрэглэх энерги нэмэгдүүлэгч. Кофейн 150mg, Бета-аланин, Креатин агуулсан.',
    category: ProductCategory.preworkout,
    rating: 4.4,
    reviewCount: 890,
  ),
  const Product(
    id: 'pw2',
    name: 'BCAA Energy',
    price: 65000,
    image: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
    description:
        'Салаалсан гинжит амин хүчил + кофейн. Дасгалын үед энергийг хадгалах.',
    category: ProductCategory.preworkout,
    rating: 4.3,
    reviewCount: 234,
  ),

  // Recovery
  const Product(
    id: 'r1',
    name: 'Creatine Monohydrate',
    price: 45000,
    image: 'https://images.unsplash.com/photo-1579722820903-3e0f13f94e16?w=400',
    description:
        'Цэвэр креатин моногидрат. Хүч чадал нэмэгдүүлэх, булчин сэргээхэд тусална. 100 удаагийн хэрэглээ.',
    category: ProductCategory.recovery,
    rating: 4.8,
    reviewCount: 1100,
  ),
  const Product(
    id: 'r2',
    name: 'Glutamine Powder',
    price: 55000,
    image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
    description:
        'L-Глютамин нунтаг. Булчингийн сэргэлт, дархлааг дэмжинэ. 60 удаагийн хэрэглээ.',
    category: ProductCategory.recovery,
    rating: 4.5,
    reviewCount: 290,
  ),

  // Weight Loss
  const Product(
    id: 'wl1',
    name: 'Fat Burner Extreme',
    price: 75000,
    image: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=400',
    description:
        'Өөх шатаагч. Бодисын солилцоог түргэсгэж, өөхийг шатаахад тусална. 60 ширхэг.',
    category: ProductCategory.weightLoss,
    rating: 4.2,
    reviewCount: 567,
  ),
  const Product(
    id: 'wl2',
    name: 'L-Carnitine 3000',
    price: 48000,
    image: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
    description:
        'Л-Карнитин шингэн. Өөхийг энерги болгон хувиргахад тусална. 20 ампул.',
    category: ProductCategory.weightLoss,
    rating: 4.4,
    reviewCount: 445,
  ),

  // Accessories
  const Product(
    id: 'a1',
    name: 'Shaker Bottle 700ml',
    price: 15000,
    image: 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
    description:
        'Уургийн шейкер. Бөмбөлөгтэй, задгай хийц. BPA-free пластик.',
    category: ProductCategory.accessories,
    rating: 4.6,
    reviewCount: 890,
  ),
  const Product(
    id: 'a2',
    name: 'Gym Gloves Pro',
    price: 35000,
    image: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
    description:
        'Дасгалын бээлий. Гар хамгаалах, барих чадварыг сайжруулна. Агааржуулалттай.',
    category: ProductCategory.accessories,
    rating: 4.5,
    reviewCount: 234,
  ),
  const Product(
    id: 'a3',
    name: 'Resistance Bands Set',
    price: 45000,
    image: 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400',
    description:
        'Эсэргүүцлийн туузны багц. 5 түвшний эсэргүүцэлтэй. Гэр, аялалд тохиромжтой.',
    category: ProductCategory.accessories,
    rating: 4.7,
    reviewCount: 567,
  ),
];
