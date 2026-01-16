using Microsoft.AspNetCore.Http;
using System;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Users.Requests
{
    public class UpdateProfileRequest
    {
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public DateTime DateOfBirth { get; set; }
        public Gender Gender { get; set; }
        public string? Bio { get; set; }
    }

    public class UpdateAvatarRequest
    {
        public IFormFile File { get; set; } = null!;
    }

    public class UpdateCoverRequest
    {
        public IFormFile File { get; set; } = null!;
    }
}
