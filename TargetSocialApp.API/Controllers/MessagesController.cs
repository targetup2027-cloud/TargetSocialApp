using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Messaging;
using TargetSocialApp.Application.Features.Messaging.Requests;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MessagesController : ControllerBase
    {
        private readonly IMessagingService _messagingService;

        public MessagesController(IMessagingService messagingService)
        {
            _messagingService = messagingService;
        }

        [HttpPut("{messageId}")]
        public async Task<IActionResult> UpdateMessage(int messageId, [FromBody] UpdateMessageRequest request)
        {
            int userId = 1;
            var response = await _messagingService.UpdateMessageAsync(userId, messageId, request);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpDelete("{messageId}")]
        public async Task<IActionResult> DeleteMessage(int messageId)
        {
            int userId = 1;
            var response = await _messagingService.DeleteMessageAsync(userId, messageId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPut("{messageId}/read")]
        public async Task<IActionResult> MarkRead(int messageId)
        {
            int userId = 1;
            var response = await _messagingService.MarkMessageAsReadAsync(userId, messageId);
             if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("{messageId}/react")]
        public async Task<IActionResult> React(int messageId, [FromBody] MessageReactionRequest request)
        {
            int userId = 1;
            var response = await _messagingService.ReactToMessageAsync(userId, messageId, request);
            return Ok(response);
        }
    }
}
