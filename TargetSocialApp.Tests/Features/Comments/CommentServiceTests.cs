using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Comments;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Application.Features.Comments.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;
using TargetSocialApp.Domain.Common;
using Xunit;

namespace TargetSocialApp.Tests.Features.Comments
{
    public class CommentServiceTests : IDisposable
    {
        private readonly Mock<IGenericRepository<Comment>> _mockCommentRepository;
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IGenericRepository<CommentReaction>> _mockReactionRepository;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        
        private readonly DbContext _dbContext;
        private readonly CommentService _commentService;

        public CommentServiceTests()
        {
            _mockCommentRepository = new Mock<IGenericRepository<Comment>>();
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockReactionRepository = new Mock<IGenericRepository<CommentReaction>>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();

            var options = new DbContextOptionsBuilder<CommentTestDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            _dbContext = new CommentTestDbContext(options);

            SetupRepositoryMock(_mockCommentRepository);
            SetupRepositoryMock(_mockUserRepository);
            SetupRepositoryMock(_mockReactionRepository);

            _commentService = new CommentService(
                _mockCommentRepository.Object,
                _mockUserRepository.Object,
                _mockReactionRepository.Object,
                _mockUnitOfWork.Object
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
            var post = new Post { Id = 1, UserId = 1, User = user, Content = "Post", Privacy = PrivacyLevel.Public, CreatedAt = DateTime.UtcNow };
            var comment = new Comment { Id = 1, PostId = 1, Post = post, UserId = 1, User = user, Content = "Test Comment", CreatedAt = DateTime.UtcNow };

            _dbContext.Set<User>().Add(user);
            _dbContext.Set<Post>().Add(post);
            _dbContext.Set<Comment>().Add(comment);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();
        }

        [Fact]
        public async Task AddComment_ShouldReturnSuccess()
        {
            SeedData();
            var request = new CreateCommentRequest { Content = "New Comment" };

            var result = await _commentService.AddCommentAsync(1, 1, request);

            result.Succeeded.Should().BeTrue();
            result.Data.Content.Should().Be("New Comment");
            _mockCommentRepository.Verify(x => x.AddAsync(It.IsAny<Comment>()), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        [Fact]
        public async Task GetPostComments_ShouldReturnComments()
        {
            SeedData();
            var result = await _commentService.GetPostCommentsAsync(1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().NotBeEmpty();
            result.Data.First().Content.Should().Be("Test Comment");
        }

        [Fact]
        public async Task LikeComment_ShouldToggleReaction()
        {
            SeedData();
            // Like first time
            var result = await _commentService.LikeCommentAsync(1, 1);
            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Liked");
            _mockReactionRepository.Verify(x => x.AddAsync(It.Is<CommentReaction>(r => r.ReactionType == ReactionType.Like)), Times.Once);

            // Seed reaction and test unlike logic (need separate test usually or reset db, but chaining is tricky with InMemory unless explicitly handled)
            // Simulating unlike by adding reaction manually
            var reaction = new CommentReaction { UserId = 1, CommentId = 1, ReactionType = ReactionType.Like };
            _dbContext.Set<CommentReaction>().Add(reaction);
            _dbContext.SaveChanges();

            var result2 = await _commentService.LikeCommentAsync(1, 1);
            result2.Succeeded.Should().BeTrue();
            result2.Data.Should().Be("Unliked");
            _mockReactionRepository.Verify(x => x.DeleteAsync(It.IsAny<CommentReaction>()), Times.Once);
        }

        [Fact]
        public async Task ReplyToComment_ShouldCreateReply()
        {
            SeedData();
            _mockCommentRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync(_dbContext.Set<Comment>().Find(1));

            var request = new CreateCommentRequest { Content = "This is a reply" };
            var result = await _commentService.ReplyToCommentAsync(1, 1, request);

            result.Succeeded.Should().BeTrue();
            result.Data.ParentCommentId.Should().Be(1);
            _mockCommentRepository.Verify(x => x.AddAsync(It.Is<Comment>(c => c.ParentCommentId == 1)), Times.Once);
        }
    }

    public class CommentTestDbContext : DbContext
    {
        public CommentTestDbContext(DbContextOptions options) : base(options) { }
        public DbSet<User> Users { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<CommentReaction> CommentReactions { get; set; }

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