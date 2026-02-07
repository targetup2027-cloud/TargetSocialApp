using System;

namespace TargetSocialApp.Application.Features.Users.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Bio { get; set; }
        public string? AvatarUrl { get; set; }
        public string? CoverPhotoUrl { get; set; }
        public bool IsEmailVerified { get; set; }
        public DateTime CreatedAt { get; set; } // BaseEntity has CreatedAt? Check BaseEntity.
    }
}
