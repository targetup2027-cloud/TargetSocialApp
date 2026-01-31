# Backend Requirements for Google Sign-In
**للباك إند ديفلوبر - متطلبات تسجيل الدخول بواسطة جوجل**

---

## ❌ **الجزء المفقود في الباك إند**

للأسف، **لا أستطيع الوصول إلى كود الباك إند** (.NET) مباشرةً لأنه في GitHub.
لكن بناءً على المشاريع الـ .NET النموذجية، إليك **ما يجب التحقق منه**:

---

## ✅ **Checklist - الباك إند ديفلوبر**

### 1. NuGet Packages Required
تأكد من وجود الـ packages دي:

```xml
<PackageReference Include="Google.Apis.Auth" Version="1.68.0" />
<PackageReference Include="Google.Apis.Auth.AspNetCore3" Version="1.68.0" />
```

**تثبيت:**
```bash
dotnet add package Google.Apis.Auth
dotnet add package Google.Apis.Auth.AspNetCore3
```

---

### 2. Endpoint: `/auth/google`

**المطلوب:**
```csharp
[HttpPost("google")]
public async Task<IActionResult> GoogleSignIn([FromBody] GoogleSignInRequest request)
{
    // 1. Validate Google ID Token
    var settings = new GoogleJsonWebSignature.ValidationSettings
    {
        Audience = new[] { Configuration["Google:ClientId"] }
    };

    GoogleJsonWebSignature.Payload payload;
    try
    {
        payload = await GoogleJsonWebSignature.ValidateAsync(
            request.IdToken, 
            settings
        );
    }
    catch (InvalidJwtException)
    {
        return Unauthorized(new { error = "Invalid Google token" });
    }

    // 2. Extract user info
    var email = payload.Email;
    var name = payload.Name;
    var picture = payload.Picture;
    var googleUserId = payload.Subject;

    // 3. Get or create user
    var user = await _userRepository.GetByEmailAsync(email);
    if (user == null)
    {
        user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            DisplayName = name,
            ProfilePicture = picture,
            GoogleId = googleUserId,
            CreatedAt = DateTime.UtcNow,
            Verified = true // Google emails are verified
        };
        await _userRepository.CreateAsync(user);
    }

    // 4. Generate JWT tokens
    var accessToken = _jwtService.GenerateAccessToken(user);
    var refreshToken = _jwtService.GenerateRefreshToken(user);

    // 5. Save refresh token
    await _tokenRepository.SaveRefreshTokenAsync(user.Id, refreshToken);

    return Ok(new
    {
        user = new
        {
            id = user.Id,
            email = user.Email,
            displayName = user.DisplayName,
            profilePicture = user.ProfilePicture,
            createdAt = user.CreatedAt
        },
        accessToken,
        refreshToken
    });
}
```

---

### 3. Configuration (appsettings.json)

أضف في `appsettings.json`:

```json
{
  "Google": {
    "ClientId": "YOUR-GOOGLE-WEB-CLIENT-ID.apps.googleusercontent.com"
  },
  "Jwt": {
    "Secret": "your-super-secret-key-min-32-chars",
    "AccessTokenExpiryMinutes": 15,
    "RefreshTokenExpiryDays": 7,
    "Issuer": "U-Axis-API",
    "Audience": "U-Axis-Mobile"
  }
}
```

**⚠️ Important:**
- `Google:ClientId` هتطلعه من Firebase Console بعد ما تسجل الـ Android/iOS apps
- لازم تكون **Web Client ID** مش Android/iOS Client ID

---

### 4. Request/Response Models

**Request:**
```csharp
public class GoogleSignInRequest
{
    [Required]
    public string IdToken { get; set; }
}
```

**Response:**
```csharp
public class AuthResponse
{
    public UserDto User { get; set; }
    public string AccessToken { get; set; }
    public string RefreshToken { get; set; }
}

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public string DisplayName { get; set; }
    public string ProfilePicture { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

---

### 5. Database Schema

تأكد من وجود الـ columns دي في `Users` table:

```sql
CREATE TABLE Users (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    DisplayName NVARCHAR(255) NOT NULL,
    ProfilePicture NVARCHAR(500),
    GoogleId NVARCHAR(255) UNIQUE,  -- للتحقق من Google user
    PasswordHash NVARCHAR(MAX),      -- NULL for Google users
    CreatedAt DATETIME2 NOT NULL,
    Verified BIT NOT NULL DEFAULT 0
);
```

---

### 6. JWT Token Generation Service

```csharp
public class JwtService
{
    private readonly IConfiguration _config;
    
    public string GenerateAccessToken(User user)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim("displayName", user.DisplayName),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_config["Jwt:Secret"])
        );
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(
                int.Parse(_config["Jwt:AccessTokenExpiryMinutes"])
            ),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

---

## 🔍 **كيف تعرف Google Web Client ID؟**

### من Firebase Console:
1. اذهب إلى **Project Settings** ⚙️
2. اختار **General** tab
3. Scroll down لـ **Your apps**
4. تحت **Web App** (لو مش موجود، اعمل Add app → Web)
5. هتلاقي **Web Client ID** على الشكل:
   ```
   123456789-abc123def456.apps.googleusercontent.com
   ```

### أو من Google Cloud Console:
1. [console.cloud.google.com](https://console.cloud.google.com)
2. **APIs & Services** → **Credentials**
3. تحت **OAuth 2.0 Client IDs**
4. اختار الـ **Web client**

---

## 🧪 **Testing الـ Endpoint**

استخدم Postman:

```http
POST https://api.dev.u-axis.com/auth/google
Content-Type: application/json

{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdlM..."
}
```

**للحصول على ID Token للتجربة:**
- استخدم Google OAuth 2.0 Playground: https://developers.google.com/oauthplayground

---

## ✅ **Verification الكامل**

- [ ] `Google.Apis.Auth` package installed
- [ ] `/auth/google` endpoint exists
- [ ] `GoogleJsonWebSignature.ValidateAsync()` implemented
- [ ] Google Web Client ID في `appsettings.json`
- [ ] Database has `GoogleId` column
- [ ] JWT tokens generated correctly
- [ ] Refresh token flow works
- [ ] Test with real Google ID token passes

---

## 📞 **إذا كان هناك أي جزء ناقص:**

أخبرني بالـ error message أو المشكلة اللي بتواجهك:
1. Package installation error → نحلها
2. Token validation failing → نشوف الـ configuration
3. Database schema issues → نعدل الـ migration
4. JWT generation problems → نصلح الـ service

**الباك إند ديفلوبر لازم ينفذ الخطوات دي علشان Google Sign-In يشتغل من الموبايل.**
