using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using restoren_app.Data;
using restoren_app.Data.Dtos.auth;
using restoren_app.Data.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace restoren_app.Controllers
{
    // Admin login
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<User> _userMan;
        private readonly IConfiguration _config;

        public AuthController(UserManager<User> userMan, IConfiguration config)
        {
            _userMan = userMan;
            _config = config;
        }

        // Returns a JWT token. Limited to 5 tries per minute 
        [HttpPost("login")]
        [EnableRateLimiting("login")]
        public async Task<ActionResult<LoginResponseDto>> Login(LoginDto dto)
        {
            var user = await _userMan.FindByNameAsync(dto.Username.Trim());

            // Same message for a wrong username or a wrong password,
            // so nobody can find out which usernames exist
            if (user == null)
                return Unauthorized(new { message = ErrorMessages.InvalidCredentials });
            //locked user -> many failed attempts
            if (await _userMan.IsLockedOutAsync(user))
                return Unauthorized(new { message = ErrorMessages.AccountLocked });

            var passwordOk = await _userMan.CheckPasswordAsync(user, dto.Password);
            if (!passwordOk)
            {
                // Identity counts the failures and locks the account after 3
                await _userMan.AccessFailedAsync(user);
                return Unauthorized(new { message = ErrorMessages.InvalidCredentials });
            }

            await _userMan.ResetAccessFailedCountAsync(user);

            var roles = await _userMan.GetRolesAsync(user);
            var expiresAt = DateTime.UtcNow.AddHours(8);
            var token = GenerateAccessToken(user, roles, expiresAt);

            return Ok(new LoginResponseDto
            {
                Token = token,
                ExpiresAt = expiresAt,
                Username = user.UserName ?? string.Empty,
                Role = roles.FirstOrDefault() ?? string.Empty
            });
        }

        // Helpers 
        private string GenerateAccessToken(User user, IList<string> roles, DateTime expiresAt)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.UserName ?? string.Empty)
            };
            foreach (var role in roles)
                claims.Add(new Claim(ClaimTypes.Role, role));

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: expiresAt,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
