using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Messaging;
using TargetSocialApp.Application.Features.Messaging.Requests;
using TargetSocialApp.Application.Common.Bases;

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
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("{conversationId}")]
        public async Task<IActionResult> GetConversation(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.GetConversationByIdAsync(userId, conversationId);
            if (!response.Succeeded) return NotFound(ApiResponseWrapper.Create(response, 404));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost]
        public async Task<IActionResult> StartConversation([FromBody] CreateConversationRequest request)
        {
            int userId = 1;
            var response = await _messagingService.CreateConversationAsync(userId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("{conversationId}")]
        public async Task<IActionResult> DeleteConversation(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.DeleteConversationAsync(userId, conversationId);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("{conversationId}/messages")]
        public async Task<IActionResult> SendMessage(int conversationId, [FromBody] SendMessageRequest request)
        {
            int userId = 1;
            var response = await _messagingService.SendMessageAsync(userId, conversationId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("{conversationId}/messages")]
        public async Task<IActionResult> GetMessages(int conversationId)
        {
            int userId = 1;
            var response = await _messagingService.GetMessagesAsync(userId, conversationId);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        // Media etc can be handled here or separate endpoints
         [HttpPost("{conversationId}/media")]
        public async Task<IActionResult> SendMedia(int conversationId)
        {
             // Implement using MessagingService SendMessage with type=Media
             return Ok(ApiResponseWrapper.Create(Response<string>.Success("Succeeded")));
        }
    }
}
