# 🐾 PawPal - Your Furry Friends Finder

<p align="center">
  <img src="assets/images/petLogo.png" width="150" alt="PawPal Logo">
</p>

<p align="center">
  <b>Connects pet lovers, adopters, and donors in one seamless platform.</b>
</p>

---

## 📖 Table of Contents
- [🐾 PawPal - Your Furry Friends Finder](#-pawpal---your-furry-friends-finder)
  - [📖 Table of Contents](#-table-of-contents)
  - [📝 About the Project](#-about-the-project)
  - [✨ Key Features](#-key-features)
    - [👤 User System](#-user-system)
    - [🐶 Pet Management](#-pet-management)
    - [💰 Hybrid Donation System](#-hybrid-donation-system)
    - [🎨 UI/UX Design](#-uiux-design)
  - [🛠 Tech Stack](#-tech-stack)
  - [📱 Screenshots](#-screenshots)
  - [🚀 Installation Guide](#-installation-guide)
    - [Prerequisites](#prerequisites)
    - [Backend Setup](#backend-setup)
    - [Frontend Setup](#frontend-setup)
  - [📂 Project Structure](#-project-structure)

---

## 📝 About the Project

**PawPal** is a hybrid mobile application designed to facilitate pet adoption, rescue missions, and donations. It solves the problem of disconnected pet communities by providing a centralized platform where users can:
1.  **Adopt** pets looking for a home.
2.  **Donate** money (via Billplz) or supplies (Food/Medical) to help pets.
3.  **Rescue** pets in emergency situations.

The app features a robust backend for managing transactions and a user-friendly frontend built with Flutter.

---

## ✨ Key Features

### 👤 User System
* **Secure Authentication:** User Registration and Login with encrypted passwords.
* **Auto-Login:** Splash screen with automated token/session checks.
* **Profile Management:** Update personal details and profile pictures (with cache-busting real-time updates).

### 🐶 Pet Management
* **Add New Pets:** Users can upload pet details including multiple images.
* **My Pets:** Manage your own listings (Delete pets).
* **Interactive Details:** View pet images in a swipeable gallery (`PageView`).
* **Owner Validation:** Users cannot adopt or donate to their own pets (Smart Logic).

### 💰 Hybrid Donation System
* **Monetary Donations:** Integrated with **Billplz Payment Gateway** for secure transactions.
* **Item Donations:** Specialized tracking for "Food" and "Medical" donations (bypasses payment gateway for direct logging).
* **Receipt Generation:** Auto-generated digital receipts for all successful transactions.

### 🎨 UI/UX Design
* **Animated Splash Screen:** Smooth fade-in animations on startup.
* **Custom Navigation:** Side drawer with dynamic user data.
* **Responsive Layouts:** Optimized for different screen sizes.

---

## 🛠 Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **Backend** | PHP (Native) | REST API for data handling |
| **Database** | MySQL (MariaDB) | Relational database for Users, Pets, Donations |
| **Payment** | Billplz API | Sandbox environment for payment processing |
| **Server** | XAMPP / Apache | Local hosting for development |

---

## 📱 Screenshots

| Home Page | Pet Details | Donation Page | Payment Success |
|:---:|:---:|:---:|:---:|
| <img src="assets/images/home.png" width="200"> | <img src="assets/images/details.png" width="200"> | <img src="assets/images/donate.png" width="200"> | <img src="assets/images/receipt.png" width="200"> |


---

## 🚀 Installation Guide

### Prerequisites
* Flutter SDK installed.
* XAMPP or WAMP server running.
* Physical Device or Emulator.

### Backend Setup
1.  Move the `pawpal` folder to your server's root directory (e.g., `C:\xampp\htdocs\pawpal`).
2.  Open `phpMyAdmin` and create a database named `pawpal_db`.
3.  Import the provided `pawpal_db.sql` file.
4.  Update `dbconnect.php` if your database password differs from default.

### Frontend Setup
1.  Open the project in **VS Code**.
2.  Run `flutter pub get` to install dependencies.
3.  Open `lib/myconfig.dart` and update the `baseUrl` with your machine's IP address:
    ```dart
    // Example
    static const String baseUrl = "[http://192.168.](http://192.168.)x.x"; 
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
lib/
├── main.dart            # Entry point
├── myconfig.dart        # Server configuration
├── models/              # Data models (User, Pet)
├── views/
│   ├── loginPage.dart   # Login screen
│   ├── registerPage.dart# Registration screen
│   ├── main_page.dart   # Home dashboard
│   ├── PetDetailsPage.dart # Pet info & actions
│   ├── DonationPage.dart # Donation form logic
│   ├── payment_page.dart # Billplz WebView
│   └── ...