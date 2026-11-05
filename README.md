# HealthMate – Personal Health & Wellness Tracker

## Project Overview

HealthMate is a personal health and wellness tracking mobile application developed using Flutter and Dart.

The main purpose of this application is to help users record and monitor their daily health activities, including steps walked, calories burned, and water intake.

The application provides a simple and user-friendly interface for managing daily health records. Health information is stored locally on the device using SQLite.

This project was developed as part of a Mobile Application Development university assignment.

## Main Features

- User registration and login
- User profile management
- Daily health dashboard
- Add new health records
- View saved health records
- Edit and delete health records
- Filter health records by date
- Track daily steps, calories, and water intake
- Set and monitor daily health goals
- View weekly health progress using charts
- User logout functionality

## Technologies Used

- **Flutter** – Mobile application development framework
- **Dart** – Programming language
- **SQLite** – Local database for storing health records
- **Provider** – State management
- **SharedPreferences** – Local user account and session information
- **fl_chart** – Weekly health progress charts
- **crypto** – Password hashing

## Application Screens

The application contains the following main screens:

1. Login Screen
2. Registration Screen
3. Dashboard Screen
4. Add Health Record Screen
5. Health Records Screen
6. Weekly Progress Screen
7. User Profile Screen

## Health Record Information

Each health record contains:

- Record ID
- Date
- Steps walked
- Calories burned
- Water intake (mL)

The records are stored locally using SQLite and can be viewed, updated, or deleted.

## Project Development Stages

- **Stage 1:** Initial Flutter project setup
- **Stage 2:** User interface and navigation
- **Stage 3:** SQLite database and health record model
- **Stage 4:** Add, view, edit, and delete health records
- **Stage 5:** Provider state management and dashboard integration
- **Stage 6:** User registration, login, and logout
- **Stage 7:** Daily health goals and weekly progress charts
- **Stage 8:** User profile management
- **Stage 9:** Application testing and documentation

## How to Run the Project

1. Install Flutter SDK and Android Studio.
2. Clone the GitHub repository.
3. Open the project in VS Code or Android Studio.
4. Run the following commands:

```bash
flutter pub get
flutter run
```

An Android emulator or connected Android device is required.

## Testing

The application has been tested using an Android emulator.

The following functionalities have been manually tested:

- User registration and login
- Health record creation
- Viewing saved health records
- Editing and deleting records
- Filtering records by date
- Weekly health progress charts
- User profile and logout

Flutter static analysis and automated tests have also been run successfully.

## Project Status

Core application features have been implemented and tested.

Final documentation and Android APK preparation are in progress.

## Developer

Developed as a university Mobile Application Development project using Flutter and Dart.