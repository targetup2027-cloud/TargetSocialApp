using System.Threading.Tasks;
using Mapster;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Users.Requests;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Users
{
    public class UserService : AppService, IUserService
    {
        private readonly IGenericRepository<User> _userRepository;
        private readonly IUnitOfWork _unitOfWork;

        public UserService(IGenericRepository<User> userRepository, IUnitOfWork unitOfWork)
        {
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<string>> DeleteAvatarAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return Response<string>.Failure("User not found");
            
            user.AvatarUrl = null; 
            await _userRepository.UpdateAsync(user);
            await _unitOfWork.CompleteAsync();
            
            return Response<string>.Success("Avatar deleted");
        }

        public async Task<Response<UserDto>> GetUserByIdAsync(int id)
        {
            var user = await _userRepository.GetByIdAsync(id);
            if (user == null)
            {
                return Response<UserDto>.Failure("User not found");
            }
            return Response<UserDto>.Success(MapToDto(user));
        }

        public async Task<Response<string>> UpdateAvatarAsync(int userId, UpdateAvatarRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return Response<string>.Failure("User not found");

            var url = await UploadImageAsync(request.File, "avatars");
            user.AvatarUrl = url;
            
            await _userRepository.UpdateAsync(user);
            await _unitOfWork.CompleteAsync();

            return Response<string>.Success(url);
        }

        public async Task<Response<string>> UpdateCoverAsync(int userId, UpdateCoverRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return Response<string>.Failure("User not found");

            var url = await UploadImageAsync(request.File, "covers");
            user.CoverPhotoUrl = url;
            
            await _userRepository.UpdateAsync(user);
            await _unitOfWork.CompleteAsync();

            return Response<string>.Success(url);
        }

        public async Task<Response<UserDto>> UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return Response<UserDto>.Failure("User not found");

            // Efficient mapping via Mapster for update
            request.Adapt(user);

            await _userRepository.UpdateAsync(user);
            await _unitOfWork.CompleteAsync();

            return Response<UserDto>.Success(MapToDto(user));
        }

        private UserDto MapToDto(User user)
        {
            return new UserDto
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                Bio = user.Bio,
                AvatarUrl = user.AvatarUrl,
                CoverPhotoUrl = user.CoverPhotoUrl,
                IsEmailVerified = user.IsEmailVerified,
                CreatedAt = user.CreatedAt
            };
        }
    }
}
