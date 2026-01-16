using System.Threading.Tasks;
using Mapster;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Users.Requests;
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

        public async Task<Response<User>> GetUserByIdAsync(int id)
        {
            var user = await _userRepository.GetByIdAsync(id);
            if (user == null)
            {
                return Response<User>.Failure("User not found");
            }
            return Response<User>.Success(user);
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

        public async Task<Response<User>> UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return Response<User>.Failure("User not found");

            // Efficient mapping via Mapster
            request.Adapt(user);

            await _userRepository.UpdateAsync(user);
            await _unitOfWork.CompleteAsync();

            return Response<User>.Success(user);
        }
    }
}
