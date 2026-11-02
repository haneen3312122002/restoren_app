using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using restoren_app.Data.Models;

namespace restoren_app.Data
{
    public static class DbSeeder
    {
        public static async Task SeedAsync(AppDbContext db, UserManager<User> userManager,
            RoleManager<IdentityRole> roleManager, IConfiguration config)
        {
            await db.Database.MigrateAsync();

            await SeedMenuAsync(db);
            await SeedAdminAsync(userManager, roleManager, config);
        }

        private static async Task SeedMenuAsync(AppDbContext db)
        {
            if (await db.Categories.AnyAsync())
                return;

            var starters = new Category { Name = "Starters", SortOrder = 1 };
            var mains = new Category { Name = "Main Dishes", SortOrder = 2 };
            var desserts = new Category { Name = "Desserts", SortOrder = 3 };
            var drinks = new Category { Name = "Drinks", SortOrder = 4 };

            starters.Products.Add(NewProduct("Garden Salad", "Fresh seasonal greens with a light lemon dressing.", 4.50m, "1512621776951-a57141f2eefd",
                new List<string> { "Lettuce", "Tomato", "Cucumber", "Lemon", "Olive oil" }));
            starters.Products.Add(NewProduct("Fattoush", "Crispy bread salad with sumac and pomegranate molasses.", 5.00m, "1540189549336-e6e99c3679fe",
                new List<string> { "Lettuce", "Toasted bread", "Radish", "Sumac", "Pomegranate molasses" }));
            starters.Products.Add(NewProduct("Hummus Plate", "Creamy chickpea dip served with warm bread.", 3.75m, "1541519227354-08fa5d50c44d",
                new List<string> { "Chickpeas", "Tahini", "Garlic", "Lemon", "Olive oil" }));

            mains.Products.Add(NewProduct("Classic Burger", "Grilled beef patty with cheese and house sauce.", 8.50m, "1568901346375-23c9450c58cd",
                new List<string> { "Beef", "Cheddar", "Lettuce", "Tomato", "Brioche bun" }));
            mains.Products.Add(NewProduct("Margherita Pizza", "Stone-baked pizza with tomato and mozzarella.", 9.00m, "1565299624946-b28f40a0ae38",
                new List<string> { "Dough", "Tomato sauce", "Mozzarella", "Basil" }));
            mains.Products.Add(NewProduct("Creamy Pasta", "Penne in a rich parmesan cream sauce.", 8.75m, "1621996346565-e3dbc646d9a9",
                new List<string> { "Penne", "Cream", "Parmesan", "Garlic", "Mushroom" }));
            mains.Products.Add(NewProduct("Grilled Steak", "Tender steak with roasted vegetables.", 15.00m, "1544025162-d76694265947",
                new List<string> { "Beef steak", "Potato", "Pepper", "Rosemary" }));

            desserts.Products.Add(NewProduct("Cheesecake", "Baked cheesecake with berry topping.", 4.25m, "1571877227200-a0d98ea607e9",
                new List<string> { "Cream cheese", "Biscuit", "Berries", "Sugar" }));
            desserts.Products.Add(NewProduct("Ice Cream Cup", "Three scoops of your favourite flavours.", 3.50m, "1563805042-7684c019e1cb",
                new List<string> { "Milk", "Cream", "Sugar", "Vanilla" }));
            desserts.Products.Add(NewProduct("Donuts", "Glazed donuts, freshly made.", 3.00m, "1551024601-bec78aea704b",
                new List<string> { "Flour", "Sugar", "Chocolate glaze" }));

            drinks.Products.Add(NewProduct("Espresso", "Strong single-shot espresso.", 2.00m, "1509042239860-f550ce710b93",
                new List<string> { "Coffee beans", "Water" }));
            drinks.Products.Add(NewProduct("Fresh Orange Juice", "Squeezed to order.", 2.75m, "1600271886742-f049cd451bba",
                new List<string> { "Orange" }));
            drinks.Products.Add(NewProduct("Mint Lemonade", "Cold lemonade with fresh mint.", 2.50m, "1621263764928-df1444c5e859",
                new List<string> { "Lemon", "Mint", "Sugar", "Ice" }));

            db.Categories.AddRange(starters, mains, desserts, drinks);
            await db.SaveChangesAsync();
        }

        // Creates the Admin role and the first admin.
        // The username and password come from user-secrets, never from the code.
        private static async Task SeedAdminAsync(UserManager<User> userManager, RoleManager<IdentityRole> roleManager, IConfiguration config)
        {
            if (!await roleManager.RoleExistsAsync(Roles.Admin))
                await roleManager.CreateAsync(new IdentityRole(Roles.Admin));

            var username = config["Admin:Username"];
            var password = config["Admin:Password"];

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                Console.WriteLine("No admin created. Add Admin:Username and Admin:Password with user-secrets.");
                return;
            }

            if (await userManager.FindByNameAsync(username) != null)
                return;

            var admin = new User { UserName = username.Trim() };
            var result = await userManager.CreateAsync(admin, password);

            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(admin, Roles.Admin);
                Console.WriteLine($"Admin user '{username}' created.");
            }
            else
            {
                foreach (var error in result.Errors)
                    Console.WriteLine($"Could not create admin: {error.Description}");
            }
        }

        // Small helper that builds one product with an Unsplash image
        private static Product NewProduct(string name, string description, decimal price, string unsplashId, List<string> ingredients)
        {
            return new Product
            {
                Name = name,
                Description = description,
                Price = price,
                ImageUrl = $"https://images.unsplash.com/photo-{unsplashId}?w=600",
                Ingredients = ingredients,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }
    }
}
