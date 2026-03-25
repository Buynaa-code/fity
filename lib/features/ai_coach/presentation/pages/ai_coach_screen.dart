import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../widgets/coach_chat_bubble.dart';
import '../widgets/workout_suggestion_card.dart';
import '../widgets/daily_insight_card.dart';
import '../widgets/quick_question_chips.dart';
import '../../domain/entities/coach_message.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _waveController;
  late AnimationController _pulseController;

  bool _isTyping = false;
  bool _showSuggestions = true;

  final List<CoachMessage> _messages = [];

  // AI Coach-н өгөгдлүүд
  final List<String> _quickQuestions = [
    'Өнөөдөр ямар дасгал хийх вэ?',
    'Жин хасахад юу хийх вэ?',
    'Булчин өсгөхөд зөвлөгөө',
    'Сунгалтын дасгал',
    'Өглөөний дасгал',
  ];

  final List<WorkoutSuggestion> _suggestions = [
    const WorkoutSuggestion(
      id: '1',
      name: 'HIIT Шатаалт',
      description: 'Өндөр эрчимтэй интервал дасгал',
      durationMinutes: 20,
      calories: 300,
      difficulty: 'Хүнд',
      exercises: ['Burpees', 'Mountain Climbers', 'Jump Squats', 'High Knees'],
      reason: 'Калори хурдан шатаах, бодисын солилцоог идэвхжүүлэх',
    ),
    const WorkoutSuggestion(
      id: '2',
      name: 'Хүч чадлын дасгал',
      description: 'Булчин хөгжүүлэх үндсэн дасгал',
      durationMinutes: 35,
      calories: 250,
      difficulty: 'Дундаж',
      exercises: ['Push-ups', 'Squats', 'Lunges', 'Plank', 'Dips'],
      reason: 'Булчингийн хүч чадал нэмэгдүүлэх',
    ),
    const WorkoutSuggestion(
      id: '3',
      name: 'Йога & Сунгалт',
      description: 'Биеийн уян хатан чанар сайжруулах',
      durationMinutes: 25,
      calories: 100,
      difficulty: 'Амархан',
      exercises: ['Cat-Cow', 'Downward Dog', 'Warrior Pose', 'Child\'s Pose'],
      reason: 'Стресс тайлах, уян хатан чанар',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Анхны мэндчилгээ
    _addInitialMessages();
  }

  void _addInitialMessages() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Өглөөний мэнд! ☀️';
    } else if (hour < 18) {
      greeting = 'Өдрийн мэнд! 💪';
    } else {
      greeting = 'Оройн мэнд! 🌙';
    }

    setState(() {
      _messages.add(CoachMessage(
        id: '1',
        content: greeting,
        type: MessageType.coach,
        timestamp: DateTime.now(),
      ));

      _messages.add(CoachMessage(
        id: '2',
        content:
            'Би таны хувийн AI дасгалжуулагч. Танд өнөөдөр юугаар туслах вэ? Дасгалын зөвлөгөө, хоолны зөвлөмж, эсвэл урам зориг хэрэгтэй юу?',
        type: MessageType.coach,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        type: MessageType.user,
        timestamp: DateTime.now(),
      ));
      _showSuggestions = false;
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // AI хариу (жишээ)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_generateResponse(text));
        });
        _scrollToBottom();
      }
    });
  }

  CoachMessage _generateResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('дасгал') || lowerQuery.contains('өнөөдөр')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '💪 Өнөөдрийн таны түвшинд тохирох дасгалуудыг санал болгоё:\n\n'
            '1. **Халаалт** (5 мин) - Биеийг бэлтгэх\n'
            '2. **HIIT** (15 мин) - Өндөр эрчимтэй\n'
            '3. **Хүч чадал** (20 мин) - Булчин хөгжүүлэх\n'
            '4. **Сунгалт** (5 мин) - Тайвшрах\n\n'
            'Аль нэгийг сонгоод эхлэх үү? 🏋️‍♂️',
        type: MessageType.workout,
        timestamp: DateTime.now(),
      );
    } else if (lowerQuery.contains('жин') || lowerQuery.contains('турах')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '🎯 Жин хасахад дараах зөвлөмжүүдийг анхаараарай:\n\n'
            '✅ **Калорийн дефицит** - Өдөрт 300-500 ккал бага хэрэглэх\n'
            '✅ **Кардио дасгал** - Долоо хоногт 3-4 удаа\n'
            '✅ **Хүч чадлын дасгал** - Булчин = Илүү калори шатаалт\n'
            '✅ **Ус уух** - Өдөрт 2-3 литр\n'
            '✅ **Нойр** - 7-8 цаг\n\n'
            'Илүү дэлгэрэнгүй зөвлөгөө хэрэгтэй юу?',
        type: MessageType.tip,
        timestamp: DateTime.now(),
      );
    } else if (lowerQuery.contains('булчин') || lowerQuery.contains('өсгөх')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '💪 Булчин өсгөхөд:\n\n'
            '🥩 **Уураг** - Биеийн жин x 1.6-2.2 гр\n'
            '🏋️ **Progressive overload** - Ачааллыг аажмаар нэмэх\n'
            '😴 **Нөхөн сэргээлт** - Булчин амрах хугацаа өгөх\n'
            '📅 **Тогтвортой байдал** - Долоо хоногт 4-5 удаа\n\n'
            'Compound дасгалуудад (Squat, Deadlift, Bench Press) анхаар!',
        type: MessageType.coach,
        timestamp: DateTime.now(),
      );
    } else if (lowerQuery.contains('сунгалт') || lowerQuery.contains('уян')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '🧘 Сунгалтын үр дүнтэй дасгалууд:\n\n'
            '• **Хамстринг сунгалт** - 30 сек\n'
            '• **Мөр сунгалт** - Тал бүр 20 сек\n'
            '• **Нуруу эргүүлэх** - 10 удаа\n'
            '• **Cat-Cow** - 10 давталт\n'
            '• **Child\'s pose** - 30 сек\n\n'
            'Дасгалын өмнө болон дараа сунгалт хийвэл гэмтлээс сэргийлнэ! 🙏',
        type: MessageType.workout,
        timestamp: DateTime.now(),
      );
    } else if (lowerQuery.contains('өглөө')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '🌅 Өглөөний эрч дасгал (10 мин):\n\n'
            '1. **Jumping Jacks** - 30 сек\n'
            '2. **High Knees** - 30 сек\n'
            '3. **Squat** - 15 удаа\n'
            '4. **Push-ups** - 10 удаа\n'
            '5. **Plank** - 30 сек\n'
            '6. **Stretching** - 2 мин\n\n'
            'Өглөө дасгал хийвэл бүх өдөржингөө эрч хүчтэй байна! ⚡',
        type: MessageType.motivation,
        timestamp: DateTime.now(),
      );
    }

    return CoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          '🤔 Сайхан асуулт! Танд тусалж чадахдаа баяртай байна.\n\n'
          'Дараах сэдвүүдээр зөвлөгөө өгч чадна:\n'
          '• Дасгалын төлөвлөгөө\n'
          '• Хоол тэжээл\n'
          '• Жин хасах/нэмэх\n'
          '• Булчин хөгжүүлэх\n'
          '• Урам зориг\n\n'
          'Ямар нэг тодорхой зорилго байна уу?',
      type: MessageType.coach,
      timestamp: DateTime.now(),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildChatArea(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // AI Avatar with animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF72928).withValues(
                        alpha: 0.3 + (_pulseController.value * 0.2),
                      ),
                      blurRadius: 12 + (_pulseController.value * 4),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Дасгалжуулагч',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Идэвхтэй',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showCoachInfo();
            },
            icon: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Daily insight
        if (_showSuggestions) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DailyInsightCard(
                tip: _getDailyTip(),
              ),
            ),
          ),

          // Workout suggestions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Санал болгох дасгалууд',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < _suggestions.length - 1 ? 12 : 0,
                          ),
                          child: WorkoutSuggestionCard(
                            suggestion: _suggestions[index],
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _sendMessage(
                                '${_suggestions[index].name} дасгалын талаар дэлгэрэнгүй хэлж өгөөч',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        // Messages
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CoachChatBubble(message: message),
                );
              },
              childCount: _messages.length,
            ),
          ),
        ),

        // Typing indicator
        if (_isTyping)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTypingIndicator(),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final offset = math.sin(
                    (_waveController.value * 2 * math.pi) + (index * 0.5),
                  );
                  return Container(
                    margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                    child: Transform.translate(
                      offset: Offset(0, offset * 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF72928),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick questions
          QuickQuestionChips(
            questions: _quickQuestions,
            onQuestionTap: (question) {
              _sendMessage(question);
            },
          ),
          const SizedBox(height: 12),
          // Input field
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Асуултаа бичээрэй...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _sendMessage(_messageController.text),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF72928).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DailyTip _getDailyTip() {
    final tips = [
      DailyTip(
        id: '1',
        title: 'Өглөө ус уух',
        content:
            'Өглөө босоод хоосон гэдэстэй 2 аяга ус уух нь бодисын солилцоог 24%-иар нэмэгдүүлдэг.',
        category: 'Эрүүл мэнд',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF3498DB),
      ),
      DailyTip(
        id: '2',
        title: 'Тогтвортой байдал',
        content:
            'Долоо хоногт 3 удаа 30 минутын дасгал хийвэл бие махбодын байдал 40%-иар сайжирна.',
        category: 'Дасгал',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF9B59B6),
      ),
      DailyTip(
        id: '3',
        title: 'Нойрны ач холбогдол',
        content:
            '7-8 цагийн нойр авснаар булчин сэргээлт 60%-иар хурдасна.',
        category: 'Нөхөн сэргээлт',
        icon: Icons.bedtime_rounded,
        color: const Color(0xFF1ABC9C),
      ),
    ];

    return tips[DateTime.now().day % tips.length];
  }

  void _showCoachInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI Дасгалжуулагч',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Таны хувийн фитнесс зөвлөх',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.fitness_center_rounded, 'Дасгалын төлөвлөгөө'),
                  _buildInfoRow(Icons.restaurant_rounded, 'Хоол тэжээлийн зөвлөгөө'),
                  _buildInfoRow(Icons.trending_up_rounded, 'Явцын шинжилгээ'),
                  _buildInfoRow(Icons.emoji_events_rounded, 'Урам зоригийн дэмжлэг'),
                  _buildInfoRow(Icons.schedule_rounded, '24/7 бэлэн'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF72928).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF72928),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
