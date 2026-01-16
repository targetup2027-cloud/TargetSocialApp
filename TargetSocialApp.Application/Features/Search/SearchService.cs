using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
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

        public async Task<Response<List<Post>>> GetPostsByHashtagAsync(string hashtag)
        {
            // Naive implementation: database LIKE. Better: use a Hashtag entity or dedicated search engine.
            var posts = await _postRepository.GetTableNoTracking()
                .Where(p => p.Content.Contains($"#{hashtag}"))
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
            return Response<List<Post>>.Success(posts);
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
             // Mock
             return Response<List<string>>.Success(new List<string> { "#trend1", "#target", "#social" });
        }

        public async Task<Response<List<Post>>> GetTrendingPostsAsync()
        {
             var posts = await _postRepository.GetTableNoTracking()
                 .OrderByDescending(p => p.Reactions.Count) // Sort by popularity
                 .Take(10)
                 .ToListAsync();
             return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<object>> SearchGeneralAsync(string query)
        {
             // Combined
             var users = await SearchUsersAsync(query);
             var posts = await SearchPostsAsync(query);
             
             return Response<object>.Success(new 
             {
                 Users = users.Data,
                 Posts = posts.Data
             });
        }

        public async Task<Response<List<string>>> SearchHashtagsAsync(string query)
        {
            // Mock
            return Response<List<string>>.Success(new List<string> { $"#{query}", $"#{query}2" });
        }

        public async Task<Response<List<Post>>> SearchPostsAsync(string query)
        {
             var posts = await _postRepository.GetTableNoTracking()
                 .Where(p => p.Content.Contains(query))
                 .ToListAsync();
             return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<List<User>>> SearchUsersAsync(string query)
        {
             var users = await _userRepository.GetTableNoTracking()
                 .Where(u => u.FirstName.Contains(query) || u.LastName.Contains(query) || u.Email.Contains(query))
                 .ToListAsync();
             return Response<List<User>>.Success(users);
        }
    }
}
