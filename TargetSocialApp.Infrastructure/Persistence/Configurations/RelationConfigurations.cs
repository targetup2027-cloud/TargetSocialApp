using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Infrastructure.Persistence.Configurations
{
    public class FriendshipConfiguration : IEntityTypeConfiguration<Friendship>
    {
        public void Configure(EntityTypeBuilder<Friendship> builder)
        {
            builder.HasOne(f => f.Requester)
                   .WithMany(u => u.SentFriendRequests)
                   .HasForeignKey(f => f.RequesterId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(f => f.Receiver)
                   .WithMany(u => u.ReceivedFriendRequests)
                   .HasForeignKey(f => f.ReceiverId)
                   .OnDelete(DeleteBehavior.Restrict);
        }
    }

    public class FollowingConfiguration : IEntityTypeConfiguration<Following>
    {
        public void Configure(EntityTypeBuilder<Following> builder)
        {
            builder.HasOne(f => f.Follower)
                   .WithMany() // Assuming no collection on User for now or just generic
                   .HasForeignKey(f => f.FollowerId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(f => f.FollowingUser)
                   .WithMany()
                   .HasForeignKey(f => f.FollowingId)
                   .OnDelete(DeleteBehavior.Restrict);
        }
    }

    public class BlockedUserConfiguration : IEntityTypeConfiguration<BlockedUser>
    {
        public void Configure(EntityTypeBuilder<BlockedUser> builder)
        {
            builder.HasOne(b => b.User)
                   .WithMany()
                   .HasForeignKey(b => b.UserId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(b => b.Blocked)
                   .WithMany()
                   .HasForeignKey(b => b.BlockedUserId)
                   .OnDelete(DeleteBehavior.Restrict);
        }
    }

    public class ConversationConfiguration : IEntityTypeConfiguration<Conversation>
    {
        public void Configure(EntityTypeBuilder<Conversation> builder)
        {
            // Configure the One-to-Many relationship (Conversation has many Messages)
            builder.HasMany(c => c.Messages)
                   .WithOne(m => m.Conversation)
                   .HasForeignKey(m => m.ConversationId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Configure the One-to-One relationship (Conversation has one LastMessage)
            builder.HasOne(c => c.LastMessage)
                   .WithOne() // No inverse navigation on Message
                   .HasForeignKey<Conversation>(c => c.LastMessageId)
                   .OnDelete(DeleteBehavior.Restrict); // Prevent cycles or cascading deletes
        }
    }

    public class StoryViewConfiguration : IEntityTypeConfiguration<StoryView>
    {
        public void Configure(EntityTypeBuilder<StoryView> builder)
        {
            builder.HasOne(sv => sv.Viewer)
                   .WithMany()
                   .HasForeignKey(sv => sv.ViewerId)
                   .OnDelete(DeleteBehavior.Restrict); // Break the cycle
        }
    }

    public class StoryHighlightItemConfiguration : IEntityTypeConfiguration<StoryHighlightItem>
    {
        public void Configure(EntityTypeBuilder<StoryHighlightItem> builder)
        {
            builder.HasOne(shi => shi.Story)
                   .WithMany()
                   .HasForeignKey(shi => shi.StoryId)
                   .OnDelete(DeleteBehavior.Restrict); // Break the cycle
                   
            builder.HasOne(shi => shi.Highlight)
                   .WithMany(h => h.Items)
                   .HasForeignKey(shi => shi.HighlightId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }

    public class MessageDeliveryStatusConfiguration : IEntityTypeConfiguration<MessageDeliveryStatus>
    {
        public void Configure(EntityTypeBuilder<MessageDeliveryStatus> builder)
        {
            builder.HasOne(mds => mds.User)
                   .WithMany()
                   .HasForeignKey(mds => mds.UserId)
                   .OnDelete(DeleteBehavior.Restrict); // Break cycle (Message -> Status, User -> Status)
        }
    }

    public class SavedPostConfiguration : IEntityTypeConfiguration<SavedPost>
    {
        public void Configure(EntityTypeBuilder<SavedPost> builder)
        {
            builder.HasOne(sp => sp.User)
                   .WithMany() // Or User.SavedPosts if it exists, checking User.cs shows SavedByUsers? Checking User.cs... No ICollection<SavedPost> might not be there or might be named differently. User.cs has public virtual ICollection<Post> Posts, ICollection<Comment> ...
                   // Let's re-check User.cs to be precise with navigation if it exists.
                   // The User.cs view showed ICollection<Post> Posts, ICollection<Comment> Comments, etc.
                   // It did NOT show ICollection<SavedPost>. So WithMany() is correct.
                   // Wait, checking Post.cs: public virtual ICollection<SavedPost> SavedByUsers.
                   // Checking User.cs... Step 15 view... lines 26-31.
                   // Posts, Comments, Stories, SentFriendRequests, ReceivedFriendRequests, UserSessions.
                   // NO SavedPosts on User. So WithMany() is correct.
                   .HasForeignKey(sp => sp.UserId)
                   .OnDelete(DeleteBehavior.Restrict); // Break cycle (Post -> SavedPost, User -> SavedPost)
        }
    }

    public class PostReactionConfiguration : IEntityTypeConfiguration<PostReaction>
    {
        public void Configure(EntityTypeBuilder<PostReaction> builder)
        {
            builder.HasOne(pr => pr.User)
                   .WithMany()
                   .HasForeignKey(pr => pr.UserId)
                   .OnDelete(DeleteBehavior.Restrict); // Break cycle (Post -> Reaction, User -> Reaction)
        }
    }

    public class CommentReactionConfiguration : IEntityTypeConfiguration<CommentReaction>
    {
        public void Configure(EntityTypeBuilder<CommentReaction> builder)
        {
            builder.HasOne(cr => cr.User)
                   .WithMany()
                   .HasForeignKey(cr => cr.UserId)
                   .OnDelete(DeleteBehavior.Restrict); // Break cycle (Comment -> Reaction, User -> Reaction)
        }
    }

    public class CommentConfiguration : IEntityTypeConfiguration<Comment>
    {
        public void Configure(EntityTypeBuilder<Comment> builder)
        {
            builder.HasOne(c => c.User)
                   .WithMany(u => u.Comments)
                   .HasForeignKey(c => c.UserId)
                   .OnDelete(DeleteBehavior.Restrict); // Break cycle (Post -> Comment, User -> Comment)

            builder.HasOne(c => c.ParentComment)
                   .WithMany(c => c.Replies)
                   .HasForeignKey(c => c.ParentCommentId)
                   .OnDelete(DeleteBehavior.Restrict); // Prevent self-referencing cascade issues often
        }
    }
}
