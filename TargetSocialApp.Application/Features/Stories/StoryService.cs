using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Stories.Requests;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Stories
{
    public class StoryService : AppService, IStoryService
    {
        private readonly IGenericRepository<Story> _storyRepository;
        private readonly IGenericRepository<StoryView> _viewRepository;
        private readonly IGenericRepository<StoryHighlight> _highlightRepository;
        private readonly IUnitOfWork _unitOfWork;

        public StoryService(
            IGenericRepository<Story> storyRepository,
            IGenericRepository<StoryView> viewRepository,
            IGenericRepository<StoryHighlight> highlightRepository,
            IUnitOfWork unitOfWork)
        {
            _storyRepository = storyRepository;
            _viewRepository = viewRepository;
            _highlightRepository = highlightRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<StoryHighlight>> CreateHighlightAsync(int userId, CreateHighlightRequest request)
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
            return Response<StoryHighlight>.Success(highlight);
        }

        public async Task<Response<StoryHighlight>> UpdateHighlightAsync(int userId, int highlightId, CreateHighlightRequest request)
        {
            var highlight = await _highlightRepository.GetByIdAsync(highlightId);
            if(highlight == null) return Response<StoryHighlight>.Failure("Not found");
            if(highlight.UserId != userId) return Response<StoryHighlight>.Failure("Unauthorized");

            highlight.Title = request.Title;
            if(request.CoverImage != null)
            {
                highlight.CoverImageUrl = await UploadImageAsync(request.CoverImage, "highlights");
            }
            // Update items typically involves clearing and re-adding or smart merge.
            // Simplified: Clear and add
            highlight.Items.Clear();
            int order = 1;
            foreach(var sid in request.StoryIds)
            {
                 highlight.Items.Add(new StoryHighlightItem { StoryId = sid, Order = order++ });
            }

            await _highlightRepository.UpdateAsync(highlight);
            await _unitOfWork.CompleteAsync();
            return Response<StoryHighlight>.Success(highlight);
        }

        public async Task<Response<Story>> CreateStoryAsync(int userId, CreateStoryRequest request)
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
            return Response<Story>.Success(story);
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

        public async Task<Response<List<Story>>> GetFriendsStoriesAsync(int userId)
        {
             // Simplified: Get all active stories from DB (would filter by friends in real app)
             // Using simple Expire check
             var stories = await _storyRepository.GetTableNoTracking()
                 .Where(s => s.ExpiresAt > DateTime.UtcNow)
                 .Include(s => s.User)
                 .OrderBy(s => s.CreatedAt)
                 .ToListAsync();
             
             return Response<List<Story>>.Success(stories);
        }

        public async Task<Response<Story>> GetStoryByIdAsync(int storyId)
        {
             var story = await _storyRepository.GetByIdAsync(storyId);
             if (story == null) return Response<Story>.Failure("Story not found");
             return Response<Story>.Success(story);
        }

        public async Task<Response<List<User>>> GetStoryViewersAsync(int userId, int storyId)
        {
             var story = await _storyRepository.GetTableNoTracking().FirstOrDefaultAsync(s => s.Id == storyId);
             if (story == null) return Response<List<User>>.Failure("Story not found");
             if (story.UserId != userId) return Response<List<User>>.Failure("Unauthorized");

             var viewers = await _viewRepository.GetTableNoTracking()
                 .Where(v => v.StoryId == storyId)
                 .Include(v => v.Viewer)
                 .Select(v => v.Viewer)
                 .ToListAsync();
             
             return Response<List<User>>.Success(viewers);
        }

        public async Task<Response<List<StoryHighlight>>> GetUserHighlightsAsync(int userId)
        {
             var highlights = await _highlightRepository.GetTableNoTracking()
                 .Where(h => h.UserId == userId)
                 .ToListAsync();
             return Response<List<StoryHighlight>>.Success(highlights);
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
