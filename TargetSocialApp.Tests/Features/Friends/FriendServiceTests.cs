using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Friends;
using TargetSocialApp.Application.Features.Friends.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;
using Xunit;

namespace TargetSocialApp.Tests.Features.Friends
{
    public class FriendServiceTests : IDisposable
    {
        private readonly Mock<IGenericRepository<Friendship>> _mockFriendshipRepository;
        private readonly Mock<IGenericRepository<Following>> _mockFollowingRepository;
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;

        private readonly FriendTestDbContext _dbContext;
        private readonly FriendService _friendService;

        public FriendServiceTests()
        {
            _mockFriendshipRepository = new Mock<IGenericRepository<Friendship>>();
            _mockFollowingRepository = new Mock<IGenericRepository<Following>>();
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();

            var options = new DbContextOptionsBuilder<FriendTestDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            _dbContext = new FriendTestDbContext(options);

            SetupRepositoryMock(_mockFriendshipRepository);
            SetupRepositoryMock(_mockFollowingRepository);
            SetupRepositoryMock(_mockUserRepository);

            _friendService = new FriendService(
                _mockFriendshipRepository.Object,
                _mockFollowingRepository.Object,
                _mockUserRepository.Object,
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
            var user1 = new User { Id = 1, FirstName = "User", LastName = "One", Email = "one@example.com", PasswordHash = "hash" };
            var user2 = new User { Id = 2, FirstName = "User", LastName = "Two", Email = "two@example.com", PasswordHash = "hash" };
            var user3 = new User { Id = 3, FirstName = "User", LastName = "Three", Email = "three@example.com", PasswordHash = "hash" };

            _dbContext.Users.AddRange(user1, user2, user3);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();
        }

        [Fact]
        public async Task SendFriendRequest_ShouldCreateRequest_WhenValid()
        {
            SeedData();
            var result = await _friendService.SendFriendRequestAsync(1, 2);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Friend request sent");
            
            var request = await _dbContext.Friendships.FirstOrDefaultAsync();
            request.Should().NotBeNull();
            request.RequesterId.Should().Be(1);
            request.ReceiverId.Should().Be(2);
            request.Status.Should().Be(FriendshipStatus.Pending);
        }

        [Fact]
        public async Task AcceptFriendRequest_ShouldUpdateStatus()
        {
            SeedData();
            var request = new Friendship { Id = 1, RequesterId = 1, ReceiverId = 2, Status = FriendshipStatus.Pending };
            _dbContext.Friendships.Add(request);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();

            var result = await _friendService.AcceptFriendRequestAsync(2, 1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Friend request accepted");

            var updated = await _dbContext.Friendships.FindAsync(1);
            updated.Status.Should().Be(FriendshipStatus.Accepted);
        }

        [Fact]
        public async Task FollowUser_ShouldCreateFollowing()
        {
            SeedData();
            var result = await _friendService.FollowUserAsync(1, 2);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("Followed successfully");

            var following = await _dbContext.Followings.FirstOrDefaultAsync();
            following.Should().NotBeNull();
            following.FollowerId.Should().Be(1);
            following.FollowingId.Should().Be(2);
        }

        [Fact]
        public async Task GetFriendsList_ShouldReturnFriends()
        {
            SeedData();
            // Friendship between 1 and 2 (Accepted)
            var friendship = new Friendship 
            { 
                Id = 1, RequesterId = 1, ReceiverId = 2, Status = FriendshipStatus.Accepted,
                Requester = await _dbContext.Users.FindAsync(1), // Set nav props for projection
                Receiver = await _dbContext.Users.FindAsync(2)
            };
            // Note: In SeedData I attach, here I attach again? No, seed data clears tracker.
            // I need to attach user again or use existing from context if tracked?
            // Since FindAsync tracks it, it's fine.
            
            _dbContext.Friendships.Add(friendship);
            _dbContext.SaveChanges();
            _dbContext.ChangeTracker.Clear();
            
            // Need to set Nav props for GetFriendsList query which selects Receiver/Requester
            // But GetFriendsList implementation uses Select... which might fail if null.
            // But Wait! FriendService.GetFriendsListAsync explicitly handles conditional projection.
            // And EF Core InMemory requires nav properties to be populated.
            // The SeedData+Add above populates them in the instance added to context.
            // But ChangeTracker.Clear() detaches them.
            // When querying back, if included or joined?
            
            // Let's rely on standard behavior.
            
            // To be safe, I should update FriendService.GetFriendsListAsync to Include(f => f.Requester).Include(f => f.Receiver).

            var result = await _friendService.GetFriendsListAsync(1);

            result.Succeeded.Should().BeTrue();
            result.Data.Should().ContainSingle();
            result.Data.First().Id.Should().Be(2);
        }
    }

    public class FriendTestDbContext : DbContext
    {
        public FriendTestDbContext(DbContextOptions options) : base(options) { }
        public DbSet<User> Users { get; set; }
        public DbSet<Friendship> Friendships { get; set; }
        public DbSet<Following> Followings { get; set; }
    }
}
