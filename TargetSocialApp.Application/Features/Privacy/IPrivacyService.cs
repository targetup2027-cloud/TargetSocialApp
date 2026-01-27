using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Privacy.Requests;
using TargetSocialApp.Application.Features.Privacy.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;

namespace TargetSocialApp.Application.Features.Privacy
{
    public interface IPrivacyService
    {
        Task<Response<PrivacySettingDto>> GetPrivacySettingsAsync(int userId);
        Task<Response<PrivacySettingDto>> UpdatePrivacySettingsAsync(int userId, UpdatePrivacySettingsRequest request);
        
        Task<Response<string>> BlockUserAsync(int userId, int startBlockUserId);
        Task<Response<string>> UnblockUserAsync(int userId, int unblockUserId);
        Task<Response<List<UserDto>>> GetBlockedUsersAsync(int userId);
        
        Task<Response<string>> ChangePasswordAsync(int userId, ChangePasswordRequest request);
        Task<Response<string>> Enable2FAAsync(int userId);
    }
}
