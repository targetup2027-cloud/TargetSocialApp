using System.Collections.Generic;
using TargetSocialApp.Application.Features.Posts.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;

namespace TargetSocialApp.Application.Features.Search.DTOs
{
    public class SearchDto
    {
        public List<UserDto> Users { get; set; } = new();
        public List<PostDto> Posts { get; set; } = new();
    }
}
