using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mapster;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Privacy.Requests;
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
             // if (!VerifyHash(request.OldPassword, user.PasswordHash)) return Failure...
             // user.PasswordHash = Hash(request.NewPassword);
             // Stub
             return Response<string>.Success("Password changed (Stub)");
        }

        public async Task<Response<string>> Enable2FAAsync(int userId)
        {
             return Response<string>.Success("2FA Enabled (Stub)");
        }

        public async Task<Response<List<User>>> GetBlockedUsersAsync(int userId)
        {
             var blocked = await _blockedRepository.GetTableNoTracking()
                 .Where(b => b.UserId == userId)
                 .Include(b => b.Blocked)
                 .Select(b => b.Blocked)
                 .ToListAsync();
             return Response<List<User>>.Success(blocked);
        }

        public async Task<Response<PrivacySetting>> GetPrivacySettingsAsync(int userId)
        {
             var settings = await _privacyRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(p => p.UserId == userId);
             
             if(settings == null)
             {
                 settings = new PrivacySetting { UserId = userId };
                 await _privacyRepository.AddAsync(settings);
                 await _unitOfWork.CompleteAsync();
             }
             return Response<PrivacySetting>.Success(settings);
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

        public async Task<Response<PrivacySetting>> UpdatePrivacySettingsAsync(int userId, UpdatePrivacySettingsRequest request)
        {
             var settings = await _privacyRepository.GetTableAsTracking()
                 .FirstOrDefaultAsync(p => p.UserId == userId);
             
             if(settings == null)
             {
                 settings = new PrivacySetting { UserId = userId };
                 await _privacyRepository.AddAsync(settings);
             }

             // Map request to settings
             settings.ProfileVisibility = request.ProfileVisibility;
             
             await _privacyRepository.UpdateAsync(settings);
             await _unitOfWork.CompleteAsync();
             return Response<PrivacySetting>.Success(settings);
        }
    }
}
