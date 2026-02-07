using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace TargetSocialApp.Application.Common.Interfaces;

public interface IFileService
{
    Task<string> UploadFileAsync(IFormFile file, string folderName);
    Task DeleteFileAsync(string filePath);
}
