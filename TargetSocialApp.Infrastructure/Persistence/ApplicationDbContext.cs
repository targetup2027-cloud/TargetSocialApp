using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Domain.Entities;
using System.Reflection;

namespace TargetSocialApp.Infrastructure.Persistence
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<PostMedia> PostMedia { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<PostReaction> PostReactions { get; set; }
        public DbSet<CommentReaction> CommentReactions { get; set; }
        public DbSet<Friendship> Friendships { get; set; }
        public DbSet<Following> Followings { get; set; }
        public DbSet<Story> Stories { get; set; }
        public DbSet<StoryView> StoryViews { get; set; }
        public DbSet<StoryHighlight> StoryHighlights { get; set; }
        public DbSet<StoryHighlightItem> StoryHighlightItems { get; set; }
        public DbSet<Conversation> Conversations { get; set; }
        public DbSet<ConversationParticipant> Participants { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<MessageDeliveryStatus> MessageStatuses { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<PrivacySetting> PrivacySettings { get; set; }
        public DbSet<NotificationSetting> NotificationSettings { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }
        public DbSet<SavedPost> SavedPosts { get; set; }
        public DbSet<BlockedUser> BlockedUsers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
        }
    }
}
