using Microsoft.AspNetCore.Http;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Media.Requests
{
    public class UploadMediaRequest
    {
        public IFormFile File { get; set; } = null!;
        public string Folder { get; set; } = "uploads";
    }
}

namespace TargetSocialApp.Application.Features.Privacy.Requests
{
    public class UpdatePrivacySettingsRequest
    {
        public PrivacyLevel ProfileVisibility { get; set; }
        // Add other settings
    }
    
    public class ChangePasswordRequest
    {
        public string OldPassword { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
    }
}
