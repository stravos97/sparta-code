using Microsoft.AspNetCore.Identity.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;


public class LoginRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
}

[ApiController]
[Route("[controller]")]
public class AuthController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public AuthController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpPost("login")]
    public IActionResult Login(LoginRequest loginRequest)
    {
        // TODO: Replace with proper authentication (ASP.NET Core Identity, database validation, etc.)
        // PLACEHOLDER: Remove hardcoded credentials - implement proper user validation
        // Example: if (await _userManager.CheckPasswordAsync(user, loginRequest.Password))
        if (ValidateUserCredentials(loginRequest.Username, loginRequest.Password))
        {
            var claims = new[]
            {
            new Claim(ClaimTypes.Name, loginRequest.Username)
        };

            // See appsettings.json for jwt
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Issuer"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds);

            return Ok(new { token = new JwtSecurityTokenHandler().WriteToken(token) });
        }

        return Unauthorized();
    }

    // PLACEHOLDER METHOD - Replace with actual user validation logic
    private bool ValidateUserCredentials(string username, string password)
    {
        // TODO: Implement proper user validation
        // - Query user database
        // - Verify hashed password
        // - Check user status/roles
        // Example: return await _userService.ValidateAsync(username, password);
        return false; // Always return false until proper implementation
    }

}