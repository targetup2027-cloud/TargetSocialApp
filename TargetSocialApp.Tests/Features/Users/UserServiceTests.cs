using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Users;
using TargetSocialApp.Application.Features.Users.Requests;
using TargetSocialApp.Domain.Entities;
using Xunit;

namespace TargetSocialApp.Tests.Features.Users
{
    public class UserServiceTests
    {
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly Mock<IFileService> _mockFileService;
        private readonly UserService _userService;

        public UserServiceTests()
        {
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();
            _mockFileService = new Mock<IFileService>();
            
            _userService = new UserService(_mockUserRepository.Object, _mockUnitOfWork.Object, _mockFileService.Object);
        }

        [Fact]
        public async Task GetUserById_ShouldReturnUser_WhenUserExists()
        {
            // Arrange
            var user = new User { Id = 1, FirstName = "John", LastName = "Doe", Email = "john@example.com" };
            _mockUserRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync(user);

            // Act
            var result = await _userService.GetUserByIdAsync(1);

            // Assert
            result.Succeeded.Should().BeTrue();
            result.Data.FirstName.Should().Be("John");
            result.Data.Email.Should().Be("john@example.com");
        }

        [Fact]
        public async Task GetUserById_ShouldReturnFailure_WhenUserDoesNotExist()
        {
            // Arrange
            _mockUserRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync((User)null);

            // Act
            var result = await _userService.GetUserByIdAsync(1);

            // Assert
            result.Succeeded.Should().BeFalse();
            result.Message.Should().Be("User not found");
        }

        [Fact]
        public async Task UpdateProfile_ShouldUpdateUser_WhenUserExists()
        {
            // Arrange
            var user = new User { Id = 1, FirstName = "Old", LastName = "Name", Bio = "Old Bio" };
            var request = new UpdateProfileRequest { FirstName = "New", LastName = "Name", Bio = "New Bio" };
            
            _mockUserRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync(user);

            // Act
            var result = await _userService.UpdateProfileAsync(1, request);

            // Assert
            result.Succeeded.Should().BeTrue();
            result.Data.FirstName.Should().Be("New");
            result.Data.Bio.Should().Be("New Bio");
            
            _mockUserRepository.Verify(x => x.UpdateAsync(It.Is<User>(u => u.FirstName == "New")), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        [Fact]
        public async Task UpdateAvatar_ShouldUploadFileAndUpdateUrl_WhenUserExists()
        {
            // Arrange
            var user = new User { Id = 1 };
            var fileMock = new Mock<IFormFile>();
            var request = new UpdateAvatarRequest { File = fileMock.Object };
            
            _mockUserRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync(user);
            _mockFileService.Setup(x => x.UploadFileAsync(request.File, "avatars")).ReturnsAsync("/avatars/new.jpg");

            // Act
            var result = await _userService.UpdateAvatarAsync(1, request);

            // Assert
            result.Succeeded.Should().BeTrue();
            result.Data.Should().Be("/avatars/new.jpg");
            user.AvatarUrl.Should().Be("/avatars/new.jpg");
            
            _mockUserRepository.Verify(x => x.UpdateAsync(user), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        [Fact]
        public async Task DeleteAvatar_ShouldRemoveUrlAndFile_WhenUserExists()
        {
            // Arrange
            var user = new User { Id = 1, AvatarUrl = "/avatars/old.jpg" };
            _mockUserRepository.Setup(x => x.GetByIdAsync(1)).ReturnsAsync(user);

            // Act
            var result = await _userService.DeleteAvatarAsync(1);

            // Assert
            result.Succeeded.Should().BeTrue();
            user.AvatarUrl.Should().BeNull();
            
            _mockFileService.Verify(x => x.DeleteFileAsync("/avatars/old.jpg"), Times.Once);
            _mockUserRepository.Verify(x => x.UpdateAsync(user), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }
    }
}
