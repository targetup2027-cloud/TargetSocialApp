using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Posts;
using TargetSocialApp.Application.Features.Posts.Requests;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;
using TargetSocialApp.Domain.Common;
using Xunit;

namespace TargetSocialApp.Tests.Features.Posts
{
    public class PostServiceTests : IDisposable
    {
        private readonly Mock<IGenericRepository<Post>> _mockPostRepository;
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IGenericRepository<PostReaction>> _mockReactionRepository;
        private readonly Mock<IGenericRepository<SavedPost>> _mockSavedPostRepository;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly Mock<IFileService> _mockFileService;
        
        private readonly DbContext _dbContext;
        private readonly PostService _postService;

        public PostServiceTests()
        {
            _mockPostRepository = new Mock<IGenericRepository<Post>>();
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockReactionRepository = new Mock<IGenericRepository<PostReaction>>();
            _mockSavedPostRepository = new Mock<IGenericRepository<SavedPost>>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();
            _mockFileService = new Mock<IFileService>();

            var options = new DbContextOptionsBuilder<PostTestDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            _dbContext = new PostTestDbContext(options);

            SetupRepositoryMock(_mockPostRepository);
            SetupRepositoryMock(_mockUserRepository);
            SetupRepositoryMock(_mockReactionRepository);
            SetupRepositoryMock(_mockSavedPostRepository);

            _postService = new PostService(
                _mockPostRepository.Object,
                _mockUserRepository.Object,
                _mockReactionRepository.Object,
                _mockSavedPostRepository.Object,
                _mockUnitOfWork.Object,
                _mockFileService.Object
            );
        }

        private void SetupRepositoryMock<T>(Mock<IGenericRepository<T>> mockRepo) where T : BaseEntity
        {
            mockRepo.Setup(x => x.GetTableNoTracking()).Returns(() => _dbContext.Set<T>().AsNoTracking());
            mockRepo.Setup(x => x.GetTableAsTracking()).Returns(() => _dbContext.Set<T>());
            
            mockRepo.Setup(x => x.AddAsync(It.IsAny<T>())).Returns(async (T entity) => {
                _dbContext.Set<T>().Add(entity);
                await _dbContext.SaveChangesAsync();
                _dbContext.ChangeTracker.Clear();
                return entity;
            });
            mockRepo.Setup(x => x.UpdateAsync(It.IsAny<T>())).Returns(async (T entity) => {
                _dbContext.Set<T>().Update(entity);
                await _dbContext.SaveChangesAsync();
                _dbContext.ChangeTracker.Clear();
            });
            mockRepo.Setup(x => x.DeleteAsync(It.IsAny<T>())).Returns(async (T entity) => {
                _dbContext.Set<T>().Remove(entity);
                await _dbContext.SaveChangesAsync();
                _dbContext.ChangeTracker.Clear();
            });
            mockRepo.Setup(x => x.GetByIdAsync(It.IsAny<int>())).ReturnsAsync((int id) => _dbContext.Set<T>().Find(id));
        }

        public void Dispose()
        {
            _dbContext.Dispose();
        }

        private void SeedData()
        {
            var user = new User 
            { 
                Id = 1, 
                FirstName = "Test", 
                LastName = "User", 
                Email = "test@example.com", 
                PasswordHash = "hash", 
                AvatarUrl = "avatar.jpg" 
            };
            var post = new Post { Id = 1, UserId = 1, User = user, Content = "Content", Privacy = PrivacyLevel.Public, CreatedAt = DateTime.UtcNow };

            _dbContext.Set<User>().Add(user);
            _dbContext.Set<Post>().Add(post);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();
        }

        [Fact]
        public async Task CreatePost_ShouldReturnSuccess_WhenValid()
        {
            SeedData();
            var request = new CreatePostRequest { Content = "New Post", Privacy = PrivacyLevel.Public };

            var result = await _postService.CreatePostAsync(1, request);

            result.Succeeded.Should().BeTrue();
            result.Data.Content.Should().Be("New Post");
            _mockPostRepository.Verify(x => x.AddAsync(It.IsAny<Post>()), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        [Fact]
        public async Task GetFeed_ShouldReturnPosts()
        {
            SeedData();
            var result = await _postService.GetFeedAsync(1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().NotBeEmpty();
            result.Data.First().Content.Should().Be("Content");
        }

        [Fact]
        public async Task LikePost_ShouldAddReaction_WhenNotLiked()
        {
            SeedData();
            // Ensure no existing reaction
            
            var result = await _postService.LikePostAsync(1, 1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Liked");
            _mockReactionRepository.Verify(x => x.AddAsync(It.Is<PostReaction>(r => r.ReactionType == ReactionType.Like)), Times.Once);
        }

        [Fact]
        public async Task LikePost_ShouldRemoveReaction_WhenAlreadyLiked()
        {
            SeedData();
            var reaction = new PostReaction { UserId = 1, PostId = 1, ReactionType = ReactionType.Like };
            _dbContext.Set<PostReaction>().Add(reaction);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();

            var result = await _postService.LikePostAsync(1, 1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Unliked");
            _mockReactionRepository.Verify(x => x.DeleteAsync(It.IsAny<PostReaction>()), Times.Once);
        }

        [Fact]
        public async Task UploadMedia_ShouldCallFileService()
        {
            var fileMock = new Mock<IFormFile>();
            var request = new UploadPostMediaRequest { File = fileMock.Object };
            _mockFileService.Setup(x => x.UploadFileAsync(It.IsAny<IFormFile>(), "posts")).ReturnsAsync("url");

            var result = await _postService.UploadMediaAsync(request);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("url");
        }
    }
    
    public class PostTestDbContext : DbContext
    {
        public PostTestDbContext(DbContextOptions options) : base(options) { }
        public DbSet<User> Users { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<PostReaction> Reactions { get; set; }
        public DbSet<SavedPost> SavedPosts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().Ignore(u => u.SentFriendRequests);
            modelBuilder.Entity<User>().Ignore(u => u.ReceivedFriendRequests);
            modelBuilder.Entity<User>().Ignore(u => u.Stories);
            modelBuilder.Entity<User>().Ignore(u => u.UserSessions);
            modelBuilder.Entity<User>().Ignore(u => u.PrivacySetting);
            modelBuilder.Entity<User>().Ignore(u => u.NotificationSetting);
        }
    }
}
