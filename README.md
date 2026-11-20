# 🍽️ Restoren: Restaurant Ordering Platform (Full-Stack)

A full-stack restaurant ordering system. Customers browse the menu, build a cart, place an order and track it live.
The restaurant admin logs in to manage orders and the menu.

| Part | Folder | Stack |
|---|---|---|
| **Client** | [`frontend/`](frontend) | Flutter Web, Riverpod 3, go_router, Dio, Clean Architecture |
| **API** | [`backend/`](backend) | ASP.NET Core 10, CQRS + MediatR, EF Core 10, SQL Server, JWT |

## Features

**Customer**
- Menu grouped by category, with a cart (side panel on laptop, drawer on phone)
- Checkout form with field-level validation
- Live order tracking (polling every 4 s)

**Admin**
- JWT login (rate limited: 5 attempts/min per IP)
- Orders tab with auto refresh and one-step-forward status changes (Pending → Preparing → Ready → Delivered)
- Menu management: create, edit, hide/show and delete products

## Highlights

- **Clean Architecture on the client**: 4 feature modules (`menu`, `cart`, `orders`, `admin`), each split into domain / data / presentation.
- **CQRS with MediatR on the server**: controllers only receive the request and send it through MediatR; business logic lives in handlers.
- **Server-side trust**: the client sends only `productId` and `quantity`. Prices and totals are computed on the server, so a tampered price has no effect.
- **JWT auth + `Admin` role**: the client attaches the token through a Dio interceptor and force-logs-out on any `401`.
- **Typed error handling**: HTTP errors and server validation responses are mapped to typed results and shown as field-level messages in the UI.
- **Order snapshots**: each order item stores the product name and unit price at order time, so later menu edits never change old orders.
- **Privacy on public tracking**: `GET /api/orders/{id}` never returns name, phone or notes.
- **Tests**: xUnit for order totals, status transitions and `CreateOrderHandler`; `flutter_test` for the cart view model and form validators.

## Quick start

Requirements: .NET 10 SDK, SQL Server LocalDB, Flutter SDK (3.11+).

```bash
# 1. API (first set the secrets once, see backend/README.md)
dotnet run --project backend/restoren_app --launch-profile http
# Swagger: http://localhost:5023/swagger

# 2. Client
cd frontend
flutter run -d chrome
```

On first start the API applies the migrations, seeds 4 categories and 13 products, and creates the admin account from your settings.

Run the tests:

```bash
dotnet test backend/restoren_app.slnx
cd frontend && flutter test
```

## Project structure

```
restoren_app/
├── backend/     ASP.NET Core API + xUnit tests   → see backend/README.md
└── frontend/    Flutter Web client                → see frontend/README.md
```

## Documentation

- [Backend README](backend/README.md): endpoints, run instructions, architecture decisions
- [Frontend README](frontend/README.md): pages, responsive layout, folder structure

## Roadmap

- SignalR instead of polling for live order status
- Widget tests for the checkout and admin flows

## Author

**Haneen Khanfar**: Flutter Developer · [LinkedIn](https://www.linkedin.com/in/haneen-khanfar-a22575278) · [Portfolio](https://my-portfolio-c7293.web.app)
