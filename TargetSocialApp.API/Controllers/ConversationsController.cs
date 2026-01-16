using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Messaging;
using TargetSocialApp.Application.Features.Messaging.Requests;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ConversationsController : ControllerBase
    {
        private readonly IMessagingService _messagingService;

        public ConversationsController(IMessagingService messagingService)
        {
            _messagingService = messagingService;
        }

        [HttpGet]
        public async Task<IActionResult> GetConversations()
        {
            int userId = 1;
            var response = await _messagingService.GetUserConversationsAsync(userId);
            return Ok(response);
        }

        [HttpGet("{conversationId}")]
        public async Task<IActionResult> GetConversation(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.GetConversationByIdAsync(userId, conversationId);
            if (!response.Succeeded) return NotFound(response);
            return Ok(response);
        }

        [HttpPost]
        public async Task<IActionResult> StartConversation([FromBody] CreateConversationRequest request)
        {
            int userId = 1;
            var response = await _messagingService.CreateConversationAsync(userId, request);
            return Ok(response);
        }

        [HttpDelete("{conversationId}")]
        public async Task<IActionResult> DeleteConversation(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.DeleteConversationAsync(userId, conversationId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("{conversationId}/messages")]
        public async Task<IActionResult> SendMessage(int conversationId, [FromBody] SendMessageRequest request)
        {
            int userId = 1;
            var response = await _messagingService.SendMessageAsync(userId, conversationId, request);
            return Ok(response);
        }

        [HttpGet("{conversationId}/messages")]
        public async Task<IActionResult> GetMessages(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.GetMessagesAsync(userId, conversationId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        // Media etc can be handled here or separate endpoints
         [HttpPost("{conversationId}/media")]
        public async Task<IActionResult> SendMedia(int conversationId)
        {
             // Implement using MessagingService SendMessage with type=Media
             return Ok();
        }
    }
}
