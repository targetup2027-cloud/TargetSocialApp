using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Media;
using TargetSocialApp.Application.Features.Media.Requests;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MediaController : ControllerBase
    {
        private readonly IMediaService _mediaService;

        public MediaController(IMediaService mediaService)
        {
            _mediaService = mediaService;
        }

        [HttpPost("upload")]
        public async Task<IActionResult> Upload([FromForm] UploadMediaRequest request)
        {
            var response = await _mediaService.UploadMediaAsync(request);
            return Ok(response);
        }

        [HttpDelete("{*mediaId}")] // wildcard to handle paths with slashes
        public async Task<IActionResult> Delete(string mediaId)
        {
            var response = await _mediaService.DeleteMediaAsync(mediaId);
            if (!response.Succeeded) return NotFound(response);
            return Ok(response);
        }
    }
}
