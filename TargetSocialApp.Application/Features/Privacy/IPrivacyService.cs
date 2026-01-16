using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Media.Requests;
using TargetSocialApp.Application.Features.Privacy.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Media
{
    public interface IMediaService
    {
        Task<Response<string>> UploadMediaAsync(UploadMediaRequest request);
        Task<Response<string>> DeleteMediaAsync(string mediaId); // mediaId might be URL or ID
    }
}

namespace TargetSocialApp.Application.Features.Privacy
{
    public interface IPrivacyService
    {
        Task<Response<PrivacySetting>> GetPrivacySettingsAsync(int userId);
        Task<Response<PrivacySetting>> UpdatePrivacySettingsAsync(int userId, UpdatePrivacySettingsRequest request);
        
        Task<Response<string>> BlockUserAsync(int userId, int startBlockUserId);
        Task<Response<string>> UnblockUserAsync(int userId, int unblockUserId);
        Task<Response<List<User>>> GetBlockedUsersAsync(int userId);
        
        Task<Response<string>> ChangePasswordAsync(int userId, ChangePasswordRequest request);
        Task<Response<string>> Enable2FAAsync(int userId);
    }
}
