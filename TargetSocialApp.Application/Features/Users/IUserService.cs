using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Users.Requests;
using TargetSocialApp.Domain.Entities;

using TargetSocialApp.Application.Features.Users.DTOs;

namespace TargetSocialApp.Application.Features.Users
{
    public interface IUserService
    {
        Task<Response<UserDto>> GetUserByIdAsync(int id);
        Task<Response<UserDto>> UpdateProfileAsync(int userId, UpdateProfileRequest request);
        Task<Response<string>> UpdateAvatarAsync(int userId, UpdateAvatarRequest request);
        Task<Response<string>> UpdateCoverAsync(int userId, UpdateCoverRequest request);
        Task<Response<string>> DeleteAvatarAsync(int userId);
    }
}
