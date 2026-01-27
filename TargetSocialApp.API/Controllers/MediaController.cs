using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Media;
using TargetSocialApp.Application.Features.Media.Requests;
using TargetSocialApp.Application.Common.Bases;

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
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("{*mediaId}")] // wildcard to handle paths with slashes
        public async Task<IActionResult> Delete(string mediaId)
        {
            var response = await _mediaService.DeleteMediaAsync(mediaId);
            if (!response.Succeeded) return NotFound(ApiResponseWrapper.Create(response, 404));
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
