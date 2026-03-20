---
name: fitness-app-development
description: Comprehensive guide for building world-class fitness applications. Use when designing, architecting, or implementing fitness app features including workouts, tracking, gamification, social features, and health integrations.
version: 1.0.0
---

# Fitness App Development Mastery

This skill provides comprehensive guidance for building world-class fitness applications based on analysis of top apps: **Strava**, **Nike Training Club**, **MyFitnessPal**, **Peloton**, **Freeletics**, **Apple Fitness+**, and **Zombies, Run!**

---

## Core Principles

### The 90% Rule
**90% of users abandon apps due to poor UX.** Every decision must prioritize:
- Instant value delivery
- Frictionless experience
- Motivating feedback
- Consistent engagement

### Fitness App Success Formula
```
Engagement = (Value × Motivation) / Friction
```

---

## 1. Onboarding Excellence

### 60-Second Rule
Users must complete setup and start their first workout within 60 seconds.

### Best Practices (from Calm, Nike Training Club)
1. **Skip login initially** - Show value before asking for commitment
2. **Ask goals first** - "What's your main goal?" with visual cards
3. **Minimal data collection** - Only what's essential
4. **Progressive profiling** - Collect more info over time
5. **Make every step skippable** - Never block progress

### Goal Selection UI Pattern
```
What brings you here?

┌─────────┐  ┌─────────┐  ┌─────────┐
│  💪     │  │  🏃     │  │  🧘     │
│ Build   │  │  Lose   │  │  Stay   │
│ Muscle  │  │ Weight  │  │ Active  │
└─────────┘  └─────────┘  └─────────┘
```

---

## 2. Gamification System (Octalysis Framework)

### The 8 Core Drives

| Drive | Implementation | Example Apps |
|-------|---------------|--------------|
| **Epic Meaning** | Hero narratives, saving humanity | Zombies, Run! |
| **Accomplishment** | Badges, trophies, progress bars | Nike Training Club |
| **Empowerment** | Custom workouts, avatar creation | FitRPG, Strava GPS Art |
| **Ownership** | Character progression, workout history | FitRPG |
| **Social Influence** | Leaderboards, kudos, challenges | Strava |
| **Scarcity** | Limited-time challenges, daily rewards | Nike Training Club |
| **Unpredictability** | Surprise rewards, random challenges | Zombies, Run! |
| **Loss Avoidance** | Streak protection, progress warnings | All top apps |

### Streak System Implementation
```dart
class StreakSystem {
  int currentStreak;
  int longestStreak;
  DateTime lastWorkoutDate;
  int freezesAvailable;

  bool isStreakActive() {
    final daysSinceLast = DateTime.now().difference(lastWorkoutDate).inDays;
    return daysSinceLast <= 1;
  }

  void useStreakFreeze() {
    if (freezesAvailable > 0 && !isStreakActive()) {
      freezesAvailable--;
      // Extend streak by 1 day
    }
  }
}
```

### Achievement Categories
- **Consistency**: 7-day streak, 30-day streak, 365-day streak
- **Volume**: First workout, 100 workouts, 1000 workouts
- **Performance**: Personal records, milestones
- **Social**: First friend, challenge winner
- **Exploration**: Try new exercise types

---

## 3. Workout System Architecture

### Timer Types
| Type | Description | Use Case |
|------|-------------|----------|
| **Countdown** | Fixed duration | Planks, holds |
| **Interval** | Work/rest cycles | HIIT, Tabata |
| **EMOM** | Every minute on the minute | CrossFit |
| **AMRAP** | As many reps as possible | Timed challenges |
| **Stopwatch** | Count up | Free workouts |

### Exercise Logging Data Model
```dart
class WorkoutLog {
  String odI;
  DateTime startTime;
  DateTime endTime;
  List<ExerciseSet> sets;
  int caloriesBurned;
  HeartRateData? heartRate;
  String? notes;
  double? perceivedExertion; // 1-10 RPE
}

class ExerciseSet {
  String exerciseId;
  int setNumber;
  int? reps;
  double? weight;
  Duration? duration;
  double? distance;
  bool isPersonalRecord;
}
```

### Workout Screen UX Principles
1. **Large, glanceable timer** - Readable from 3 feet away
2. **Minimal UI during exercise** - Remove distractions
3. **Audio cues** - Hands-free operation
4. **Haptic feedback** - Feel transitions without looking
5. **Easy pause/skip** - Thumb-accessible controls

---

## 4. Progress Tracking & Visualization

### Key Metrics to Track
- **Volume**: Sets × Reps × Weight
- **Frequency**: Workouts per week
- **Duration**: Total workout time
- **Consistency**: Streak length
- **Performance**: Personal records

### Visualization Best Practices
- Line charts for trends over time
- Bar charts for weekly/monthly comparison
- Progress rings for daily goals (Apple style)
- Highlight PRs with celebratory colors
- Show comparison to previous periods

### Progress Photo System
- Side-by-side comparison sliders
- Consistent framing guidelines (grid overlay)
- Privacy-first (local storage default)
- Optional encrypted cloud backup

---

## 5. Social & Community Features

### Activity Feed Design
```
┌─────────────────────────────────┐
│ 👤 Sarah completed              │
│    Morning HIIT • 32 min        │
│    🔥 340 cal burned            │
│                                 │
│    👏 12  💬 3      2h ago      │
└─────────────────────────────────┘
```

### Leaderboard Types
- **Friends only** - Intimate competition
- **Global** - For competitive users
- **Challenge-specific** - Time-limited events
- **Segment** - Location-based (Strava style)

### Challenge System
```dart
class Challenge {
  String id;
  String title;
  ChallengeType type; // distance, volume, frequency, duration
  DateTime startDate;
  DateTime endDate;
  List<Participant> participants;
  PrizeInfo? prizes;

  double getUserProgress(String odIsU) {
    // Calculate progress toward goal
  }
}
```

---

## 6. Health & Device Integration

### Apple HealthKit / Google Health Connect
```dart
// Essential metrics to sync
final types = [
  HealthDataType.WORKOUT,
  HealthDataType.HEART_RATE,
  HealthDataType.STEPS,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.SLEEP_IN_BED,
  HealthDataType.WEIGHT,
];
```

### Wearable Integration
- **Heart rate zones** - Real-time intensity feedback
- **Calorie estimation** - More accurate with HR data
- **Auto-detection** - Start/stop workout automatically
- **Watch apps** - Standalone workout tracking

---

## 7. Notification Strategy

### Timing Framework
| Time | Notification Type |
|------|------------------|
| Morning (7-9am) | Motivation, workout reminder |
| Pre-workout | Scheduled session reminder |
| Post-workout | Celebration, stats summary |
| Evening (7-9pm) | Streak protection warning |
| Weekly | Progress summary, challenge updates |

### Message Tone
✅ **Positive**: "Ready to continue your streak?"
✅ **Encouraging**: "Your workout is waiting!"
❌ **Shaming**: "You haven't worked out in 3 days"
❌ **Negative**: "You're falling behind"

---

## 8. Nutrition Integration

### Core Features
- **Barcode scanning** - Quick food logging
- **Food database** - Comprehensive and searchable
- **Macro tracking** - Protein, carbs, fats
- **Water logging** - Visual progress (Water Minder style)
- **Meal photos** - Optional visual logging

### Calorie Calculation
```dart
double calculateTDEE(User user) {
  // Mifflin-St Jeor Equation
  double bmr;
  if (user.isMale) {
    bmr = 10 * user.weightKg + 6.25 * user.heightCm - 5 * user.age + 5;
  } else {
    bmr = 10 * user.weightKg + 6.25 * user.heightCm - 5 * user.age - 161;
  }
  return bmr * user.activityMultiplier;
}
```

---

## 9. Technical Architecture

### Recommended Stack
```yaml
State Management: flutter_bloc or riverpod
Local Database: isar or drift
Cloud Backend: Firebase / Supabase
Health Data: health package
Charts: fl_chart
Notifications: flutter_local_notifications
Background: workmanager
```

### Offline-First Architecture
1. All data stored locally first
2. Background sync when connected
3. Conflict resolution strategy
4. Optimistic UI updates
5. Graceful degradation

### Performance Requirements
- **60fps** animations during workouts
- **<100ms** tap response time
- **<3s** app cold start
- **<1%** battery per hour of tracking

---

## 10. Accessibility Checklist

- [ ] Minimum 44x44pt touch targets
- [ ] 4.5:1 color contrast ratio
- [ ] VoiceOver/TalkBack support
- [ ] Reduce motion option
- [ ] Dynamic Type support
- [ ] Haptic feedback for key events
- [ ] Audio cues for visual information
- [ ] Caption support for video content

---

## Quick Reference: Top App Features

| App | Key Strength | Unique Feature |
|-----|--------------|----------------|
| **Strava** | Social/community | Segment leaderboards, GPS art |
| **Nike Training Club** | Workout quality | Expert-designed programs, free |
| **MyFitnessPal** | Nutrition tracking | Massive food database |
| **Peloton** | Live classes | Instructor-led experience |
| **Freeletics** | AI coaching | Adaptive difficulty |
| **Apple Fitness+** | Integration | Seamless Apple ecosystem |
| **Zombies, Run!** | Narrative | Story-driven workouts |

---

## Implementation Checklist

### MVP Features
- [ ] User onboarding (60-second rule)
- [ ] Workout logging
- [ ] Basic progress tracking
- [ ] Streak system
- [ ] Simple achievements

### Growth Features
- [ ] Social feed
- [ ] Leaderboards
- [ ] Challenges
- [ ] Health integrations
- [ ] Nutrition tracking

### Retention Features
- [ ] Push notifications
- [ ] Streak protection
- [ ] Personalized recommendations
- [ ] Community features
- [ ] Premium content
