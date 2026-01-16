using Microsoft.AspNetCore.Hosting;
using System;
using System.IO;
using System.Threading.Tasks;

using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.Application.Features.Media
{
    public class MediaService : AppService, IMediaService
    {
        public MediaService() 
        {
            // Inject WebHostEnvironment if needed, but AppService base might handle UploadImageAsync logic if we move it there or duplicated.
            // In AppService base shown in step 204 logs (UserService.UploadImageAsync), it was protected. 
            // I need to verify AppService implementation.
            // If AppService doesn't have it (it was in UserService in logs), I need to copy logic here.
        }
        
        // Assuming I need to inject IWebHostEnvironment
        private readonly IWebHostEnvironment _webHostEnvironment;

        public MediaService(IWebHostEnvironment webHostEnvironment)
        {
             _webHostEnvironment = webHostEnvironment;
        }

        public async Task<Response<string>> UploadMediaAsync(Requests.UploadMediaRequest request)
        {
             // Duplicated logic from UserService for now
             var folderName = request.Folder;
             var file = request.File;
             
             var uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "images", folderName);
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            return Response<string>.Success($"/images/{folderName}/{uniqueFileName}");
        }

        public async Task<Response<string>> DeleteMediaAsync(string mediaId)
        {
             // mediaId is relative path?
             // Delete file from disk
             var filePath = Path.Combine(_webHostEnvironment.WebRootPath, mediaId.TrimStart('/'));
             if (File.Exists(filePath))
             {
                 File.Delete(filePath);
                 return Response<string>.Success("Deleted");
             }
             return Response<string>.Failure("Not found");
        }
    }
}
