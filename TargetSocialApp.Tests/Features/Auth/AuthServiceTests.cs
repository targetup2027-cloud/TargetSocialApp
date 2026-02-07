using FluentAssertions;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Moq;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Auth;
using TargetSocialApp.Application.Features.Auth.Requests;
using TargetSocialApp.Application.Features.Auth.Responses;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Common;
using Xunit;

namespace TargetSocialApp.Tests.Features.Auth
{
    public class AuthServiceTests : IDisposable
    {
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IValidator<RegisterRequest>> _mockRegisterValidator;
        private readonly Mock<IValidator<LoginRequest>> _mockLoginValidator;
        private readonly Mock<IConfiguration> _mockConfiguration;
        private readonly Mock<IMemoryCache> _mockCache;
        private readonly Mock<IPasswordHasher> _mockPasswordHasher;
        private readonly Mock<ITokenService> _mockTokenService;
        private readonly Mock<ISmsService> _mockSmsService;
        
        private readonly DbContextOptions<DbContext> _dbOptions; // Assuming DbContext is available or can be mocked via generic DbContextOptions if using generic context
        private readonly DbContext _dbContext; // Need a concrete DbContext to get DbSet from InMemory
        // Wait, TargetSocialApp.Infrastructure usually has ApplicationDbContext.
        // If I don't want to depend on Infrastructure, can passed DbContext work?
        // Actually, just creating a simple DbContext is enough.

        private readonly AuthService _authService;

        public AuthServiceTests()
        {
            _mockUnitOfWork = new Mock<IUnitOfWork>();
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockRegisterValidator = new Mock<IValidator<RegisterRequest>>();
            _mockLoginValidator = new Mock<IValidator<LoginRequest>>();
            _mockConfiguration = new Mock<IConfiguration>();
            _mockCache = new Mock<IMemoryCache>();
            _mockPasswordHasher = new Mock<IPasswordHasher>();
            _mockTokenService = new Mock<ITokenService>();
            _mockSmsService = new Mock<ISmsService>();

            // Setup InMemory DB for async queryable mocking
            // Just use a temporary DbContext to get a DbSet that supports async
            var options = new DbContextOptionsBuilder<AuthTestDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            var context = new AuthTestDbContext(options);
            _dbContext = context;
            _dbContext.ChangeTracker.QueryTrackingBehavior = QueryTrackingBehavior.NoTracking;

            SetupRepositoryMock(_mockUserRepository);

            // Default Setup for validation
            _mockRegisterValidator.SetReturnsDefault(Task.FromResult(new ValidationResult()));
            _mockRegisterValidator.Setup(v => v.ValidateAsync(It.IsAny<IValidationContext>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(new ValidationResult());
            
            _mockLoginValidator.SetReturnsDefault(Task.FromResult(new ValidationResult()));
            _mockLoginValidator.Setup(v => v.ValidateAsync(It.IsAny<IValidationContext>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(new ValidationResult());

            _authService = new AuthService(
                _mockUnitOfWork.Object,
                _mockUserRepository.Object,
                _mockRegisterValidator.Object,
                _mockLoginValidator.Object,
                _mockConfiguration.Object,
                _mockCache.Object,
                _mockPasswordHasher.Object,
                _mockTokenService.Object,
                _mockSmsService.Object
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

        // Helper to setup mock repo with data
        private void SetupRepositoryData(IEnumerable<User> users)
        {
            if (users.Any())
            {
                _dbContext.Set<User>().AddRange(users);
                _dbContext.SaveChanges();
                _dbContext.ChangeTracker.Clear();
            }
        }

        [Fact]
        public async Task Register_ShouldReturnSuccess_WhenRequestIsValid()
        {
            // Arrange
            var request = new RegisterRequest
            {
                Email = "test@example.com",
                Password = "Password123!",
                FirstName = "Test",
                LastName = "User"
            };

            SetupRepositoryData(new List<User>()); // Empty DB
            _mockPasswordHasher.Setup(x => x.HashPassword(request.Password)).Returns("hashed_password");

            // Act
            var response = await _authService.RegisterAsync(request);

            // Assert
            response.Succeeded.Should().BeTrue();
            response.Data.Should().Be("User registered successfully");
            _mockUserRepository.Verify(x => x.AddAsync(It.IsAny<User>()), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        [Fact]
        public async Task Register_ShouldReturnFailure_WhenEmailExists()
        {
            // Arrange
            var request = new RegisterRequest { Email = "existing@example.com", Password = "Password123!" };
            SetupRepositoryData(new List<User> { new User { FirstName = "User", LastName = "One", Email = "existing@example.com", PasswordHash = "hashed" } });

            // Act
            var response = await _authService.RegisterAsync(request);

            // Assert
            response.Succeeded.Should().BeFalse();
            response.Message.Should().Contain("Email already exists");
            _mockUserRepository.Verify(x => x.AddAsync(It.IsAny<User>()), Times.Never);
        }

        [Fact]
        public async Task Login_ShouldReturnSuccess_WhenCredentialsAreValid()
        {
            // Arrange
            var request = new LoginRequest { Email = "test@example.com", Password = "Password123!" };
            var user = new User { Id = 1, FirstName = "Test", LastName = "User", Email = "test@example.com", PasswordHash = "hashed_password" };
            SetupRepositoryData(new List<User> { user });

            _mockPasswordHasher.Setup(x => x.VerifyPassword(request.Password, user.PasswordHash)).Returns(true);
            _mockTokenService.Setup(x => x.GenerateTokensAsync(user)).ReturnsAsync(new AuthResponse { AccessToken = "token", RefreshToken = "refresh" });

            // Act
            var response = await _authService.LoginAsync(request);

            // Assert
            response.Succeeded.Should().BeTrue();
            response.Data.AccessToken.Should().Be("token");
        }

        [Fact]
        public async Task Login_ShouldReturnFailure_WhenUserNotFound()
        {
            // Arrange
            var request = new LoginRequest { Email = "unknown@example.com", Password = "Password123!" };
            SetupRepositoryData(new List<User>());

            // Act
            var response = await _authService.LoginAsync(request);

            // Assert
            response.Succeeded.Should().BeFalse();
            response.Message.Should().Be("Invalid credentials");
        }

        [Fact]
        public async Task Login_ShouldReturnFailure_WhenPasswordIsInvalid()
        {
            // Arrange
            var request = new LoginRequest { Email = "test@example.com", Password = "WrongPassword" };
            var user = new User { FirstName = "Test", LastName = "User", Email = "test@example.com", PasswordHash = "hashed_password" };
            SetupRepositoryData(new List<User> { user });

            _mockPasswordHasher.Setup(x => x.VerifyPassword(request.Password, user.PasswordHash)).Returns(false);

            // Act
            var response = await _authService.LoginAsync(request);

            // Assert
            response.Succeeded.Should().BeFalse();
            response.Message.Should().Be("Invalid credentials");
        }

        [Fact]
        public async Task RequestOtp_ShouldReturnSuccess_WhenNewRequest()
        {
            // Arrange
            var request = new OtpRequest { PhoneNumber = "+1234567890", Channel = "sms" };
            object attemptsObj = null;
            _mockCache.Setup(mc => mc.TryGetValue(It.IsAny<object>(), out attemptsObj)).Returns(false);
            
            var mockCacheEntry = new Mock<ICacheEntry>();
            _mockCache.Setup(mc => mc.CreateEntry(It.IsAny<object>())).Returns(mockCacheEntry.Object);

            _mockSmsService.Setup(x => x.SendVerificationAsync(request.PhoneNumber, request.Channel))
                .ReturnsAsync((true, "pending"));

            // Act
            var response = await _authService.RequestOtpAsync(request);

            // Assert
            response.Succeeded.Should().BeTrue();
            response.Data.Should().Be("pending");
        }

        [Fact]
        public async Task RequestOtp_ShouldReturnFailure_WhenRateLimited()
        {
            // Arrange
            var request = new OtpRequest { PhoneNumber = "+1234567890" };
            object attemptsObj = 3;
            _mockCache.Setup(mc => mc.TryGetValue(It.IsAny<object>(), out attemptsObj)).Returns(true);

            // Act
            var response = await _authService.RequestOtpAsync(request);

            // Assert
            response.Succeeded.Should().BeFalse();
            response.Message.Should().Contain("Too many requests");
            _mockSmsService.Verify(x => x.SendVerificationAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
        }

        [Fact]
        public async Task VerifyOtp_ShouldReturnSuccess_WhenCodeIsValid()
        {
            // Arrange
            var request = new OtpVerifyRequest { PhoneNumber = "+1234567890", Code = "123456" };
            object attemptsObj = null;
            _mockCache.Setup(mc => mc.TryGetValue(It.IsAny<object>(), out attemptsObj)).Returns(false);

            _mockSmsService.Setup(x => x.VerifyCodeAsync(request.PhoneNumber, request.Code))
                .ReturnsAsync((true, "approved"));

            // Act
            var response = await _authService.VerifyOtpAsync(request);

            // Assert
            response.Succeeded.Should().BeTrue();
            response.Data.Should().Contain("Verification successful");
        }

        [Fact]
        public async Task VerifyOtp_ShouldReturnFailure_WhenCodeIsInvalid()
        {
            // Arrange
            var request = new OtpVerifyRequest { PhoneNumber = "+1234567890", Code = "000000" };
            object attemptsObj = null;
            _mockCache.Setup(mc => mc.TryGetValue(It.IsAny<object>(), out attemptsObj)).Returns(false);
            var mockCacheEntry = new Mock<ICacheEntry>();
            _mockCache.Setup(mc => mc.CreateEntry(It.IsAny<object>())).Returns(mockCacheEntry.Object);

            _mockSmsService.Setup(x => x.VerifyCodeAsync(request.PhoneNumber, request.Code))
                .ReturnsAsync((false, "Invalid code"));

            // Act
            var response = await _authService.VerifyOtpAsync(request);

            // Assert
            response.Succeeded.Should().BeFalse();
            response.Message.Should().Be("Invalid code");
        }
    }

    public class AuthTestDbContext : DbContext
    {
        public AuthTestDbContext(DbContextOptions options) : base(options) { }
        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().Ignore(u => u.SentFriendRequests);
            modelBuilder.Entity<User>().Ignore(u => u.ReceivedFriendRequests);
            modelBuilder.Entity<User>().Ignore(u => u.Stories);
            modelBuilder.Entity<User>().Ignore(u => u.UserSessions);
            modelBuilder.Entity<User>().Ignore(u => u.PrivacySetting);
            modelBuilder.Entity<User>().Ignore(u => u.NotificationSetting);
            modelBuilder.Entity<User>().Ignore(u => u.Posts);
            modelBuilder.Entity<User>().Ignore(u => u.Comments);
        }
    }
}
