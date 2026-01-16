using Microsoft.Extensions.DependencyInjection;
using System.Reflection;
using FluentValidation;
using Mapster;
using TargetSocialApp.Application.Features.Auth;
using TargetSocialApp.Application.Features.Users;
using TargetSocialApp.Application.Features.Posts;
using TargetSocialApp.Application.Features.Comments;
using TargetSocialApp.Application.Features.Friends;
using TargetSocialApp.Application.Features.Stories;
using TargetSocialApp.Application.Features.Messaging;
using TargetSocialApp.Application.Features.Notifications;
using TargetSocialApp.Application.Features.Search;
using TargetSocialApp.Application.Features.Media;
using TargetSocialApp.Application.Features.Privacy;

namespace TargetSocialApp.Application
{
    public static class ModuleServiceDependencies
    {
        public static IServiceCollection AddApplicationDependencies(this IServiceCollection services)
        {
            // Register Services
            services.AddTransient<IAuthService, AuthService>();
            services.AddTransient<IUserService, UserService>();
            services.AddTransient<IPostService, PostService>();
            services.AddTransient<ICommentService, CommentService>();
            services.AddTransient<IFriendService, FriendService>();
            services.AddTransient<IStoryService, StoryService>();
            services.AddTransient<IMessagingService, MessagingService>();
            services.AddTransient<INotificationService, NotificationService>();
            services.AddTransient<ISearchService, SearchService>();
            services.AddTransient<IMediaService, MediaService>();
            services.AddTransient<IPrivacyService, PrivacyService>();

            // Register Validators
            services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

            // Register Mapster
            var config = TypeAdapterConfig.GlobalSettings;
            config.Scan(Assembly.GetExecutingAssembly());
            services.AddSingleton(config);

            return services;
        }
    }
}
