using FluentAssertions;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Moq;
using System.Linq.Expressions;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Auth;
using TargetSocialApp.Application.Features.Auth.Requests;
using TargetSocialApp.Domain.Entities;
using Xunit;

namespace TargetSocialApp.Tests.Features.Auth
{
    public class AuthServiceTests
    {
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly Mock<IGenericRepository<User>> _mockUserRepository;
        private readonly Mock<IValidator<RegisterRequest>> _mockRegisterValidator;
        private readonly Mock<IValidator<LoginRequest>> _mockLoginValidator;
        private readonly Mock<IConfiguration> _mockConfiguration;
        private readonly Mock<IMemoryCache> _mockCache;
        private readonly AuthService _authService;

        public AuthServiceTests()
        {
            _mockUnitOfWork = new Mock<IUnitOfWork>();
            _mockUserRepository = new Mock<IGenericRepository<User>>();
            _mockRegisterValidator = new Mock<IValidator<RegisterRequest>>();
            _mockLoginValidator = new Mock<IValidator<LoginRequest>>();
            _mockConfiguration = new Mock<IConfiguration>();
            _mockCache = new Mock<IMemoryCache>();

            _authService = new AuthService(
                _mockUnitOfWork.Object,
                _mockUserRepository.Object,
                _mockRegisterValidator.Object,
                _mockLoginValidator.Object,
                _mockConfiguration.Object,
                _mockCache.Object
            );
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

            // Validation passes
            // Validation passes (Broad setup to catch extension method wrapping)
            _mockRegisterValidator.SetReturnsDefault(Task.FromResult(new ValidationResult()));
            _mockRegisterValidator
                .Setup(v => v.ValidateAsync(It.IsAny<IValidationContext>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(new ValidationResult());

            // User does not exist (Mocking IQueryable is tricky, assuming InMemory might be better or simple mock if repository returns IQueryable directly)
            // Ideally GenericRepository returns IQueryable which we can mock with a List
            var users = new List<User>().AsQueryable();
            
            // Note: Mocking DbSet extensions like FirstOrDefaultAsync is complex with just Moq.
            // For pure unit testing without EF dependencies, usually we wrap the query logic or use an InMemory DB provider for the repository.
            // However, since the service calls GetTableNoTracking() which returns IQueryable, implementing a full Async Query Provider mock is verbose.
            // A simpler approach for the Unit test of Logic vs EF is to assume specific behavior or Refactor the Service to use `GetUserByEmail` method instead of direct LINQ.
            // But adhering to "Don't change code just for testing" initially:
            
            // Standard Moq setup for Async Enumerables is required here.
            // To avoid complexity in this first test, let's verify if we can start with a mock that returns an empty list for simple enumeration if possible,
            // or simply use a predefined Mock helpers if they existed.
            // Given the constraints and likely error of "Source is not IAsyncEnumerable", 
            // I will use a helper class approach or simply Refactor the Service later. 
            // For now, let's try to mock the repository to return a Mock DbSet or similar.
            
            // Actually, the easiest way for this code structure ("GetTableNoTracking") is to use the MockQueryable library, 
            // OR simply accept that we might need to change the Service to `GetByEmailAsync` to make it testable easily.
            // Let's assume for this step we will mock basic flow and might hit the Async issue, 
            // but let's try to write the test structure first.

            var mockSet = new Mock<DbSet<User>>();
            // Setup async queryable (Simplified for compilation, might fail runtime without specific Async Providers)
            
            _mockUserRepository.Setup(x => x.GetTableNoTracking()).Returns(MockDbSet(users));

            // Act
            var response = await _authService.RegisterAsync(request);

            // Assert
            response.Succeeded.Should().BeTrue();
            response.Data.Should().Be("User registered successfully");
            _mockUserRepository.Verify(x => x.AddAsync(It.IsAny<User>()), Times.Once);
            _mockUnitOfWork.Verify(x => x.CompleteAsync(), Times.Once);
        }

        // Helper to mock IQueryable/DbSet for Async usage (Simplified version)
        // In real world, we'd bring in a library like MockQueryable.Moq
        private DbSet<T> MockDbSet<T>(IQueryable<T> data) where T : class
        {
            var mockSet = new Mock<DbSet<T>>();
            mockSet.As<IQueryable<T>>().Setup(m => m.Provider).Returns(new TestAsyncQueryProvider<T>(data.Provider));
            mockSet.As<IQueryable<T>>().Setup(m => m.Expression).Returns(data.Expression);
            mockSet.As<IQueryable<T>>().Setup(m => m.ElementType).Returns(data.ElementType);
            mockSet.As<IQueryable<T>>().Setup(m => m.GetEnumerator()).Returns(data.GetEnumerator());
            // Async enumerator setup omitted for brevity in this initial file write
            return mockSet.Object;
        }
    }
    
    // Minimal Async Query Provider to satisfy EF Core extension methods
    internal class TestAsyncQueryProvider<TEntity> : IAsyncQueryProvider
    {
        private readonly IQueryProvider _inner;

        internal TestAsyncQueryProvider(IQueryProvider inner)
        {
            _inner = inner;
        }

        public IQueryable CreateQuery(Expression expression)
        {
            return new TestAsyncEnumerable<TEntity>(expression);
        }

        public IQueryable<TElement> CreateQuery<TElement>(Expression expression)
        {
            return new TestAsyncEnumerable<TElement>(expression);
        }

        public object Execute(Expression expression)
        {
            return _inner.Execute(expression);
        }

        public TResult Execute<TResult>(Expression expression)
        {
            return _inner.Execute<TResult>(expression);
        }

        public TResult ExecuteAsync<TResult>(Expression expression, CancellationToken cancellationToken = default)
        {
             // Detailed implementation usually needed here for ToListAsync/FirstOrDefaultAsync
             // For now, returning default execution to see if minimal works or we need full mock
             var resultType = typeof(TResult).GetGenericArguments()[0];
             var executionResult = typeof(IQueryProvider)
                 .GetMethod(
                     name: nameof(IQueryProvider.Execute),
                     genericParameterCount: 1,
                     types: new[] { typeof(Expression) })
                 .MakeGenericMethod(resultType)
                 .Invoke(this, new[] { expression });

             return (TResult)typeof(Task).GetMethod(nameof(Task.FromResult))
                 .MakeGenericMethod(resultType)
                 .Invoke(null, new[] { executionResult });
        }
    }

    internal class TestAsyncEnumerable<T> : EnumerableQuery<T>, IAsyncEnumerable<T>, IQueryable<T>
    {
        public TestAsyncEnumerable(IEnumerable<T> enumerable)
            : base(enumerable)
        { }

        public TestAsyncEnumerable(Expression expression)
            : base(expression)
        { }

        public IAsyncEnumerator<T> GetAsyncEnumerator(CancellationToken cancellationToken = default)
        {
            return new TestAsyncEnumerator<T>(this.AsEnumerable().GetEnumerator());
        }

        IQueryProvider IQueryable.Provider
        {
            get { return new TestAsyncQueryProvider<T>(this); }
        }
    }

    internal class TestAsyncEnumerator<T> : IAsyncEnumerator<T>
    {
        private readonly IEnumerator<T> _inner;

        public TestAsyncEnumerator(IEnumerator<T> inner)
        {
            _inner = inner;
        }

        public ValueTask DisposeAsync()
        {
            _inner.Dispose();
            return ValueTask.CompletedTask;
        }

        public ValueTask<bool> MoveNextAsync()
        {
            return ValueTask.FromResult(_inner.MoveNext());
        }

        public T Current
        {
            get { return _inner.Current; }
        }
    }
}
