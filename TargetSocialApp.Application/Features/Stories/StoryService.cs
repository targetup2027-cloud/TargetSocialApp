using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Stories.Requests;
using TargetSocialApp.Application.Features.Stories.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Stories
{
    public class StoryService : AppService, IStoryService
    {
        private readonly IGenericRepository<Story> _storyRepository;
        private readonly IGenericRepository<StoryView> _viewRepository;
        private readonly IGenericRepository<StoryHighlight> _highlightRepository;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IUnitOfWork _unitOfWork;

        public StoryService(
            IGenericRepository<Story> storyRepository,
            IGenericRepository<StoryView> viewRepository,
            IGenericRepository<StoryHighlight> highlightRepository,
            IGenericRepository<User> userRepository,
            IUnitOfWork unitOfWork)
        {
            _storyRepository = storyRepository;
            _viewRepository = viewRepository;
            _highlightRepository = highlightRepository;
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<StoryHighlightDto>> CreateHighlightAsync(int userId, CreateHighlightRequest request)
        {
            var coverUrl = await UploadImageAsync(request.CoverImage, "highlights");
            
            var highlight = new StoryHighlight
            {
                UserId = userId,
                Title = request.Title,
                CoverImageUrl = coverUrl,
                CreatedAt = DateTime.UtcNow
            };

            int order = 1;
            foreach (var storyId in request.StoryIds)
            {
                highlight.Items.Add(new StoryHighlightItem { StoryId = storyId, Order = order++ });
            }

            await _highlightRepository.AddAsync(highlight);
            await _unitOfWork.CompleteAsync();

            // Return DTO... assuming empty stories list for now as we just created it and maybe didn't load them.
            // Or ideally fetch them.
            return Response<StoryHighlightDto>.Success(new StoryHighlightDto 
            {
                Id = highlight.Id,
                UserId = highlight.UserId,
                Title = highlight.Title,
                CoverImageUrl = highlight.CoverImageUrl,
                Stories = new List<StoryDto>() // Placeholder
            });
        }

        public async Task<Response<StoryHighlightDto>> UpdateHighlightAsync(int userId, int highlightId, CreateHighlightRequest request)
        {
            var highlight = await _highlightRepository.GetTableAsTracking()
                .Include(h => h.Items)
                .FirstOrDefaultAsync(h => h.Id == highlightId);
            if(highlight == null) return Response<StoryHighlightDto>.Failure("Not found");
            if(highlight.UserId != userId) return Response<StoryHighlightDto>.Failure("Unauthorized");

            highlight.Title = request.Title;
            if(request.CoverImage != null)
            {
                highlight.CoverImageUrl = await UploadImageAsync(request.CoverImage, "highlights");
            }
            
            highlight.Items.Clear();
            int order = 1;
            foreach(var sid in request.StoryIds)
            {
                 highlight.Items.Add(new StoryHighlightItem { StoryId = sid, Order = order++ });
            }

            await _highlightRepository.UpdateAsync(highlight);
            await _unitOfWork.CompleteAsync();

            return Response<StoryHighlightDto>.Success(new StoryHighlightDto
            {
                Id = highlight.Id,
                UserId = highlight.UserId,
                Title = highlight.Title,
                CoverImageUrl = highlight.CoverImageUrl
            });
        }

        public async Task<Response<StoryDto>> CreateStoryAsync(int userId, CreateStoryRequest request)
        {
            var url = await UploadImageAsync(request.File, "stories");
            
            var story = new Story
            {
                UserId = userId,
                MediaUrl = url,
                MediaType = request.MediaType,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddHours(24)
            };

            await _storyRepository.AddAsync(story);
            await _unitOfWork.CompleteAsync();

            var user = await _userRepository.GetByIdAsync(userId);

            var dto = new StoryDto
            {
                Id = story.Id,
                UserId = story.UserId,
                UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                UserAvatarUrl = user?.AvatarUrl,
                MediaUrl = story.MediaUrl,
                MediaType = story.MediaType,
                CreatedAt = story.CreatedAt,
                ExpiresAt = story.ExpiresAt,
                ViewsCount = 0,
                IsViewedByCurrentUser = false
            };

            return Response<StoryDto>.Success(dto);
        }

        public async Task<Response<string>> DeleteHighlightAsync(int userId, int highlightId)
        {
             var highlight = await _highlightRepository.GetByIdAsync(highlightId);
             if (highlight == null) return Response<string>.Failure("Highlight not found");
             if (highlight.UserId != userId) return Response<string>.Failure("Unauthorized");

             await _highlightRepository.DeleteAsync(highlight);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Highlight deleted");
        }

        public async Task<Response<string>> DeleteStoryAsync(int userId, int storyId)
        {
             var story = await _storyRepository.GetByIdAsync(storyId);
             if (story == null) return Response<string>.Failure("Story not found");
             if (story.UserId != userId) return Response<string>.Failure("Unauthorized");

             await _storyRepository.DeleteAsync(story);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Story deleted");
        }

        public async Task<Response<List<StoryDto>>> GetFriendsStoriesAsync(int userId)
        {
             var stories = await _storyRepository.GetTableNoTracking()
                 .Where(s => s.ExpiresAt > DateTime.UtcNow)
                 .OrderBy(s => s.CreatedAt)
                 .Select(s => new StoryDto
                 {
                     Id = s.Id,
                     UserId = s.UserId,
                     UserName = s.User.FirstName + " " + s.User.LastName,
                     UserAvatarUrl = s.User.AvatarUrl,
                     MediaUrl = s.MediaUrl,
                     MediaType = s.MediaType,
                     CreatedAt = s.CreatedAt,
                     ExpiresAt = s.ExpiresAt,
                     ViewsCount = s.Views.Count(),
                     IsViewedByCurrentUser = s.Views.Any(v => v.ViewerId == userId) // Assumes userId available in scope - wait, userId is arg
                 })
                 .ToListAsync();
             
             // Note: In Select(Expression), passed arguments (userId) are captured in closure and work fine in EF Core.
             
             return Response<List<StoryDto>>.Success(stories);
        }

        public async Task<Response<StoryDto>> GetStoryByIdAsync(int storyId)
        {
             var story = await _storyRepository.GetTableNoTracking()
                 .Where(s => s.Id == storyId)
                 .Select(s => new StoryDto
                 {
                     Id = s.Id,
                     UserId = s.UserId,
                     UserName = s.User.FirstName + " " + s.User.LastName,
                     UserAvatarUrl = s.User.AvatarUrl,
                     MediaUrl = s.MediaUrl,
                     MediaType = s.MediaType,
                     CreatedAt = s.CreatedAt,
                     ExpiresAt = s.ExpiresAt,
                     ViewsCount = s.Views.Count(),
                     IsViewedByCurrentUser = false // Don't have viewer ID here?
                 })
                 .FirstOrDefaultAsync();

             if (story == null) return Response<StoryDto>.Failure("Story not found");
             return Response<StoryDto>.Success(story);
        }

        public async Task<Response<List<UserDto>>> GetStoryViewersAsync(int userId, int storyId)
        {
             var story = await _storyRepository.GetTableNoTracking().FirstOrDefaultAsync(s => s.Id == storyId);
             if (story == null) return Response<List<UserDto>>.Failure("Story not found");
             if (story.UserId != userId) return Response<List<UserDto>>.Failure("Unauthorized");

             var viewers = await _viewRepository.GetTableNoTracking()
                 .Where(v => v.StoryId == storyId)
                 .Select(v => new UserDto
                 {
                     Id = v.Viewer.Id,
                     FirstName = v.Viewer.FirstName,
                     LastName = v.Viewer.LastName,
                     Email = v.Viewer.Email,
                     PhoneNumber = v.Viewer.PhoneNumber,
                     Bio = v.Viewer.Bio,
                     AvatarUrl = v.Viewer.AvatarUrl,
                     CoverPhotoUrl = v.Viewer.CoverPhotoUrl,
                     IsEmailVerified = v.Viewer.IsEmailVerified,
                     CreatedAt = v.Viewer.CreatedAt
                 })
                 .ToListAsync();
             
             return Response<List<UserDto>>.Success(viewers);
        }

        public async Task<Response<List<StoryHighlightDto>>> GetUserHighlightsAsync(int userId)
        {
             var highlights = await _highlightRepository.GetTableNoTracking()
                 .Where(h => h.UserId == userId)
                 .Select(h => new StoryHighlightDto
                 {
                     Id = h.Id,
                     UserId = h.UserId,
                     Title = h.Title,
                     CoverImageUrl = h.CoverImageUrl,
                     Stories = h.Items.OrderBy(i => i.Order).Select(i => new StoryDto
                     {
                         Id = i.Story.Id,
                         UserId = i.Story.UserId,
                         UserName = i.Story.User.FirstName + " " + i.Story.User.LastName,
                         UserAvatarUrl = i.Story.User.AvatarUrl,
                         MediaUrl = i.Story.MediaUrl,
                         MediaType = i.Story.MediaType,
                         CreatedAt = i.Story.CreatedAt,
                         ExpiresAt = i.Story.ExpiresAt,
                         ViewsCount = i.Story.Views.Count(),
                         IsViewedByCurrentUser = false
                     }).ToList()
                 })
                 .ToListAsync();
             return Response<List<StoryHighlightDto>>.Success(highlights);
        }

        public async Task<Response<string>> ViewStoryAsync(int userId, int storyId)
        {
             var exists = await _viewRepository.GetTableNoTracking()
                 .AnyAsync(v => v.StoryId == storyId && v.ViewerId == userId);
             
             if(exists) return Response<string>.Success("Already viewed");

             await _viewRepository.AddAsync(new StoryView
             {
                 StoryId = storyId,
                 ViewerId = userId,
                 ViewedAt = DateTime.UtcNow
             });
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Viewed");
        }
    }
}
