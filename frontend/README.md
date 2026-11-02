# Restaurant Management App (frontend)

Flutter Web app for the restaurant ordering system. It works on a laptop browser and on a phone browser:
every screen uses `LayoutBuilder` to switch between a wide and a narrow layout.

## Stack

| Concern | Choice |
|---|---|
| UI | Flutter Web, Material 3 |
| State | Riverpod 3 (`Notifier`, `FutureProvider`, `StreamProvider` for polling) |
| Routing | go_router |
| HTTP | Dio with an interceptor for the admin token |
| Storage | shared_preferences (keeps the admin logged in after a refresh) |

## Run

The API must be running first (see `backend/README.md`), by default on http://localhost:5023.

```bash
cd frontend
flutter run -d chrome
```

To point at a different API address:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:5023
```

Without `API_BASE_URL`, the app calls port 5023 on the same host the page was opened from,
so opening the app from a phone on the laptop's IP reaches the API on that laptop.

Tests:

```bash
flutter test
```

## Pages

| Route | Page |
|---|---|
| `/` | Menu with category filter + cart (side panel on laptop, drawer with counter on phone) |
| `/checkout` | Order form with validation, order summary |
| `/track` | Enter an order number |
| `/track/:id` | Live order status (polling every 4 s, stops at Delivered or when leaving the page) |
| `/admin` | Login form, then Orders tab (auto refresh every 5 s) and Menu management tab |

## Responsive layout

| Width | Layout |
|---|---|
| < 600 | One product column, cart as a drawer, admin actions under each product |
| 600 – 899 | Two product columns, cart as a drawer |
| ≥ 900 | Cart as a fixed side panel, checkout form and summary side by side, product form as a dialog |
| ≥ 1100 | Three product columns |

## Folder structure

```
lib/
├── core/        config, Dio client, error mapping, Result, theme, router, validators, shared widgets
└── features/
    ├── menu/    domain / data / presentation
    ├── cart/    domain / presentation (frontend-only state)
    ├── orders/  domain / data / presentation (checkout + tracking)
    └── admin/   domain / data / presentation (login, orders, menu management)
```

## Decisions

- The frontend sends only `productId` and `quantity`; the cart total is for display only and the server total is the one shown after ordering.
- Validation rules in `core/validation/validators.dart` match the backend rules.
- Polling instead of WebSocket keeps the tracking page simple; SignalR is a possible future improvement.
- Any 401 from an admin endpoint clears the token and shows the login form again.
