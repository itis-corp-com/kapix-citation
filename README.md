# Kapix Citation

A Flutter mobile application for streamlined traffic citation processing using finite state machine (FSM) workflow and cloud-based document processing.

## Architecture

**Hybrid FSM + Cloud AI Approach**
- **Client**: Lightweight FSM workflow (50MB) for optimal mobile performance
- **Server**: Cloud-based AI document classification and processing
- **Benefits**: Fast user experience with intelligent error correction

## Key Features

- **Progress Tracking**: Visual progress indicator with 7-step workflow
- **Document Capture**: Camera integration for license, registration, insurance documents
- **Cloud Storage**: AWS S3 integration for secure document storage
- **Real-time Updates**: Firebase Realtime Database for status tracking
- **Error Correction**: Server-side document classification corrects user mistakes

## Workflow States

```
start → licenseFront → registration → insurance → contact → review → done
```

## Tech Stack

- **Frontend**: Flutter/Dart
- **State Management**: Provider pattern
- **Cloud Storage**: AWS S3 (us-west-2, itis.kapix-citation bucket)
- **Database**: Firebase Realtime Database
- **Authentication**: Firebase Auth

## Configuration

### AWS S3
- Region: `us-west-2`
- Bucket: `itis.kapix-citation`

### Firebase
- Realtime Database: `https://itis-kapix-citation.firebaseio.com`
- Document structure: `users/{userId}/citations/{citationId}/documents/{auto_generated_id}`

## Getting Started

### Prerequisites
- Flutter SDK
- AWS credentials configured
- Firebase project setup

### Installation

1. Clone the repository
```bash
git clone https://github.com/itis-corp-com/kapix-citation.git
cd kapix-citation
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure credentials in `lib/config/app_config.dart`

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── config/          # App configuration and credentials
├── models/          # Data models and FSM states
├── providers/       # State management (Progress, Upload)
├── services/        # AWS S3 and Firebase services
├── widgets/         # Reusable UI components
└── screens/         # App screens and navigation
```

## Development Notes

- Mock flow advances through citation steps on any photo capture for testing
- Firebase auto-generated keys simplify document management
- Server-side processing allows correction of user document type mistakes
- Designed for muscle memory development from prompts to automatic workflow

## License

Proprietary - ITIS Corporation
