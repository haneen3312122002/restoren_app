using Microsoft.AspNetCore.Identity;

namespace restoren_app.Data.Models
{
    // The admin user. Id, UserName and PasswordHash all come from IdentityUser.
    // Only admins log in; customers order without an account.
    public class User : IdentityUser
    {
    }

    // Role names in one place so we don't type "Admin" everywhere
    public static class Roles
    {
        public const string Admin = "Admin";
    }
}
