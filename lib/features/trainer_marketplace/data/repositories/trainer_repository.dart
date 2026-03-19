import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trainer_model.dart';
import '../models/booking_model.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/entities/booking.dart';

class TrainerRepository {
  static const String _bookingsKey = 'trainer_bookings';

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
}
