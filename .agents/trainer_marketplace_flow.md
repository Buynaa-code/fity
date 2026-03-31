# Trainer Marketplace Feature - Flow & Architecture

## Folder Structure

```
lib/features/trainer_marketplace/
├── domain/
│   └── entities/
│       ├── trainer.dart              # Trainer entity + TimeSlot, Review classes
│       ├── booking.dart              # Booking entity + BookingStatus enum
│       └── trainer_subscription.dart # Subscription tiers + pricing
├── data/
│   ├── models/
│   │   ├── trainer_model.dart            # JSON serialization
│   │   ├── booking_model.dart            # JSON serialization
│   │   └── trainer_subscription_model.dart
│   └── repositories/
│       └── trainer_repository.dart   # Data layer (SharedPreferences)
└── presentation/
    ├── bloc/
    │   ├── trainer_list/             # List filtering, search, sort
    │   ├── trainer_detail/           # Single trainer view
    │   ├── booking/                  # Booking CRUD
    │   ├── review/                   # Review management
    │   └── trainer_registration/     # Multi-step registration
    ├── pages/
    │   ├── trainer_list_screen.dart
    │   ├── trainer_detail_screen.dart
    │   ├── booking_history_screen.dart
    │   ├── create_review_screen.dart
    │   └── trainer_registration_screen.dart
    └── widgets/
        ├── trainer_card.dart
        ├── rating_stars.dart
        ├── specialty_chip.dart
        ├── featured_trainer_card.dart
        ├── review_input_widget.dart
        ├── specialty_selector.dart
        ├── certification_input.dart
        ├── availability_picker.dart
        ├── photo_gallery_picker.dart
        └── subscription_plan_card.dart
```

## User Flows

### 1. Browse Trainers Flow
```
TrainerListScreen
    │
    ├─> Search by name/specialty
    ├─> Filter by specialty chips
    ├─> Sort (rating/price/experience)
    │
    └─> Tap trainer card
            │
            v
        TrainerDetailScreen
            │
            ├─> View info, certifications, reviews
            ├─> Select date (7 days)
            ├─> Select time slot
            │
            └─> Tap "Book"
                    │
                    v
                BookingBloc.CreateBooking
                    │
                    ├─> Validate slot availability
                    └─> Create booking → Success dialog
```

### 2. Booking Management Flow
```
BookingHistoryScreen
    │
    ├─> Tab: "Upcoming"
    │       ├─> View booking details
    │       └─> Cancel (if > 24hrs before)
    │
    └─> Tab: "Past"
            │
            └─> Completed booking without review
                    │
                    └─> "Leave Review" button
                            │
                            v
                        CreateReviewScreen
                            │
                            ├─> Rate (1-5 stars)
                            ├─> Comment
                            └─> Submit → Updates trainer rating
```

### 3. Trainer Registration Flow (5 Steps)
```
Step 1: Basic Info
    ├─> Name, Phone, Bio
    v
Step 2: Specialties
    ├─> Select specialties
    ├─> Add certifications
    ├─> Experience years
    v
Step 3: Price & Photos
    ├─> Hourly rate
    ├─> Photo URLs
    v
Step 4: Availability
    ├─> Select available time slots
    v
Step 5: Subscription
    ├─> Choose tier (Basic/Professional/Premium)
    ├─> Process payment (simulated)
    └─> Submit → Status: PENDING (needs admin approval)
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Screens   │  │   Widgets   │  │ BlocBuilder/    │ │
│  │             │  │             │  │ BlocListener    │ │
│  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘ │
└─────────┼────────────────┼──────────────────┼──────────┘
          │                │                  │
          v                v                  v
┌─────────────────────────────────────────────────────────┐
│                    BLoC Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Events    │─>│    BLoC     │─>│     States      │ │
│  │             │  │   (Logic)   │  │                 │ │
│  └─────────────┘  └──────┬──────┘  └─────────────────┘ │
└──────────────────────────┼─────────────────────────────┘
                           │
                           v
┌─────────────────────────────────────────────────────────┐
│                  Repository Layer                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │              TrainerRepository                    │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │  │
│  │  │ Trainers │  │ Bookings │  │ Subscriptions│   │  │
│  │  └──────────┘  └──────────┘  └──────────────┘   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           v
┌─────────────────────────────────────────────────────────┐
│                  Storage Layer                          │
│              SharedPreferences (Local)                  │
└─────────────────────────────────────────────────────────┘
```

## BLoC Summary

| BLoC | Events | States | Purpose |
|------|--------|--------|---------|
| TrainerListBloc | LoadTrainers, FilterBySpecialty, Search, Sort | Loading, Loaded, Error | List management |
| TrainerDetailBloc | LoadDetail, SelectTimeSlot, SelectDate | Loading, Loaded, Error | Single trainer view |
| BookingBloc | Load, Create, Cancel, Reschedule, CheckSlot | Loading, Loaded, Created, Cancelled, Error | Booking CRUD |
| ReviewBloc | LoadPending, LoadTrainer, Submit | Loading, PendingLoaded, TrainerLoaded, Submitted | Review management |
| TrainerRegistrationBloc | InitReg, UpdateInfo, NextStep, Submit, Pay | Multi-step form state | Registration workflow |

## Key Business Rules

### Booking Rules
- **Cancellation deadline:** 24 hours before booking
- **Slot validation:** No double-booking allowed
- **Status flow:** pending → confirmed → completed/cancelled

### Trainer Status
- **pending:** Awaiting admin approval
- **approved:** Active and visible
- **rejected:** Rejected with reason
- **suspended:** Temporarily disabled

### Subscription Tiers
| Tier | Price | Features |
|------|-------|----------|
| Basic | 50,000₮ | Profile listing, 10 bookings/month |
| Professional | 100,000₮ | Featured listing, unlimited bookings, analytics |
| Premium | 200,000₮ | All Professional + priority support, top placement |

## Screen Navigation

```
HomeScreen
    │
    ├─> "Trainers" → TrainerListScreen
    │                     │
    │                     ├─> TrainerDetailScreen
    │                     │         │
    │                     │         └─> Booking flow
    │                     │
    │                     ├─> "History" → BookingHistoryScreen
    │                     │                    │
    │                     │                    └─> CreateReviewScreen
    │                     │
    │                     └─> "Become Trainer" → TrainerRegistrationScreen
    │
    └─> FeaturedTrainersCarousel → TrainerDetailScreen
```

## Files by Layer

### Domain Layer (Entities)
- `trainer.dart` - Trainer, TimeSlot, Review, TrainerStatus enum
- `booking.dart` - Booking, BookingStatus enum
- `trainer_subscription.dart` - TrainerSubscription, SubscriptionTier, SubscriptionStatus

### Data Layer
- `trainer_model.dart` - fromJson/toJson for Trainer
- `booking_model.dart` - fromJson/toJson for Booking
- `trainer_subscription_model.dart` - fromJson/toJson for Subscription
- `trainer_repository.dart` - All data operations (600+ lines)

### Presentation Layer
- 5 BLoCs with events/states
- 5 Screens
- 10 Widgets

## Issues Found & Fixed

### 1. RenderFlex Overflow (featured_trainer_card.dart)
**Problem:** Card content exceeded 180px height constraint causing 4px overflow
**Fix:** Reduced image height (110→100), padding (10→8), spacing (3,3,6→2,2,4)

### 2. Duplicate Widget (_FeaturedTrainerCard)
**Problem:** Two versions existed - in trainer_list_screen.dart and widgets/featured_trainer_card.dart
**Fix:** Used `Expanded` wrapper with `Spacer` to prevent overflow in trainer_list_screen.dart version

### 3. Code Structure Observations
- Repository is large (600+ lines) - consider splitting into smaller repositories
- Mock data is hardcoded - should use backend API
- Payment is simulated - needs real payment integration
- Trainer login is email-only - needs proper authentication

## Status

All imports verified. No circular dependencies. Clean Architecture properly implemented.
