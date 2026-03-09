# TECHNI Customer App

## Overview
TECHNI Customer App is a **Flutter-based mobile onboarding application** designed to allow users to quickly register, verify their phone number using OTP, and create a personal profile before accessing services on the TECHNI platform.

The goal of the application is to provide a **smooth, secure, and user-friendly onboarding experience** for customers.

The app focuses on:

- Clean and modern UI design 
- Smooth onboarding flow 
- Strong form validation 
- Modular and scalable Flutter architecture 

---

# Application Flow

The onboarding process follows a simple guided flow:

**Welcome Screen → Sign In → OTP Verification → Success Screen → Create Profile**

This ensures every user account is **verified and complete** before accessing platform services.

---

# Features

## 1. Welcome Screen
- Displays TECHNI branding
- Clean minimal UI
- Entry point to the application
- Navigation to Sign In screen

## 2. Sign In Screen
Users authenticate using their **phone number**.

Features:
- 🇱🇰 Sri Lankan phone number validation
- Numeric input only
- Real-time validation feedback
- Prevents invalid inputs

Example format:

```
+94XXXXXXXXX
```

---

## 3. OTP Verification Screen
Used to verify the user's phone number using a **6-digit OTP code**.

Features:

- 6 separate OTP input boxes
- Automatic focus movement between inputs
- Accepts **numbers only**
- Verify button activates only when all digits are filled

⚠️ Note:

Backend OTP verification will be integrated later by another team member.

---

## 4. Success Screen
Displayed after successful phone verification.

Features:

- Success confirmation message
- Illustration
- TECHNI logo
- Close button to continue

Navigation uses **pushReplacement** so users cannot go back to the verification screen.

---

## 5. Create Profile Screen
Allows users to complete their personal information.

Users provide:

- Full Name
- Birth Date
- Email Address
- Address / Location
- Profile Picture

### Profile Photo Upload
Users can upload a profile picture using the **image_picker package**.

The gallery opens when the camera icon is tapped.

### Birth Date Selection

- Calendar date picker
- Date range: **1950 → Present**
- Automatically fills the input field

### Email Validation
Ensures the email contains **@** and follows a basic valid structure.

### Form Validation
The **Save Profile button** becomes active only when required fields are valid.

Required fields:

- Full name
- Birth date
- Valid email

---

# Technologies Used

## Framework

**Flutter** – Used to build cross-platform mobile applications.

## Programming Language

**Dart** – Primary language used for Flutter development.

## Flutter Packages

| Package | Purpose |
|------|------|
| image_picker | Select profile picture from gallery |

---

# 📂 Project Structure

```
lib/
 ├── main.dart
 │
 ├── app/
 │   ├── routes.dart
 │   └── theme.dart
 │
 ├── core/
 │   └── assets.dart
 │
 ├── screens/
 │   ├── welcome_screen.dart
 │   ├── sign_in_screen.dart
 │   ├── verification_screen.dart
 │   ├── success_screen.dart
 │   └── create_profile_screen.dart
 │
 └── widgets/
     ├── app_header.dart
     ├── input_field.dart
     ├── primary_button.dart
     └── success_card.dart
```

---

# Folder Explanation

### main.dart
Entry point of the Flutter application.

Responsibilities:
- Launch the app
- Initialize routes
- Apply global theme

---

### app/
Contains global application configuration.

**routes.dart**
- Defines navigation routes for all screens

**theme.dart**
- Global colors
- Typography
- Button styles

---

### core/
Contains shared resources used across the app.

**assets.dart**
- Centralized asset paths
- Images
- Icons

---

### screens/
Contains full UI pages of the application.

Each file represents one screen in the onboarding flow.

---

### widgets/
Contains reusable UI components used across multiple screens.

Examples:

- Custom input fields
- Primary buttons
- Header components
- Success cards

This improves **code reusability and maintainability**.

---

# ⚙️ How to Run the Project

Follow these steps to run the project locally.

## 1. Install Flutter

Download Flutter from:

https://flutter.dev/docs/get-started/install

Verify installation:

```
flutter doctor
```

---

## 2. Clone the Repository

```
git clone https://github.com/yourusername/techni-customer-app.git
```

Navigate to the project folder:

```
cd techni-customer-app
```

---

## 3. Install Dependencies

Run:

```
flutter pub get
```

---

## 4. Run the Application

Start an emulator or connect a physical device.

Then run:

```
flutter run
```

The application will launch on your device.

---

# Current Development Status

Completed

- Onboarding UI screens
- Phone number validation
- OTP input interface
- Image upload functionality
- Form validation
- Screen navigation
- Reusable widgets

In Progress / Planned

- Backend OTP verification
- API integration
- Location services
- User profile database

---

# Skills Demonstrated

This project demonstrates several important development skills:

- Flutter mobile development 
- UI/UX design principles 
- Form validation & input control 
- Navigation and routing 
- Image handling 
- Modular project architecture 

---

# Future Improvements

Planned improvements include:

- Firebase / backend authentication
- Real OTP verification
- Location API integration
- Profile editing
- Dark mode support

---

# Author

**TECHNI DEVELOPMENT TEAM**

Flutter Developer | Computer Science Students

Passionate about building **clean, scalable, and user-friendly applications.**

---

⭐ If you found this project helpful, consider giving it a **star on GitHub!**

