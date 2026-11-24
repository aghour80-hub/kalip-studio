# KALIP studio — Luxury Fashion E-Commerce Mobile Application (Cambodia)

> **Timeless Elegance • Modern Luxury • BKK1 Flagship Atelier, Phnom Penh**

A production-grade cross-platform fashion e-commerce mobile application built for the Cambodian luxury fashion market, supporting physical inventory owned by the store, bilingual English/Khmer localization, dual-currency pricing (USD / KHR), Bakong KHQR national payment integration, Cash on Delivery with local cash rounding customs, an executive administration dashboard, and an AI-powered fashion concierge integrated with n8n workflow automations.

---

## 🏛️ 1. Architecture & Technology Stack

The application follows strict **Clean Architecture** patterns and modular separation of concerns:

- **Mobile Framework**: Flutter 3.50+ / Dart 3.14+
- **Design System**: Custom Material 3 luxury aesthetic (Obsidian Black, Luxury Beige, Canvas Linen)
- **State Management**: Flutter Riverpod (`StateNotifierProvider`, `Provider`, `FutureProvider`)
- **Declarative Navigation**: GoRouter with `StatefulShellRoute.indexedStack` (persistent bottom navigation) and role-based route guards
- **Backend & Database**: Supabase (PostgreSQL 15+, Supabase Authentication, Storage, Row Level Security)
- **National Payments**: EMVCo-compliant Bakong KHQR QR generator with CRC-16/CCITT-FALSE checksums and Bakong deep linking
- **Cash Payments**: Cash on Delivery (COD) dual-currency calculations with 100-Riel customary rounding
- **Logistics & Delivery**: Phnom Penh same-day express moto rider and provincial Virak Buntham (VET Express Cambodia)
- **AI Concierge**: Grounded AI assistant answering product stock and order status inquiries via secure backend proxy
- **Automations**: n8n workflow automations via signed webhooks for Telegram store notifications and dispatch tickets

---

## 📂 2. Project Directory Structure

```text
lib/
├── main.dart                               # App entrypoint, dotenv & Supabase initialization
├── core/
│   ├── config/                             # Supabase & environment configurations (.env)
│   │   └── supabase_config.dart
│   ├── constants/                          # Global constants, business thresholds, storage keys
│   │   └── app_constants.dart
│   ├── currency/                           # Dual currency engine (USD & KHR at 1 USD = 4,100 KHR)
│   │   ├── currency_formatter.dart
│   │   └── currency_provider.dart
│   ├── delivery/                           # Cambodian courier logistics & SLA routing engine
│   │   └── delivery_service.dart
│   ├── localization/                       # Khmer (km) and English (en) dictionary engine
│   │   ├── app_localizations.dart
│   │   └── language_provider.dart
│   ├── payment/                            # Bakong KHQR generator & Cash on Delivery service
│   │   ├── khqr_service.dart
│   │   └── cod_service.dart
│   ├── router/                             # GoRouter navigation & Role-Based Route Guards
│   │   └── app_router.dart
│   └── theme/                              # Luxury Minimalist Design System
│       ├── app_colors.dart                 # Obsidian Black, Luxury Beige, Linen White
│       ├── app_typography.dart             # Cormorant Garamond Serif + Kantumruy Pro Khmer
│       └── app_theme.dart                  # Material 3 theme data
├── data/
│   ├── mock/                               # Realistic Cambodian luxury fashion catalog
│   │   └── sample_data.dart
│   ├── models/                             # Strongly-typed data models with JSON serialization
│   │   ├── cart_item_model.dart
│   │   ├── category_model.dart
│   │   ├── chat_message_model.dart
│   │   ├── coupon_model.dart
│   │   ├── order_model.dart
│   │   ├── product_model.dart
│   │   └── user_model.dart
│   ├── repositories/                       # Supabase repositories with resilient offline fallback
│   │   ├── cart_repository.dart
│   │   ├── category_repository.dart
│   │   ├── order_repository.dart
│   │   └── product_repository.dart
│   └── services/                           # External services & APIs
│       ├── ai_concierge_service.dart       # Grounded AI fashion styling assistant
│       ├── n8n_webhook_service.dart        # Event dispatcher for n8n automations
│       ├── payment_service.dart            # Server-side payment status verifier
│       └── supabase_auth_service.dart      # Email/Password authentication & sessions
└── presentation/
    ├── providers/                          # Riverpod state notifiers & providers
    │   ├── admin_provider.dart             # GMV analytics & catalog inventory state
    │   ├── ai_chat_provider.dart           # AI conversational state
    │   ├── auth_provider.dart              # Authentication & role management
    │   ├── cart_provider.dart              # Cart items, stock gating, coupon engine
    │   ├── orders_provider.dart            # Order creation & pipeline transitions
    │   ├── products_provider.dart          # Filtered catalog, search, and sorting
    │   └── wishlist_provider.dart          # Wishlist persistence & cart transfer
    ├── widgets/                            # Reusable luxury UI components
    │   ├── app_bar_header.dart             # Bilingual & currency header
    │   ├── khqr_payment_sheet.dart         # Interactive Bakong KHQR payment modal
    │   ├── luxury_image.dart               # Shimmer cached network images
    │   ├── product_card.dart               # Editorial luxury product card
    │   └── responsive_layout.dart          # Responsive column calculations
    └── screens/
        ├── admin/                          # Executive Administration Suite
        │   ├── admin_dashboard_screen.dart # KPI cards, GMV (USD/KHR), inventory alerts
        │   ├── admin_orders_screen.dart    # Fulfillment pipeline (Pending -> Delivered)
        │   ├── admin_payments_screen.dart  # KHQR slip audit & COD payment clearance
        │   └── admin_products_screen.dart  # Product catalog & BKK1 atelier restock modal
        ├── ai_chat/
        │   └── ai_chat_screen.dart         # Floating AI Fashion Concierge dialog
        ├── auth/
        │   ├── forgot_password_screen.dart # Password recovery
        │   ├── login_screen.dart           # Email/password sign-in & guest mode
        │   └── register_screen.dart        # Cambodian member registration (+855)
        ├── cart/
        │   └── cart_screen.dart            # Bag, free delivery progress, promo codes
        ├── categories/
        │   └── categories_screen.dart      # Tabbed collections (Women, Men, Tailoring)
        ├── checkout/
        │   ├── checkout_screen.dart        # Cambodian province/district dropdowns, KHQR/COD
        │   └── order_success_screen.dart   # Order confirmation & delivery estimate
        ├── home/
        │   └── home_screen.dart            # Hero PageView, new arrivals, floating AI button
        ├── main_shell_screen.dart          # 5-Tab Persistent bottom navigation
        ├── orders/
        │   ├── order_details_screen.dart   # 5-stage timeline & courier tracking
        │   └── orders_screen.dart          # Order history list
        ├── product/
        │   └── product_details_screen.dart # Swatches, sizes, size guide, stock check
        ├── profile/
        │   └── profile_screen.dart         # VIP profile, admin launcher, preferences
        ├── search/
        │   └── search_screen.dart          # Search & sorting filter sheet
        └── wishlist/
            └── wishlist_screen.dart        # Wishlist grid
```

---

## 🎨 3. Design System & Cambodian Localization

### Palette

| Color | Hex | Role |
| --- | --- | --- |
| **Obsidian Black** | `#121212` | Primary brand luxury tone, buttons, active chips |
| **Luxury Beige** | `#C5A880` | Accent badges, gold details, icons |
| **Champagne** | `#E5D5C0` | Secondary luxury accents, borders |
| **Canvas Linen** | `#F9F7F3` | Surface background, cards, text fields |
| **Pure White** | `#FFFFFF` | Card surfaces, sheets, crisp typography |
| **Hairline Border** | `#EBE6DD` | Minimalist editorial dividers |

### Bilingual Typography

- **English (`en`)**: *Cormorant Garamond* for editorial display titles; *Plus Jakarta Sans* for clean, modern body copy.
- **Khmer (`km`)**: *Kantumruy Pro* with custom line-height calculations optimized for Khmer script legibility.
- Supports instant switching without restarting the application.

### Multi-Currency & Cambodian Cash Customs

- **Primary Currencies**: `USD ($)` and `Cambodian Riel (៛)`
- **Exchange Rate**: Configurable standard rate of 1 USD = 4,100 KHR.
- **Dual Display**: All prices prominently show both currencies (e.g. `$185.00 ≈ 758,500 ៛`).
- **100-Riel Customary Rounding**: Cash on Delivery and KHQR calculations automatically round riel figures to the nearest 100 Riels, adhering strictly to Cambodian currency customs where denominations below 100 Riels are not in circulation.

---

## 🗄️ 4. Database Schema & Supabase Architecture

The database is built on PostgreSQL with Row Level Security (RLS) enabled across all tables:

### 15 Production PostgreSQL Tables

1. `profiles`: User profile data linked to `auth.users`, with roles (`customer`, `admin`, `manager`).
2. `categories`: Hierarchical fashion collections with Khmer/English naming and gender tagging.
3. `products`: Main catalog with SKU, bilingual descriptions, materials, and pricing.
4. `product_variants`: Matrix of color swatches (names and hex values), sizes (XS - XXL), and variant SKUs.
5. `inventory`: Physical inventory tracking located at the *BKK1 Flagship Atelier, Phnom Penh*, with reserved quantities.
6. `product_images`: Multi-image editorial carousels per product.
7. `addresses`: Cambodian delivery addresses with province, district, and courier notes.
8. `carts`: Persistent shopping carts per user profile.
9. `cart_items`: Cart line items linked to product variants.
10. `coupons`: Promotional discount codes (`STYLE10`, `CAMBODIA`, `VIP10`, `LUXURY20`) with minimum spend and expiration rules.
11. `orders`: Orders with server-verified financials, address snapshots, and tracking codes.
12. `order_items`: Line item snapshot records.
13. `payments`: Payment audit trail for KHQR payloads, transaction references, and server verification stamps.
14. `reviews`: Customer verified reviews with 1-5 star ratings.
15. `notifications`: Push and in-app member notifications.

### Setup Database

Execute the migration and seed files in the Supabase SQL editor:

```bash
# 1. Run Schema Migration
supabase/migrations/20261122000000_initial_schema.sql

# 2. Run Seed Data
supabase/seed.sql
```

---

## 💳 5. Payment Integrations

### 1. Bakong KHQR (National QR Standard)

- Generates official EMVCo-compliant dynamic QR payloads containing:
  - **Tag 00**: `000201` (Payload Format)
  - **Tag 01**: `010212` (Dynamic QR initiation with transaction amount)
  - **Tag 29**: Merchant Account Information (`stylehouse@aclb`, Bakong ID)
  - **Tag 52**: `5691` (Clothing Boutique MCC)
  - **Tag 53**: `840` (USD) or `116` (KHR)
  - **Tag 54**: Transaction Amount
  - **Tag 58**: `KH` (Cambodia)
  - **Tag 59**: `KALIP STUDIO ATELIER`
  - **Tag 60**: `PHNOM PENH`
  - **Tag 62**: Bill number and order reference
  - **Tag 63**: CRC-16/CCITT-FALSE Checksum (Polynomial `0x1021`, Initial `0xFFFF`)
- Supports **Bakong Deep Linking** (`bakong://qr?data=...`) to open banking apps directly.
- Real-time 5-minute countdown expiration timer in `KhqrPaymentSheet`.

### 2. Cash on Delivery (COD)

- Calculates exact USD amount and rounded KHR amount (100-riel increments).
- Provides banknote recommendations ($10, $20, $50, $100 notes) for smooth courier handovers.

### 3. Server-Side Payment Verification

- Never trusts client-submitted payment flags.
- Simulates or calls backend webhook verification to confirm bank transaction references before marking orders as confirmed.

---

## 🚚 6. Cambodian Logistics & Delivery Workflow

- **Phnom Penh (Same-Day Express)**:
  - Dispatched directly from BKK1 Flagship Atelier (Street 302).
  - SLA: 2 – 4 Hours via dedicated motorcycle express riders.
  - Tracking code format: `VET-PP-XXXX`.
- **Provincial Deliveries** (*Siem Reap, Battambang, Sihanoukville, Kampot, Kandal, etc.*):
  - Partner: **Virak Buntham (VET) Express Cambodia** / J&T Express.
  - SLA: 24 – 48 Hours (1 – 2 Business Days).
  - Tracking code format: `VET-PROV-XXXX`.
- **Free Delivery Threshold**: Automatic free shipping on all orders over $50.00 (standard fee is $2.00).

---

## 🛡️ 7. Executive Administration Portal

Accessible by authorized personnel (`user.isAdmin == true`):

- **Executive Analytics**: Gross Merchandise Value (GMV) in USD and KHR, total order volumes, and low-inventory warnings.
- **Physical Inventory Restock**: 1-tap fast restock modal adding physical units to the BKK1 atelier inventory.
- **Order Pipeline Manager**: Transition orders through fulfillment phases (*Pending $\rightarrow$ Confirmed $\rightarrow$ Processing $\rightarrow$ Delivering $\rightarrow$ Delivered*).
- **Payment Slip Audit**: Audit trail of KHQR transaction references and COD collections.
- **Role Switcher**: Convenient toggle in `ProfileScreen` allowing developers and auditors to switch between VIP Member and Atelier Staff roles seamlessly.

---

## 🤖 8. AI Concierge & n8n Workflow Automations

### AI Fashion Concierge

- Accessible via the floating luxury button on the Home Screen or from `/ai-concierge`.
- Grounded in real catalog products, physical stock levels, and user orders.
- Answers queries regarding:
  - Product stock & sizing recommendations.
  - Delivery SLA policies across Phnom Penh and provinces.
  - Cambodian payment methods (KHQR & COD).
  - Khmer silk and linen fabric care.
- **Security Rule**: Uses backend proxy endpoint (`AI_BACKEND_URL`). No raw OpenAI API keys are embedded in the mobile binary.

### n8n Automations

- **`order_created`**: Dispatches order payloads with recipient details, financial totals, and courier tracking to n8n webhooks for instant store management Telegram notifications.
- **`payment_verified`**: Dispatches verified transaction events to generate PDF invoices and dispatch courier slips.
- **`inventory_low`**: Automatically alerts boutique floor managers when stock drops below 5 units.

---

## 🧪 9. Automated Testing & Verification

The project includes an automated test suite with **53 unit and widget tests** covering every layer:

| Test File | Description | Status |
| --- | --- | --- |
| `test/auth_test.dart` | Auth notifier, user model, roles, sign-in, guest mode | ✅ PASSED |
| `test/checkout_test.dart` | Checkout form validation, pricing calculations, delivery thresholds | ✅ PASSED |
| `test/currency_test.dart` | Exchange rates (1 USD = 4,100 KHR) and dual-currency formatting | ✅ PASSED |
| `test/phase4_repository_test.dart` | Product variants, categories, inventory stock gating, coupons | ✅ PASSED |
| `test/phase5_payment_delivery_test.dart` | EMVCo Bakong KHQR generator, CRC-16 checksum, COD 100-riel rounding, SLA routing | ✅ PASSED |
| `test/phase6_admin_test.dart` | RBAC route guards, GMV analytics, restock, fulfillment transitions | ✅ PASSED |
| `test/phase7_ai_n8n_test.dart` | AI concierge grounding, n8n webhook event payloads, chat state | ✅ PASSED |
| `test/responsive_test.dart` | Adaptive layout calculations for phones and tablets | ✅ PASSED |
| `test/widget_test.dart` | App smoke test and 5-tab persistent navigation | ✅ PASSED |

### Running Static Analysis & Tests

```powershell
# Run Flutter static analysis (0 warnings, 0 errors)
flutter analyze

# Run complete unit and widget test suite (53 passing tests)
flutter test
```

---

## 🚀 10. Deployment & Release Preparation

### Environment Configuration

Create a `.env` file at the root of the project (modeled after `.env.example`):

```ini
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
AI_BACKEND_URL=https://api.stylehouse.com.kh/v1/ai-chat
N8N_ORDER_WEBHOOK_URL=https://n8n.stylehouse.com.kh/webhook/orders
N8N_WEBHOOK_SECRET=your_n8n_webhook_secret
```

### Build Production Release APK (Android)

```powershell
flutter build apk --release
```

### Build Production iOS Archive (macOS/Xcode)

```bash
flutter build ipa --release
```

---

*Crafted with passion for KALIP studio Cambodia.*
