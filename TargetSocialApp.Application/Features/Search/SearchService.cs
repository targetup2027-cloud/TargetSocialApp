using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Posts.DTOs;
using TargetSocialApp.Application.Features.Search.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Search
{
    public class SearchService : AppService, ISearchService
    {
        private readonly IGenericRepository<User> _userRepository;
        private readonly IGenericRepository<Post> _postRepository;

        public SearchService(
            IGenericRepository<User> userRepository,
            IGenericRepository<Post> postRepository)
        {
            _userRepository = userRepository;
            _postRepository = postRepository;
        }

        public async Task<Response<List<PostDto>>> GetPostsByHashtagAsync(string hashtag)
        {
            var posts = await _postRepository.GetTableNoTracking()
                .Where(p => p.Content.Contains($"#{hashtag}"))
                .OrderByDescending(p => p.CreatedAt)
                .Select(p => new PostDto
                {
                    Id = p.Id,
                    UserId = p.UserId,
                    UserName = p.User.FirstName + " " + p.User.LastName,
                    UserAvatarUrl = p.User.AvatarUrl,
                    Content = p.Content,
                    Privacy = p.Privacy,
                    CreatedAt = p.CreatedAt,
                    Media = p.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                    ReactionsCount = p.Reactions.Count(),
                    CommentsCount = p.Comments.Count(),
                    IsLikedByCurrentUser = false,
                    IsSavedByCurrentUser = false
                })
                .ToListAsync();
            return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<List<string>>> GetSuggestionsAsync(string query)
        {
            var users = await _userRepository.GetTableNoTracking()
                .Where(u => u.FirstName.Contains(query) || u.LastName.Contains(query))
                .Take(5)
                .Select(u => $"{u.FirstName} {u.LastName}")
                .ToListAsync();
            
            return Response<List<string>>.Success(users);
        }

        public async Task<Response<List<string>>> GetTrendingHashtagsAsync()
        {
             return Response<List<string>>.Success(new List<string> { "#trend1", "#target", "#social" });
        }

        public async Task<Response<List<PostDto>>> GetTrendingPostsAsync()
        {
             var posts = await _postRepository.GetTableNoTracking()
                 .OrderByDescending(p => p.Reactions.Count) 
                 .Take(10)
                 .Select(p => new PostDto
                 {
                     Id = p.Id,
                     UserId = p.UserId,
                     UserName = p.User.FirstName + " " + p.User.LastName,
                     UserAvatarUrl = p.User.AvatarUrl,
                     Content = p.Content,
                     Privacy = p.Privacy,
                     CreatedAt = p.CreatedAt,
                     Media = p.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                     ReactionsCount = p.Reactions.Count(),
                     CommentsCount = p.Comments.Count(),
                     IsLikedByCurrentUser = false,
                     IsSavedByCurrentUser = false
                 })
                 .ToListAsync();
             return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<SearchDto>> SearchGeneralAsync(string query)
        {
             var users = await SearchUsersAsync(query);
             var posts = await SearchPostsAsync(query);
             
             return Response<SearchDto>.Success(new SearchDto
             {
                 Users = users.Data,
                 Posts = posts.Data
             });
        }

        public async Task<Response<List<string>>> SearchHashtagsAsync(string query)
        {
            return Response<List<string>>.Success(new List<string> { $"#{query}", $"#{query}2" });
        }

        public async Task<Response<List<PostDto>>> SearchPostsAsync(string query)
        {
             var posts = await _postRepository.GetTableNoTracking()
                 .Where(p => p.Content.Contains(query))
                 .Select(p => new PostDto
                 {
                     Id = p.Id,
                     UserId = p.UserId,
                     UserName = p.User.FirstName + " " + p.User.LastName,
                     UserAvatarUrl = p.User.AvatarUrl,
                     Content = p.Content,
                     Privacy = p.Privacy,
                     CreatedAt = p.CreatedAt,
                     Media = p.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                     ReactionsCount = p.Reactions.Count(),
                     CommentsCount = p.Comments.Count(),
                     IsLikedByCurrentUser = false,
                     IsSavedByCurrentUser = false
                 })
                 .ToListAsync();
             return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<List<UserDto>>> SearchUsersAsync(string query)
        {
             var users = await _userRepository.GetTableNoTracking()
                 .Where(u => u.FirstName.Contains(query) || u.LastName.Contains(query) || u.Email.Contains(query))
                 .Select(u => new UserDto
                 {
                     Id = u.Id,
                     FirstName = u.FirstName,
                     LastName = u.LastName,
                     Email = u.Email,
                     PhoneNumber = u.PhoneNumber,
                     Bio = u.Bio,
                     AvatarUrl = u.AvatarUrl,
                     CoverPhotoUrl = u.CoverPhotoUrl,
                     IsEmailVerified = u.IsEmailVerified,
                     CreatedAt = u.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<UserDto>>.Success(users);
        }
    }
}
