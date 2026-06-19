# Migration Guide: Firebase Storage to Cloudinary (Free-Tier Friendly Architecture)

This document provides a detailed blueprint and reference for migrating the **Worth** wealth operating system from a Firebase Storage-based architecture to a **100% free-tier friendly architecture** using **Cloudinary** for binary assets (images, profile photos, attachments, backups) and **Hive** for offline-first local caching.

---

## 1. Overview of the New Architecture

To remain indefinitely on the free tier, we have eliminated the dependency on **Firebase Cloud Storage**.

*   **Authentication**: Remains on **Firebase Authentication** (Email/Password, Google Sign-In).
*   **Structured Database**: **Cloud Firestore** stores structured document data.
*   **Binary Storage**: **Cloudinary** handles profile photos, receipts/document attachments, and exported encrypted backups.
*   **Offline-First Cache**: **Hive** caches all data locally. UI operations write immediately to Drift (for complex relational queries/Views/lot math) and Hive boxes (for outbox synchronization to Firestore).
*   **Sync Manager**: Detects connectivity, retries failed sync requests, and resolves sync conflicts using `updatedAt` timestamps (Last-Write-Wins).

```
                 +--------------------------+
                 |    Flutter UI / Riverpod |
                 +------------+-------------+
                              |
                              v
                 +------------+-------------+
                 |     Repository Layer     |
                 +------+-------------+-----+
                        |             |
       (Local Read/Queries)           (Dual-Write Cache & Queue)
                        v             v
                 +------+-----+ +-----+-----+
                 | Drift DB   | | Hive DB   |
                 +------------+ +-----+-----+
                                      |
                                      v
                               +------+-----+
                               | Sync Engine|
                               +---+----+---+
                                   |    |
           (Pushes documents when) |    | (Uploads files to Cloudinary)
           (network is available ) |    |
                                   v    v
                              +----+--+ +----+------+
                              |Firestore| |Cloudinary|
                              +-------+ +-----------+
```

---

## 2. Cloudinary Setup & Security

To avoid exposing your Cloudinary API Secret inside the Flutter client app, we implement **Signed Uploads** or **Restricted Unsigned Presets**.

### Option A: Signed Uploads (Recommended)
1. Set up a lightweight serverless function (e.g., Firebase Cloud Functions or Vercel).
2. The Flutter client requests a signature by sending parameters like `timestamp` and `public_id`.
3. The serverless function generates a SHA-1 signature using your `API_SECRET` and returns it to the client.
4. The client uploads the file directly to Cloudinary using the signature.

### Option B: Restricted Unsigned Presets
1. In your Cloudinary console, go to **Settings > Upload**.
2. Enable an **Unsigned Upload Preset**.
3. Apply restriction rules:
   * Limit file sizes (e.g., max 10MB for backups, 2MB for profile photos).
   * Restrict allowed file formats (e.g., only `.json`, `.png`, `.jpg`).
   * Turn on incoming metadata validation.

---

## 3. SQLite (Drift) to Firestore Collection Mapping

The system operates a dual-write mechanism. When you perform a write, it goes to the Drift SQLite database (local) and is simultaneously pushed to the corresponding Hive Box which queues it for Firestore.

The mapping of local SQLite tables to Firestore collections is defined as follows:

| Local Drift Table | Target Firestore Collection | Hive Model | Notes / Key Attributes |
| :--- | :--- | :--- | :--- |
| `users` | `users/{userId}` | `HiveUser` | `uid`, `email`, `displayName`, `photoUrl` |
| `portfolios` | `users/{userId}/portfolios` | `HivePortfolio` | `id`, `name`, `updatedAt` |
| `accounts` (non-credit) | `users/{userId}/assets` | `HiveAsset` | Mapped as Asset with `type: 'cash'` / bank |
| `accounts` (credit) | `users/{userId}/liabilities` | `HiveLiability` | Mapped as Liability with `type: 'credit_card'` |
| `people` | `users/{userId}/receivables` | `HiveReceivable` | Mapped as Receivable |
| `expected_incomes` | `users/{userId}/receivables` | `HiveReceivable` | Mapped as Receivable with status flags |
| `investments` | `users/{userId}/assets` | `HiveAsset` | Mapped as Asset with `type: 'investment'` |
| `transactions` | `users/{userId}/transactions` | `HiveTransaction` | Mapped with details; `attachmentUrl` uploaded to Cloudinary |
| `ipo_pools` | `users/{userId}/ipo_pools` | `HiveIpoPool` | Tracks IPO pools |
| `ipo_contributors` | `users/{userId}/ipo_contributors` | `HiveIpoContributor` | IPO contributors |
| `ipo_applications` | `users/{userId}/ipo_applications` | `HiveIpoApplication` | IPO application numbers and amounts |
| `ipo_settlements` | `users/{userId}/ipo_settlements` | `HiveIpoSettlement` | Track contributor refunds/payouts |
| `portfolio_histories` | `users/{userId}/portfolio_history` | `HivePortfolioHistory` | Historical actions log |
| `portfolio_snapshots` | `users/{userId}/monthly_snapshots` | `HiveMonthlySnapshot` | Snapshots of net worth over months |
| `settings` | `users/{userId}/settings` | `HiveSetting` | App preference keys and values |

---

## 4. Firestore Security Rules

Deploy the following security rules to your Cloud Firestore instance. These rules ensure that authenticated users can **only** read and write documents in their own user folder:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document and subcollections
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 5. Migration Execution Checklist

To clean up your local Flutter setup and remove the Firebase Storage dependency:

1. **Remove package**:
   Ensure `firebase_storage` is removed from `pubspec.yaml` (Completed).
2. **Clean Project**:
   Run the following commands in the terminal:
   ```bash
   puro flutter clean
   puro flutter pub get
   ```
3. **Run Code Generation**:
   Regenerate all model files to ensure adapters are synchronized:
   ```bash
   puro flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Configure Credentials**:
   Provide the Cloudinary parameters in `lib/core/services/cloudinary_service.dart` or via a `.env` file injected at runtime:
   * `cloudName`: Your Cloudinary Cloud Name
   * `apiKey`: Your Cloudinary API Key
   * `uploadPreset`: The upload preset name

Your Worth application is now completely migrated to a free-tier friendly, offline-first architecture!
