using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Media.Requests;

namespace TargetSocialApp.Application.Features.Media
{
    public interface IMediaService
    {
        Task<Response<string>> UploadMediaAsync(UploadMediaRequest request);
        Task<Response<string>> DeleteMediaAsync(string mediaId); 
    }
}
