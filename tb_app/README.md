# TB APP 

A new Flutter project.

## Overview

TB App is a chat application with authentication, real-time messaging via WebSocket, conversation management (favorites, pinned, unread), user search, and a profile module. Firebase is used for initialization and FCM device tokens; backend communication is via REST APIs and WebSockets defined in `lib/constants/api_constants.dart`.

## Tech Stack

- Flutter (Material 3)
- Firebase Core and FCM (for notifications)
- HTTP (http)
- Shared Preferences (shared_preferences)
- WebSocket (web_socket_channel)
- JWT Validation (jwt_decoder)

## App Entry

- `lib/main.dart`
  - Initializes Flutter bindings and `Firebase.initializeApp()`.
  - Launches `Splashscreen` as the home widget with MaterialApp and Material 3 theme.

## App Flow

1. Splash → checks JWT in SharedPreferences; if valid and not expired, registers device (FCM) and navigates to Home. Otherwise navigates to Login.
2. Auth → Login/Sign-up flows obtain JWT, register device, then navigate to Home or Update Profile.
3. Home → Lists conversations with filters (All/Unread/Groups/Favorites), search, pin/unpin, and navigate to Chat.
4. Chat → Loads history, connects to WebSocket for real-time messages, supports favorites and clear chat.
5. Profile → View and edit profile, see and manage favorites.

---

## Screens and Functionality

### Splash
- File: `lib/screens/splash/splash_screen.dart`
- Purpose: Animated splash and authentication gate.
- Key behaviors:
  - Reads `jwt_token` and `user_email` from SharedPreferences.
  - Uses `jwt_decoder` to verify token expiry.
  - If valid, requests FCM permission, fetches FCM token, calls `ApiConstants.registerDevice`, then navigates to `HomeScreenPage`.
  - If invalid/absent, clears stored creds and navigates to `LoginPage`.

### Authentication

- File: `lib/screens/auth/login_page.dart` (LoginPage)
  - Inputs: email, password.
  - Flow:
    1) POST `ApiConstants.signIn`.
    2) On success, POST `ApiConstants.generateJwt` to fetch `jwt_token` and save `user_email` and `jwt_token` in SharedPreferences.
    3) Requests FCM permission and POST `ApiConstants.registerDevice` with email + FCM token.
    4) Navigate to `HomeScreenPage`.
  - Error handling: shows dialog on empty fields or HTTP errors.

- File: `lib/screens/auth/signup_page.dart` (SignUpPage)
  - Inputs: email, create/confirm password.
  - Flow:
    1) POST `ApiConstants.signUp`.
    2) POST `ApiConstants.generateJwt` and save credentials (like Login).
    3) Registers device with FCM via `ApiConstants.registerDevice` (Authorization header is included if JWT present).
    4) Navigate to `UpdateProfilePage` to complete profile.
  - Validations: non-empty fields, password match.

- File: `lib/screens/auth/reset_password_page.dart` (Resetpasswordpage)
  - Input: email.
  - Flow: POST `ApiConstants.forgotPassword` to request OTP, then on success navigates to `OTPValidationPage` with email.

- File: `lib/screens/auth/otp_validation_page.dart` (OTPValidationPage)
  - Inputs: OTP (for the email passed from Reset Password).
  - Flow: POST `ApiConstants.otpValidate`. On success, navigates to `Createnewpasspage`.

- File: `lib/screens/auth/create_new_password_page.dart` (Createnewpasspage)
  - Inputs: new password, confirm password.
  - Flow: POST `ApiConstants.resetPassword` with email + new password. On success, shows success dialog and pops back to auth entry.

Barrel file for auth imports: `lib/screens/auth/auth.dart`.

### Home / Conversations

- File: `lib/screens/home/home_screen_page.dart` (HomeScreenPage)
  - Inputs: `emailText` (required), optional `profileImageUrl`.
  - Loads on init (via a loading dialog):
    - Conversations: POST `ApiConstants.conversations` with email.
    - Favorites: POST `ApiConstants.listFavorites`.
    - Pinned chats: POST `ApiConstants.listPinned`.
  - Maintains and displays:
    - Conversation list with last message preview and unread badges.
    - Filters via ToggleButtons: All, Unread, Groups, Favorites.
    - Search by conversation name.
    - Pinned and favorites indicators in list tiles.
  - Actions:
    - Long-press a conversation to Pin/Unpin, or mark as read (local state update).
    - Tap opens `ChatPage` with conversation details.
    - FAB opens `AddUsersPage` to start new Private/Group conversation via selection dialog.
    - Logout menu item: shows confirm dialog, unregisters device (`ApiConstants.unregisterDevice`), clears JWT and email from SharedPreferences, deletes FCM token, and navigates to Login.

### Chat

- File: `lib/screens/chat/chat_page.dart` (ChatPage)
  - Props: `conversationId`, `conversationName`, `conversationType` (private/group), `emailText`.
  - On init:
    - Loads messages: POST `ApiConstants.getMessages`.
    - Marks messages read: POST `ApiConstants.messageRead`.
    - Connects WebSocket: `ApiConstants.sendMessageWs(conversationId, email)`.
    - If group, loads participants: POST `ApiConstants.getGroupParticipants`.
  - Real-time:
    - Sends messages over WS `{ "body": text }`.
    - Displays tick states: sent/delivered/read based on server events.
    - Receives messages and appends; scrolls to bottom.
  - AppBar actions:
    - Toggle Favorite: POST `ApiConstants.addFavorite` / `removeFavorite`.
    - Clear Chat: POST `ApiConstants.clearChat`, then reloads messages.
  - Title tap:
    - Group: bottom sheet listing participants.
    - Private: bottom sheet showing recipient info (from messages or conversationName fallback).

- File: `lib/screens/chat/add_users_page.dart` (AddUsersPage)
  - Props: `emailText`, `mode` ('Private' default or 'Group').
  - Loads users:
    - Private: POST `ApiConstants.getDirectUsers`.
    - Group: POST `ApiConstants.getAllUsers`.
  - Features:
    - Search by name/email.
    - Select one or multiple participants (require ≥2 for group).
    - Optional group name prompt.
    - Start conversation: POST `ApiConstants.conversationStart` with creator email, participants, conversation_name, conversation_type.

Barrel file for chat imports: `lib/screens/chat/chat.dart`.

### Profile

- File: `lib/screens/profile/profile_page.dart` (ProfilePage)
  - Props: `emailText`.
  - Loads:
    - Profile: POST `ApiConstants.fetchProfile`.
    - Favorites: POST `ApiConstants.listFavorites`.
  - UI:
    - Profile card with initials avatar, name, email, join date.
    - Favorites list with swipe-to-remove (POST `ApiConstants.removeFavorite`).
    - Edit icon opens `UpdateProfilePage`; after returning, refreshes data.

- File: `lib/screens/profile/update_profile_page.dart` (UpdateProfilePage)
  - Props: `emailText`, `fromProfile` (default false).
  - Inputs: first name, last name, optional local image path (picked via image_picker). If no URL provided, generates a `ui-avatars` URL by name.
  - Flow: POST `ApiConstants.profile` to update. On success:
    - If launched from Profile, pops back once.
    - If launched post sign-up, navigates to Home with optional `profileImageUrl`.

### Utilities

- File: `lib/utils/alert.dart`
  - `showCustomPopup(...)`: Themed alert dialog with title, content, primary button, optional handler.

- File: `lib/utils/loading.dart`
  - `showLoadingPopup(...)`: Shows a modal progress indicator while running an async function (used throughout flows).

- File: `lib/utils/selection_dialog.dart`
  - `showSelectionDialog(...)`: Modal to choose chat mode (Private/Group) before opening Add Users.

Barrel file for utils (if present): `lib/utils/utils.dart`.

### Constants

- File: `lib/constants/api_constants.dart`
  - Base URL: `ApiConstants.baseUrl`.
  - REST endpoints for auth, user, conversations, favorites, pinned, participants.
  - WebSocket URL builder: `sendMessageWs(conversationId, email)`.

---

## Development Notes

- Replace `ApiConstants.baseUrl` with your backend URL. For local dev behind HTTPS, WebSocket URL is derived by substituting https with ws.
- Required services:
  - Firebase project set up for firebase_core and firebase_messaging.
  - Backend implementing listed REST/WS endpoints.
- Android/iOS setup for FCM must be completed per Firebase docs.

## Quick Start

1) Configure `ApiConstants.baseUrl`.
2) Configure Firebase (Android/iOS) and add app files (google-services.json / GoogleService-Info.plist).
3) `flutter pub get`
4) Run: `flutter run`

## Navigation Summary

- Splash → Login | Home
- Login → Home
- SignUp → UpdateProfile → Home
- ResetPassword → OTPValidation → CreateNewPassword → back to Auth
- Home → Chat | AddUsers | Profile | Logout
- Profile → UpdateProfile

---


<video controls width="600">
  <source src="TB.mp4" type="video/mp4">
<video controls width="600">
  <source src="TB2.mp4" type="video/mp4">
</video>