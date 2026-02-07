using System.Threading.Tasks;

namespace TargetSocialApp.Application.Common.Interfaces
{
    public interface IUnitOfWork
    {
        // Add specific repository properties here as we implement them, e.g.
        // IUserRepository Users { get; }
        // For now, it's a placeholder to manage transactions if not using GenericRepository's transaction methods directly.
        Task<int> CompleteAsync();
    }
}
