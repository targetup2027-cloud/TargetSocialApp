using System.Collections.Generic;

namespace TargetSocialApp.Application.Common.Bases
{
    public class ApiResponse<T>
    {
        public int StatusCode { get; set; }
        public bool Succeeded { get; set; }
        public string Message { get; set; }
        public object Errors { get; set; }
        public T Data { get; set; }
        public object Meta { get; set; }

        public ApiResponse()
        {
        }

        public ApiResponse(Response<T> response, int statusCode = 200)
        {
            Succeeded = response.Succeeded;
            Message = response.Message;
            Data = response.Data;
            Meta = response.Meta;
            Errors = response.Errors;
            StatusCode = statusCode;
        }
    }

    public static class ApiResponseWrapper
    {
        public static ApiResponse<T> Create<T>(Response<T> response, int statusCode = 200)
        {
            return new ApiResponse<T>(response, statusCode);
        }
    }
}
