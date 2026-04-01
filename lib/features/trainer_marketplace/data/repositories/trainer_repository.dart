import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trainer_model.dart';
import '../models/booking_model.dart';
import '../models/trainer_subscription_model.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/trainer_subscription.dart';

class TrainerRepository {
  static const String _bookingsKey = 'trainer_bookings';
  static const String _trainersKey = 'registered_trainers';
  static const String _subscriptionsKey = 'trainer_subscriptions';
  static const String _reviewsKey = 'trainer_reviews';

  // Mock trainers data
  List<Trainer> getTrainers() {
    final now = DateTime.now();
    return [
      TrainerModel(
        id: '1',
        name: 'Батболд Д.',
        bio:
            'Мэргэжлийн фитнесс дасгалжуулагч. 10 жилийн туршлагатай. Олон улсын тэмцээнд амжилттай оролцсон.',
        imageUrl: 'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=400',
        specialties: ['Strength', 'Bodybuilding', 'Weight Loss'],
        hourlyRate: 50000,
        rating: 4.9,
        reviewCount: 127,
        experienceYears: 10,
        certifications: ['NASM CPT', 'ACE Certified'],
        availableSlots: _generateTimeSlots(now, '1'),
      ),
      TrainerModel(
        id: '2',
        name: 'Сарангэрэл Б.',
        bio:
            'Йога болон пилатес мэргэжилтэн. Уян хатан байдал, стресс тайлах арга техникт мэргэшсэн.',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
        specialties: ['Yoga', 'Pilates', 'Flexibility'],
        hourlyRate: 45000,
        rating: 4.8,
        reviewCount: 89,
        experienceYears: 7,
        certifications: ['RYT 500', 'Pilates Certified'],
        availableSlots: _generateTimeSlots(now, '2'),
      ),
      TrainerModel(
        id: '3',
        name: 'Тэмүүлэн Г.',
        bio:
            'Кардио болон HIIT дасгалжуулагч. Таны зорилгод хүрэхэд туслах бэлтгэлийн хөтөлбөр боловсруулна.',
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
        specialties: ['Cardio', 'HIIT', 'Endurance'],
        hourlyRate: 40000,
        rating: 4.7,
        reviewCount: 64,
        experienceYears: 5,
        certifications: ['ACE GFI', 'CrossFit L2'],
        availableSlots: _generateTimeSlots(now, '3'),
      ),
      TrainerModel(
        id: '4',
        name: 'Номин-Эрдэнэ А.',
        bio:
            'Хоол тэжээл зөвлөгч, фитнесс дасгалжуулагч. Эрүүл амьдралын хэв маягт шилжихэд туслана.',
        imageUrl: 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
        specialties: ['Nutrition', 'Weight Loss', 'Lifestyle'],
        hourlyRate: 55000,
        rating: 4.9,
        reviewCount: 156,
        experienceYears: 8,
        certifications: ['Precision Nutrition', 'ISSA CPT'],
        availableSlots: _generateTimeSlots(now, '4'),
      ),
      TrainerModel(
        id: '5',
        name: 'Ганзориг М.',
        bio:
            'Бокс, кикбоксинг дасгалжуулагч. Өөрийгөө хамгаалах ур чадвар, бие бялдрын бэлтгэл.',
        imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
        specialties: ['Boxing', 'Kickboxing', 'Self-Defense'],
        hourlyRate: 60000,
        rating: 4.8,
        reviewCount: 93,
        experienceYears: 12,
        certifications: ['Boxing Coach', 'MMA Certified'],
        availableSlots: _generateTimeSlots(now, '5'),
      ),
    ];
  }

  static List<TimeSlotModel> _generateTimeSlots(DateTime baseDate, String trainerId) {
    final slots = <TimeSlotModel>[];
    for (int day = 0; day < 7; day++) {
      final date = baseDate.add(Duration(days: day));
      for (int hour = 9; hour < 18; hour += 2) {
        slots.add(TimeSlotModel(
          id: '${trainerId}_${day}_$hour',
          dateTime: DateTime(date.year, date.month, date.day, hour),
          durationMinutes: 60,
          isAvailable: (day + hour + int.parse(trainerId)) % 3 != 0,
        ));
      }
    }
    return slots;
  }

  Future<Trainer?> getTrainerByIdAsync(String id) async {
    // First check mock trainers
    final mockTrainers = getTrainers();
    try {
      return mockTrainers.firstWhere((t) => t.id == id);
    } catch (_) {
      // Then check registered trainers
      final registeredTrainers = await getRegisteredTrainers();
      try {
        return registeredTrainers.firstWhere((t) => t.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Trainer? getTrainerById(String id) {
    final trainers = getTrainers();
    try {
      return trainers.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Review> getTrainerReviews(String trainerId) {
    final now = DateTime.now();
    return [
      ReviewModel(
        id: '1',
        trainerId: trainerId,
        userId: 'user1',
        userName: 'Болор Э.',
        userImageUrl: '',
        rating: 5.0,
        comment: 'Маш сайн дасгалжуулагч! Зорилгодоо хүрэхэд маш их тусалсан.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: '2',
        trainerId: trainerId,
        userId: 'user2',
        userName: 'Түвшин Б.',
        userImageUrl: '',
        rating: 4.5,
        comment: 'Мэргэжлийн түвшинд заадаг. Цаг баримталдаг.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ReviewModel(
        id: '3',
        trainerId: trainerId,
        userId: 'user3',
        userName: 'Ану Д.',
        userImageUrl: '',
        rating: 5.0,
        comment: 'Гайхалтай туршлага! Бусдад санал болгож байна.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  // Booking methods
  Future<List<Booking>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList(_bookingsKey) ?? [];
    return bookingsJson
        .map((json) => BookingModel.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  Future<Booking> createBooking({
    required Trainer trainer,
    required TimeSlot slot,
    required String userId,
    String? notes,
  }) async {
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainerId: trainer.id,
      trainerName: trainer.name,
      trainerImageUrl: trainer.imageUrl,
      userId: userId,
      scheduledAt: slot.dateTime,
      durationMinutes: slot.durationMinutes,
      price: trainer.hourlyRate,
      status: BookingStatus.confirmed,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList(_bookingsKey) ?? [];
    bookingsJson.add(jsonEncode(booking.toJson()));
    await prefs.setStringList(_bookingsKey, bookingsJson);

    return booking;
  }

  Future<void> cancelBooking(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList(_bookingsKey) ?? [];
    final bookings = bookingsJson
        .map((json) => BookingModel.fromJson(jsonDecode(json)))
        .toList();

    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      bookings[index] = bookings[index].copyWith(status: BookingStatus.cancelled);
      await prefs.setStringList(
        _bookingsKey,
        bookings.map((b) => jsonEncode(b.toJson())).toList(),
      );
    }
  }

  // Seed test data for review testing
  Future<void> seedTestBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final existingBookings = prefs.getStringList(_bookingsKey) ?? [];

    // Check if test data already exists
    if (existingBookings.any((b) => b.contains('test_completed'))) {
      return;
    }

    final trainers = getTrainers();
    final now = DateTime.now();

    final testBookings = [
      // Completed booking - can leave review
      BookingModel(
        id: 'test_completed_1',
        trainerId: trainers[0].id,
        trainerName: trainers[0].name,
        trainerImageUrl: trainers[0].imageUrl,
        userId: 'current_user',
        scheduledAt: now.subtract(const Duration(days: 3)),
        durationMinutes: 60,
        price: trainers[0].hourlyRate,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 4)),
        hasReview: false,
      ),
      // Another completed booking
      BookingModel(
        id: 'test_completed_2',
        trainerId: trainers[1].id,
        trainerName: trainers[1].name,
        trainerImageUrl: trainers[1].imageUrl,
        userId: 'current_user',
        scheduledAt: now.subtract(const Duration(days: 7)),
        durationMinutes: 60,
        price: trainers[1].hourlyRate,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 8)),
        hasReview: false,
      ),
      // Upcoming booking
      BookingModel(
        id: 'test_upcoming_1',
        trainerId: trainers[2].id,
        trainerName: trainers[2].name,
        trainerImageUrl: trainers[2].imageUrl,
        userId: 'current_user',
        scheduledAt: now.add(const Duration(days: 2)),
        durationMinutes: 60,
        price: trainers[2].hourlyRate,
        status: BookingStatus.confirmed,
        createdAt: now,
        hasReview: false,
      ),
    ];

    for (final booking in testBookings) {
      existingBookings.add(jsonEncode(booking.toJson()));
    }

    await prefs.setStringList(_bookingsKey, existingBookings);
  }

  // Trainer registration methods
  Future<List<Trainer>> getRegisteredTrainers() async {
    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    return trainersJson
        .map((json) => TrainerModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<Trainer> createTrainer({
    required String userId,
    required String name,
    required String bio,
    required String phone,
    required List<String> specialties,
    required double hourlyRate,
    required int experienceYears,
    required List<String> certifications,
    required List<TimeSlot> availableSlots,
    String? imageUrl,
    List<String>? photoUrls,
  }) async {
    final trainer = TrainerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      bio: bio,
      phone: phone,
      imageUrl: imageUrl ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$userId',
      specialties: specialties,
      hourlyRate: hourlyRate,
      rating: 0.0,
      reviewCount: 0,
      experienceYears: experienceYears,
      certifications: certifications,
      availableSlots: availableSlots.map((s) => TimeSlotModel(
        id: s.id,
        dateTime: s.dateTime,
        durationMinutes: s.durationMinutes,
        isAvailable: s.isAvailable,
      )).toList(),
      isVerified: false,
      isActive: false,
      isFeatured: false,
      photoUrls: photoUrls ?? [],
      registeredAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    trainersJson.add(jsonEncode(trainer.toJson()));
    await prefs.setStringList(_trainersKey, trainersJson);

    return trainer;
  }

  Future<Trainer> updateTrainer(Trainer trainer) async {
    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    final trainers = trainersJson
        .map((json) => TrainerModel.fromJson(jsonDecode(json)))
        .toList();

    final index = trainers.indexWhere((t) => t.id == trainer.id);
    if (index != -1) {
      final updatedTrainer = TrainerModel.fromEntity(trainer);
      trainers[index] = updatedTrainer;
      await prefs.setStringList(
        _trainersKey,
        trainers.map((t) => jsonEncode(t.toJson())).toList(),
      );
      return updatedTrainer;
    }
    throw Exception('Дасгалжуулагч олдсонгүй');
  }

  Future<Trainer?> getTrainerByUserId(String userId) async {
    final registeredTrainers = await getRegisteredTrainers();
    try {
      return registeredTrainers.firstWhere((t) => t.userId == userId);
    } catch (_) {
      return null;
    }
  }

  // Subscription methods
  Future<List<TrainerSubscription>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionsJson = prefs.getStringList(_subscriptionsKey) ?? [];
    return subscriptionsJson
        .map((json) => TrainerSubscriptionModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<TrainerSubscription?> getActiveSubscription(String trainerId) async {
    final subscriptions = await getSubscriptions();
    try {
      return subscriptions.firstWhere(
        (s) => s.trainerId == trainerId && s.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<TrainerSubscription> createSubscription({
    required String trainerId,
    required SubscriptionTier tier,
  }) async {
    final now = DateTime.now();
    final subscription = TrainerSubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainerId: trainerId,
      tier: tier,
      status: SubscriptionStatus.active,
      price: TrainerSubscription.getTierPrice(tier),
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      createdAt: now,
    );

    final prefs = await SharedPreferences.getInstance();
    final subscriptionsJson = prefs.getStringList(_subscriptionsKey) ?? [];
    subscriptionsJson.add(jsonEncode(subscription.toJson()));
    await prefs.setStringList(_subscriptionsKey, subscriptionsJson);

    // Activate trainer and set subscription tier
    final trainers = await getRegisteredTrainers();
    final trainerIndex = trainers.indexWhere((t) => t.id == trainerId);
    if (trainerIndex != -1) {
      final updatedTrainer = trainers[trainerIndex].copyWith(
        isActive: true,
        subscriptionTier: tier,
        isFeatured: tier == SubscriptionTier.professional || tier == SubscriptionTier.premium,
      );
      await updateTrainer(updatedTrainer);
    }

    return subscription;
  }

  // Review methods
  Future<Review> createReview({
    required String trainerId,
    required String bookingId,
    required String userId,
    required String userName,
    required String userImageUrl,
    required double rating,
    required String comment,
  }) async {
    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainerId: trainerId,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    // Save review
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    reviewsJson.add(jsonEncode(review.toJson()));
    await prefs.setStringList(_reviewsKey, reviewsJson);

    // Update booking hasReview
    await updateBookingReview(bookingId, review.id);

    // Update trainer rating
    await _updateTrainerRating(trainerId);

    return review;
  }

  Future<void> updateBookingReview(String bookingId, String reviewId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList(_bookingsKey) ?? [];
    final bookings = bookingsJson
        .map((json) => BookingModel.fromJson(jsonDecode(json)))
        .toList();

    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      bookings[index] = bookings[index].copyWith(
        hasReview: true,
        reviewId: reviewId,
      );
      await prefs.setStringList(
        _bookingsKey,
        bookings.map((b) => jsonEncode(b.toJson())).toList(),
      );
    }
  }

  Future<void> _updateTrainerRating(String trainerId) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    final reviews = reviewsJson
        .map((json) => ReviewModel.fromJson(jsonDecode(json)))
        .where((r) => r.trainerId == trainerId)
        .toList();

    if (reviews.isEmpty) return;

    final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    // Update registered trainer
    final trainers = await getRegisteredTrainers();
    final index = trainers.indexWhere((t) => t.id == trainerId);
    if (index != -1) {
      final updatedTrainer = trainers[index].copyWith(
        rating: avgRating,
        reviewCount: reviews.length,
      );
      await updateTrainer(updatedTrainer);
    }
  }

  Future<List<Review>> getReviewsByTrainerId(String trainerId) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    return reviewsJson
        .map((json) => ReviewModel.fromJson(jsonDecode(json)))
        .where((r) => r.trainerId == trainerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Booking>> getCompletedBookingsWithoutReview(String userId) async {
    final bookings = await getBookings();
    return bookings
        .where((b) =>
            b.userId == userId &&
            b.status == BookingStatus.completed &&
            !b.hasReview)
        .toList();
  }

  // Featured trainers for home screen carousel
  Future<List<Trainer>> getFeaturedTrainers({int limit = 10}) async {
    final registeredTrainers = await getRegisteredTrainers();
    final mockTrainers = getTrainers();

    // Combine registered trainers with mock trainers for demo
    final allTrainers = [...registeredTrainers, ...mockTrainers];

    // Filter active trainers with professional or premium subscription
    final featuredTrainers = allTrainers.where((t) => t.canBeFeatured).toList();

    // Sort: premium first, then professional, then by rating
    featuredTrainers.sort((a, b) {
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;
      if (a.isProfessional && !b.isProfessional) return -1;
      if (!a.isProfessional && b.isProfessional) return 1;
      return b.rating.compareTo(a.rating);
    });

    // For demo purposes, return mock trainers with simulated featured status
    if (featuredTrainers.isEmpty) {
      return mockTrainers.take(limit).map((t) => t.copyWith(
        subscriptionTier: SubscriptionTier.professional,
        isActive: true,
        isFeatured: true,
      )).toList();
    }

    return featuredTrainers.take(limit).toList();
  }

  // Get all trainers (mock + registered)
  Future<List<Trainer>> getAllTrainers() async {
    final registeredTrainers = await getRegisteredTrainers();
    final mockTrainers = getTrainers();
    return [...registeredTrainers.where((t) => t.isActive && t.isApproved), ...mockTrainers];
  }

  // Trainer registration with pending status
  Future<Trainer> registerTrainer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<String> specialties,
    required int experienceYears,
    required List<String> certificationUrls,
    required String bio,
    required double hourlyRate,
    String? imageUrl,
    List<String>? photoUrls,
  }) async {
    final trainer = TrainerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      imageUrl: imageUrl ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$email',
      specialties: specialties,
      hourlyRate: hourlyRate,
      rating: 0.0,
      reviewCount: 0,
      experienceYears: experienceYears,
      certifications: [],
      certificationUrls: certificationUrls,
      availableSlots: [],
      isVerified: false,
      isActive: false,
      isFeatured: false,
      photoUrls: photoUrls ?? [],
      registeredAt: DateTime.now(),
      status: TrainerStatus.pending,
    );

    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    trainersJson.add(jsonEncode(trainer.toJson()));
    await prefs.setStringList(_trainersKey, trainersJson);

    return trainer;
  }

  // Get pending trainers for admin
  Future<List<Trainer>> getPendingTrainers() async {
    final trainers = await getRegisteredTrainers();
    return trainers.where((t) => t.status == TrainerStatus.pending).toList();
  }

  // Approve trainer
  Future<void> approveTrainer(String trainerId, String adminId) async {
    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    final trainers = trainersJson
        .map((json) => TrainerModel.fromJson(jsonDecode(json)))
        .toList();

    final index = trainers.indexWhere((t) => t.id == trainerId);
    if (index != -1) {
      trainers[index] = trainers[index].copyWith(
        status: TrainerStatus.approved,
        isActive: true,
        isVerified: true,
        approvedAt: DateTime.now(),
        approvedBy: adminId,
      );
      await prefs.setStringList(
        _trainersKey,
        trainers.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }
  }

  // Reject trainer
  Future<void> rejectTrainer(String trainerId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final trainersJson = prefs.getStringList(_trainersKey) ?? [];
    final trainers = trainersJson
        .map((json) => TrainerModel.fromJson(jsonDecode(json)))
        .toList();

    final index = trainers.indexWhere((t) => t.id == trainerId);
    if (index != -1) {
      trainers[index] = trainers[index].copyWith(
        status: TrainerStatus.rejected,
        rejectionReason: reason,
      );
      await prefs.setStringList(
        _trainersKey,
        trainers.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }
  }

  // Get trainer status by email
  Future<TrainerStatus?> getTrainerStatusByEmail(String email) async {
    final trainers = await getRegisteredTrainers();
    try {
      final trainer = trainers.firstWhere((t) => t.email == email);
      return trainer.status;
    } catch (_) {
      return null;
    }
  }

  // Get trainer by email
  Future<Trainer?> getTrainerByEmail(String email) async {
    final trainers = await getRegisteredTrainers();
    try {
      return trainers.firstWhere((t) => t.email == email);
    } catch (_) {
      return null;
    }
  }

  // Trainer login
  Future<Trainer?> trainerLogin(String email, String password) async {
    // For demo, just check if trainer exists with email
    final trainer = await getTrainerByEmail(email);
    return trainer;
  }
}
