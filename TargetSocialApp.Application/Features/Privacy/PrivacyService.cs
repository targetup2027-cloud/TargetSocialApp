using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mapster;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Privacy.Requests;
using TargetSocialApp.Application.Features.Privacy.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Privacy
{
    public class PrivacyService : AppService, IPrivacyService
    {
        private readonly IGenericRepository<User> _userRepository;
        private readonly IGenericRepository<PrivacySetting> _privacyRepository;
        private readonly IGenericRepository<BlockedUser> _blockedRepository;
        private readonly IUnitOfWork _unitOfWork;

        public PrivacyService(
            IGenericRepository<User> userRepository,
            IGenericRepository<PrivacySetting> privacyRepository,
            IGenericRepository<BlockedUser> blockedRepository,
            IUnitOfWork unitOfWork)
        {
            _userRepository = userRepository;
            _privacyRepository = privacyRepository;
            _blockedRepository = blockedRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<string>> BlockUserAsync(int userId, int blockedUserId)
        {
             if(userId == blockedUserId) return Response<string>.Failure("Cannot block self");
             
             var existing = await _blockedRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(b => b.UserId == userId && b.BlockedUserId == blockedUserId);
             
             if(existing != null) return Response<string>.Success("Already blocked");

             await _blockedRepository.AddAsync(new BlockedUser { UserId = userId, BlockedUserId = blockedUserId });
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Blocked");
        }

        public async Task<Response<string>> ChangePasswordAsync(int userId, ChangePasswordRequest request)
        {
             // Simplify: In real world, use UserManager or Hash verification
             var user = await _userRepository.GetByIdAsync(userId);
             // Stub
             return Response<string>.Success("Password changed (Stub)");
        }

        public async Task<Response<string>> Enable2FAAsync(int userId)
        {
             return Response<string>.Success("2FA Enabled (Stub)");
        }

        public async Task<Response<List<UserDto>>> GetBlockedUsersAsync(int userId)
        {
             var blocked = await _blockedRepository.GetTableNoTracking()
                 .Where(b => b.UserId == userId)
                 .Include(b => b.Blocked)
                 .Select(b => new UserDto
                 {
                     Id = b.Blocked.Id,
                     FirstName = b.Blocked.FirstName,
                     LastName = b.Blocked.LastName,
                     Email = b.Blocked.Email,
                     PhoneNumber = b.Blocked.PhoneNumber,
                     Bio = b.Blocked.Bio,
                     AvatarUrl = b.Blocked.AvatarUrl,
                     CoverPhotoUrl = b.Blocked.CoverPhotoUrl,
                     IsEmailVerified = b.Blocked.IsEmailVerified,
                     CreatedAt = b.Blocked.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<UserDto>>.Success(blocked);
        }

        public async Task<Response<PrivacySettingDto>> GetPrivacySettingsAsync(int userId)
        {
             var settings = await _privacyRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(p => p.UserId == userId);
             
             if(settings == null)
             {
                 settings = new PrivacySetting { UserId = userId };
                 await _privacyRepository.AddAsync(settings);
                 await _unitOfWork.CompleteAsync();
             }
             
             return Response<PrivacySettingDto>.Success(settings.Adapt<PrivacySettingDto>());
        }

        public async Task<Response<string>> UnblockUserAsync(int userId, int unblockUserId)
        {
             var existing = await _blockedRepository.GetTableAsTracking()
                 .FirstOrDefaultAsync(b => b.UserId == userId && b.BlockedUserId == unblockUserId);
             
             if(existing == null) return Response<string>.Failure("Not blocked");

             await _blockedRepository.DeleteAsync(existing);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Unblocked");
        }

        public async Task<Response<PrivacySettingDto>> UpdatePrivacySettingsAsync(int userId, UpdatePrivacySettingsRequest request)
        {
             var settings = await _privacyRepository.GetTableAsTracking()
                 .FirstOrDefaultAsync(p => p.UserId == userId);
             
             if(settings == null)
             {
                 settings = new PrivacySetting { UserId = userId };
                 await _privacyRepository.AddAsync(settings);
             }

             // Map request to settings
             // Assuming request has same properties as entity/DTO or subset
             request.Adapt(settings);
             
             await _privacyRepository.UpdateAsync(settings);
             await _unitOfWork.CompleteAsync();
             return Response<PrivacySettingDto>.Success(settings.Adapt<PrivacySettingDto>());
        }
    }
}
