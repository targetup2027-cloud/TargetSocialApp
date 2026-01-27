using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Infrastructure.Persistence.Seeding
{
    public class DataSeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly Random _random = new Random();

        public DataSeeder(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task SeedAsync()
        {
            // 1. Core Users & Settings
            if (!await _context.Users.AnyAsync())
            {
                await SeedUsersAsync();
            }

            // 2. Connections (Friendships & Followings)
            if (!await _context.Friendships.AnyAsync())
            {
                await SeedConnectionsAsync();
            }

            // 3. Content (Posts, Media)
            if (!await _context.Posts.AnyAsync())
            {
                await SeedPostsAsync();
            }

            // 4. Post Interactions (Comments, Reactions, Saved)
            if (!await _context.Comments.AnyAsync())
            {
                await SeedPostInteractionsAsync();
            }

            // 5. Stories & Highlights
            if (!await _context.Stories.AnyAsync())
            {
                await SeedStoriesAndHighlightsAsync();
            }

            // 6. Messaging (Conversations, Messages)
            if (!await _context.Conversations.AnyAsync())
            {
                await SeedMessagingAsync();
            }

            // 7. Notifications
            if (!await _context.Notifications.AnyAsync())
            {
                await SeedNotificationsAsync();
            }
            
            // 8. Blocked Users
             if (!await _context.BlockedUsers.AnyAsync())
            {
                await SeedBlockedUsersAsync();
            }
        }

        private async Task SeedUsersAsync()
        {
            var users = new List<User>();
            var genders = Enum.GetValues(typeof(Gender)).Cast<Gender>().ToArray();
            
            for (int i = 1; i <= 20; i++)
            {
                users.Add(new User
                {
                    FirstName = $"User{i}",
                    LastName = $"Test{i}",
                    Email = $"user{i}@test.com",
                    PasswordHash = "BCryptHashOrWhatever", // In real scenario, use password hasher
                    DateOfBirth = DateTime.UtcNow.AddYears(-20 - i),
                    Gender = genders[i % genders.Length],
                    Bio = $"Bio for user {i}. Social enthusiast.",
                    IsEmailVerified = true,
                    IsPhoneVerified = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    PrivacySetting = new PrivacySetting { ProfileVisibility = (i % 3 == 0) ? PrivacyLevel.OnlyMe : PrivacyLevel.Public },
                    NotificationSetting = new NotificationSetting { EmailNotifications = true, PushNotifications = true }
                });
            }

            await _context.Users.AddRangeAsync(users);
            await _context.SaveChangesAsync();
        }

        private async Task SeedConnectionsAsync()
        {
            var users = await _context.Users.ToListAsync();
            var friendships = new List<Friendship>();
            var followings = new List<Following>();

            for (int i = 0; i < users.Count; i++)
            {
                for (int j = i + 1; j < users.Count; j++)
                {
                    // Friendships (Mutual)
                    if (_random.Next(0, 4) == 0) // 25% chance
                    {
                        friendships.Add(new Friendship
                        {
                            RequesterId = users[i].Id,
                            ReceiverId = users[j].Id,
                            Status = FriendshipStatus.Accepted,
                            CreatedAt = DateTime.UtcNow
                        });
                    }

                    // Followings (One way) - Let's verify if Following exists in Context (based on previous check it does)
                    if (_random.Next(0, 3) == 0) // 33% chance i follows j
                    {
                        followings.Add(new Following
                        {
                            FollowerId = users[i].Id,
                            FollowingId = users[j].Id,
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                     if (_random.Next(0, 3) == 0) // 33% chance j follows i
                    {
                        followings.Add(new Following
                        {
                            FollowerId = users[j].Id,
                            FollowingId = users[i].Id,
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                }
            }

            await _context.Friendships.AddRangeAsync(friendships);
            await _context.Followings.AddRangeAsync(followings);
            await _context.SaveChangesAsync();
        }

        private async Task SeedPostsAsync()
        {
            var users = await _context.Users.ToListAsync();
            var posts = new List<Post>();

            foreach (var user in users)
            {
                int postCount = _random.Next(2, 6);
                for (int k = 0; k < postCount; k++)
                {
                    var post = new Post
                    {
                        UserId = user.Id,
                        Content = $"This is post #{k + 1} by {user.FirstName}. #seeding",
                        Privacy = PrivacyLevel.Public,
                        CreatedAt = DateTime.UtcNow.AddDays(-_random.Next(1, 60)),
                    };

                    // 50% chance to have media
                    if (_random.Next(0, 2) == 0)
                    {
                        post.Media = new List<PostMedia>
                        {
                            new PostMedia
                            {
                                MediaType = MediaType.Image,
                                Url = $"https://picsum.photos/seed/{user.Id}{k}/600/400"
                            }
                        };
                    }

                    posts.Add(post);
                }
            }

            await _context.Posts.AddRangeAsync(posts);
            await _context.SaveChangesAsync();
        }

        private async Task SeedPostInteractionsAsync()
        {
            var users = await _context.Users.ToListAsync();
            var posts = await _context.Posts.ToListAsync();

            var comments = new List<Comment>();
            var postReactions = new List<PostReaction>();
            var savedPosts = new List<SavedPost>();

            foreach (var post in posts)
            {
                // Comments
                int commentCount = _random.Next(0, 5);
                for (int c = 0; c < commentCount; c++)
                {
                    var commenter = users[_random.Next(users.Count)];
                    comments.Add(new Comment
                    {
                        PostId = post.Id,
                        UserId = commenter.Id,
                        Content = $"Nice post! {c}",
                        CreatedAt = DateTime.UtcNow.AddMinutes(c * 10)
                    });
                }

                // Reactions
                int reactionCount = _random.Next(0, 10);
                for (int r = 0; r < reactionCount; r++)
                {
                    var reactor = users[_random.Next(users.Count)];
                    // Ensure unique reaction per user per post
                    if (!postReactions.Any(pr => pr.PostId == post.Id && pr.UserId == reactor.Id))
                    {
                        postReactions.Add(new PostReaction
                        {
                            PostId = post.Id,
                            UserId = reactor.Id,
                            ReactionType = (ReactionType)_random.Next(0, 5) // Assuming enum has at least 5 values
                        });
                    }
                }

                // Saved Posts
                if (_random.Next(0, 5) == 0) // Occasional save
                {
                    var saver = users[_random.Next(users.Count)];
                     if (!savedPosts.Any(sp => sp.PostId == post.Id && sp.UserId == saver.Id))
                    {
                        savedPosts.Add(new SavedPost
                        {
                            PostId = post.Id,
                            UserId = saver.Id,
                            SavedAt = DateTime.UtcNow
                        });
                    }
                }
            }

            await _context.Comments.AddRangeAsync(comments);
            await _context.PostReactions.AddRangeAsync(postReactions);
            await _context.SavedPosts.AddRangeAsync(savedPosts);
            await _context.SaveChangesAsync();

            // Comment Reactions (Nested)
            // Need to save comments first to get IDs? Since we added to context they are tracked, but IDs generated on SaveChanges usually for Identity.
            // Let's reload comments or assume IDs populated if using strict EF Flow, but safe to do another pass.
            
            var savedComments = await _context.Comments.ToListAsync();
            var commentReactions = new List<CommentReaction>();
            
             foreach (var comment in savedComments)
            {
                 if (_random.Next(0, 2) == 0) // 50% chance of reaction
                 {
                     var reactor = users[_random.Next(users.Count)];
                     commentReactions.Add(new CommentReaction
                     {
                         CommentId = comment.Id,
                         UserId = reactor.Id,
                         ReactionType = ReactionType.Like
                     });
                 }
            }
            await _context.CommentReactions.AddRangeAsync(commentReactions);
            await _context.SaveChangesAsync();
        }

        private async Task SeedStoriesAndHighlightsAsync()
        {
            var users = await _context.Users.ToListAsync();
            var stories = new List<Story>();

            // Stories
            foreach (var user in users)
            {
                int storyCount = _random.Next(0, 3);
                for (int s = 0; s < storyCount; s++)
                {
                    stories.Add(new Story
                    {
                        UserId = user.Id,
                        MediaUrl = $"https://picsum.photos/seed/story{user.Id}{s}/400/800",
                        MediaType = MediaType.Image,
                        ExpiresAt = DateTime.UtcNow.AddHours(12),
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }
            await _context.Stories.AddRangeAsync(stories);
            await _context.SaveChangesAsync();

            // Story Views
            var savedStories = await _context.Stories.ToListAsync();
            var views = new List<StoryView>();
            foreach (var story in savedStories)
            {
                int viewCount = _random.Next(0, 5);
                for (int v = 0; v < viewCount; v++)
                {
                     var viewer = users[_random.Next(users.Count)];
                     if (viewer.Id != story.UserId && !views.Any(vw => vw.StoryId == story.Id && vw.ViewerId == viewer.Id))
                     {
                         views.Add(new StoryView
                         {
                             StoryId = story.Id,
                             ViewerId = viewer.Id,
                             ViewedAt = DateTime.UtcNow
                         });
                     }
                }
            }
            await _context.StoryViews.AddRangeAsync(views);

            // Highlights
            var highlights = new List<StoryHighlight>();
            foreach(var user in users)
            {
                 if (_random.Next(0,3) == 0)
                 {
                     highlights.Add(new StoryHighlight
                     {
                         UserId = user.Id,
                         Title = "My Best",
                         CoverImageUrl = "https://picsum.photos/100/100",
                         CreatedAt = DateTime.UtcNow
                     });
                 }
            }
            await _context.StoryHighlights.AddRangeAsync(highlights);
            await _context.SaveChangesAsync();
            
            // Highlight Items
            var savedHighlights = await _context.StoryHighlights.ToListAsync();
            var highlightItems = new List<StoryHighlightItem>();
            foreach(var hl in savedHighlights)
            {
                // Find user stories
                var userStories = savedStories.Where(s => s.UserId == hl.UserId).Take(2).ToList();
                foreach(var s in userStories)
                {
                     highlightItems.Add(new StoryHighlightItem
                     {
                         HighlightId = hl.Id,
                         StoryId = s.Id,
                         Order = 1
                     });
                }
            }
            await _context.StoryHighlightItems.AddRangeAsync(highlightItems);
            await _context.SaveChangesAsync();
        }

        private async Task SeedMessagingAsync()
        {
            var users = await _context.Users.ToListAsync();
            var conversations = new List<Conversation>();

            // Create some convos
            for(int i=0; i<10; i++)
            {
                 conversations.Add(new Conversation
                 {
                     IsGroup = false,
                     CreatedAt = DateTime.UtcNow, 
                     UpdatedAt = DateTime.UtcNow
                 });
            }
            await _context.Conversations.AddRangeAsync(conversations);
            await _context.SaveChangesAsync();

            var participants = new List<ConversationParticipant>();
            var messages = new List<Message>();
            
            // Assign participants and messages
            foreach(var convo in conversations)
            {
                var user1 = users[_random.Next(users.Count)];
                var user2 = users[_random.Next(users.Count)];
                while(user1.Id == user2.Id) user2 = users[_random.Next(users.Count)];

                participants.Add(new ConversationParticipant { ConversationId = convo.Id, UserId = user1.Id });
                participants.Add(new ConversationParticipant { ConversationId = convo.Id, UserId = user2.Id });

                // Add messages
                int msgCount = _random.Next(2, 10);
                for(int m=0; m<msgCount; m++)
                {
                    var sender = m % 2 == 0 ? user1 : user2;
                    messages.Add(new Message
                    {
                        ConversationId = convo.Id,
                        SenderId = sender.Id,
                        Content = $"Hello! Message {m}",
                        Type = MessageType.Text,
                        SentAt = DateTime.UtcNow.AddMinutes(m),
                        IsRead = true
                    });
                }
            }
            
            await _context.Participants.AddRangeAsync(participants);
            await _context.Messages.AddRangeAsync(messages);
            await _context.SaveChangesAsync();
        }

        private async Task SeedNotificationsAsync()
        {
             var users = await _context.Users.ToListAsync();
             var notifications = new List<Notification>();

             foreach(var user in users)
             {
                 int notifCount = _random.Next(1, 5);
                 for(int n=0; n<notifCount; n++)
                 {
                     var actor = users[_random.Next(users.Count)];
                     notifications.Add(new Notification
                     {
                         UserId = user.Id,
                         ActorId = actor.Id,
                         Type = NotificationType.Like, // Simplified
                         Content = $"{actor.FirstName} liked your post.",
                         IsRead = false,
                         CreatedAt = DateTime.UtcNow
                     });
                 }
             }

             await _context.Notifications.AddRangeAsync(notifications);
             await _context.SaveChangesAsync();
        }

        private async Task SeedBlockedUsersAsync()
        {
            var users = await _context.Users.ToListAsync();
            var blocked = new List<BlockedUser>();
            
             // Create a few blocks
             if (users.Count > 2)
             {
                 blocked.Add(new BlockedUser { UserId = users[0].Id, BlockedUserId = users[1].Id, BlockedAt = DateTime.UtcNow });
             }
             
             await _context.BlockedUsers.AddRangeAsync(blocked);
             await _context.SaveChangesAsync();
        }
    }
}
