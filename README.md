# Masar | مسار

<p align="center">
  <img src="assets/images/Masar.png" alt="Masar app logo" width="120" />
</p>

**Masar** is an Arabic, offline-first daily organizer built with Flutter. It brings tasks, habits, and study materials together in one place.

## Features

### Daily Tasks
- Create, edit, complete, and delete tasks.
- Set a date and time for each task.
- Receive local notifications for scheduled tasks.
- Filter tasks by **All**, **Today**, **Overdue**, and **Upcoming**.
- View today's progress and see overdue tasks on the home screen.
- Completed tasks from previous days are automatically cleaned up when the app starts.

### Habits
- Create habits with a name and description.
- Mark habits as completed each day.
- Track consecutive-day streaks and reset daily completion status.

### Study Organizer
- Create and manage subjects, with a description and optional teacher name.
- Add lessons to each subject and edit or delete them.
- Mark lessons as completed and view completed vs. remaining lesson progress.
- Add multiple notes to each lesson.
- Give each note a title, description, content, and color; edit or delete notes.

### Personalization & Extras
- Set your name during onboarding and change it later.
- Arabic right-to-left interface with a daily overview.
- Read a motivational quote in Settings and share it using your device's share sheet.
- View app information and contact the developer from the About screen.
- Clear all app data from Settings.

### Local Storage
- Works offline; no account or backend server is required.
- Tasks, habits, subjects, lessons, and notes are stored locally on the device.

## Download

Visit the **[Masar Download Website](https://sifeemad123.github.io/Masar/)** to download the Android APK.

> The published download is an Android APK. An iOS build is not currently offered on the download website.

## Built With

- **Flutter & Dart** — mobile UI and application logic
- **Provider** — state management
- **Hive** — local storage for tasks, habits, subjects, lessons, and notes
- **Shared Preferences** — saved user name
- **Flutter Local Notifications** — task reminders
- **Share Plus** — sharing motivational quotes
- **Intl** — localized date and time formatting

## Run Locally

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Clone the repository:
   ```bash
   git clone https://github.com/sifeemad123/Masar.git
   cd Masar
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Repository

[View Masar on GitHub](https://github.com/sifeemad123/Masar)

---

Made by **Saif Emad**.
