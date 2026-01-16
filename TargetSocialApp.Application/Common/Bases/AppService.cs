using System;
using System.IO;
using System.Threading.Tasks;
using FluentValidation;
using Microsoft.AspNetCore.Http;


namespace TargetSocialApp.Application.Common.Bases
{
    public class Response<T>
    {
        public bool Succeeded { get; set; }
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }
        public object? Meta { get; set; }
        public object? Errors { get; set; }

        public static Response<T> Success(T data, string message = "Operation completed successfully", object? meta = null)
        {
            return new Response<T> { Succeeded = true, Data = data, Message = message, Meta = meta };
        }

        public static Response<T> Failure(string message, object? errors = null)
        {
            return new Response<T> { Succeeded = false, Message = message, Errors = errors };
        }
    }

    public abstract class AppService
    {
        public async Task<Response<TResult>> DoValidationAsync<TRequest, TResult>(TRequest request, IValidator<TRequest> validator)
        {
            var validationResult = await validator.ValidateAsync(request);
            if (!validationResult.IsValid)
            {
                var errors = validationResult.Errors.Select(e => e.ErrorMessage).ToList();
                return Response<TResult>.Failure("Validation failed", errors);
            }
            return null; // Return null if validation succeeds, indicating caller should proceed
        }

        public async Task<string> UploadImageAsync(IFormFile file, string folder)
        {
             // Mock implementation for now, will enhance later
             if (file == null || file.Length == 0) return null;
             
             var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
             var path = Path.Combine("wwwroot", folder, fileName);
             
             // Ensure directory exists
             Directory.CreateDirectory(Path.Combine("wwwroot", folder));
             
             using (var stream = new FileStream(path, FileMode.Create))
             {
                 await file.CopyToAsync(stream);
             }
             
             return $"/{folder}/{fileName}";
        }
    }
}
