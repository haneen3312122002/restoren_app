# Restaurant Management API (backend)

ASP.NET Core 10 Web API for the restaurant ordering system: public menu, ordering, order tracking,
admin login (JWT), order management and menu CRUD.

## Stack

| Layer | Choice |
|---|---|
| API | ASP.NET Core 10 Web API, controllers |
| Pattern | CQRS with MediatR (commands / queries / handlers) |
| Data | EF Core 10 + SQL Server (LocalDB for local development) |
| Auth | JWT bearer with an `Admin` role, BCrypt password hashes |
| Docs | Swagger (Swashbuckle) with an Authorize button |
| Tests | xUnit + EF Core InMemory |

## Run locally

Requirements: .NET 10 SDK and SQL Server LocalDB (installed with Visual Studio).

1. Set the secrets once (they are stored outside the repo with user-secrets):

```bash
cd backend/restoren_app
dotnet user-secrets set "Jwt:Key" "<any random string of at least 32 characters>"
dotnet user-secrets set "Admin:Username" "admin"
dotnet user-secrets set "Admin:Password" "<local admin password>"
```

The same values can be given as environment variables instead: `Jwt__Key`, `Admin__Username`, `Admin__Password`.
The app refuses to start without a `Jwt:Key` of at least 32 characters.

2. Run:

```bash
dotnet run --project backend/restoren_app --launch-profile http
```

On start the app applies the migrations, seeds 4 categories and 13 products, and creates the admin
from the settings above. Swagger opens at http://localhost:5023/swagger.

3. Tests:

```bash
dotnet test backend/restoren_app.slnx
```

## Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/menu` | – | Available products grouped by category |
| POST | `/api/orders` | – | Place an order → 201 |
| GET | `/api/orders/{id}` | – | Track an order (no name, phone or notes) |
| POST | `/api/auth/login` | – | Admin login → JWT (rate limited: 5/min per IP) |
| GET | `/api/admin/orders?status=&includeDelivered=` | Admin | Orders with customer details |
| PATCH | `/api/admin/orders/{id}/status` | Admin | Move an order one step forward |
| GET | `/api/admin/menu` | Admin | All products, including hidden |
| GET | `/api/admin/menu/{id}` | Admin | One product |
| GET | `/api/admin/menu/categories` | Admin | Categories for the dropdown |
| POST | `/api/admin/menu` | Admin | Create a product → 201 |
| PUT | `/api/admin/menu/{id}` | Admin | Update a product |
| PATCH | `/api/admin/menu/{id}/availability` | Admin | Hide / show a product |
| DELETE | `/api/admin/menu/{id}` | Admin | Delete a product → 204 |

## Folder structure

```
restoren_app/
├── Controllers/     HTTP only: receive the request, send it through MediatR
├── CQRS/            business logic, one folder per feature
│   ├── menu/        Queries + Handlers
│   ├── order/       Commands + Queries + Handlers
│   ├── product/     Commands + Queries + Handlers (admin menu)
│   └── auth/        Commands + Handlers
├── Data/            AppDbContext, seed, Models (entities), Dtos, Migrations
├── Rules/           shared business rules: status transitions, total calculation
├── Validation/      custom validation attributes
├── Middleware/      one error handler that returns ProblemDetails
├── Extensions/      JWT and Swagger setup
└── Services/        JWT token creation
```

## Architecture decisions

- **CQRS handlers instead of a Repository layer.** Each handler talks to `AppDbContext` directly. The
  DbContext is already a Unit of Work, so an extra Repository adds no value at this size.
- **The total is computed on the server.** The client sends only `productId` and `quantity`; prices come
  from the database, so a tampered price or total has no effect.
- **Snapshot in OrderItems.** Each item stores the product name and unit price at order time. Changing a
  price or deleting a product does not change old orders (deleting sets `ProductId` to NULL).
- **Status rule in one place.** `Rules/OrderStatusRules` allows only Pending → Preparing → Ready → Delivered.
  The check runs in the handler, never only in the UI.
- **No personal data on public tracking.** Order ids are sequential and guessable, so
  `GET /api/orders/{id}` never returns the customer's name, phone or notes.
- **Polling instead of SignalR** for live status (planned for the frontend); SignalR is a future improvement.
- **Money as `decimal` / `decimal(10,2)`**, never floating point; dates stored in UTC.
