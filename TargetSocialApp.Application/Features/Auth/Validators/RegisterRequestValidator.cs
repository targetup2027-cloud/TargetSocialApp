using FluentValidation;
using TargetSocialApp.Application.Features.Auth.Requests;

namespace TargetSocialApp.Application.Features.Auth.Validators
{
    public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
    {
        public RegisterRequestValidator()
        {
            RuleFor(x => x.Email).NotEmpty().EmailAddress();
            RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
            RuleFor(x => x.LastName).NotEmpty().MaximumLength(100);
            RuleFor(x => x.Password).NotEmpty().MinimumLength(8)
                .Matches("[A-Z]").WithMessage("Password must contain uppercase letter.")
                .Matches("[a-z]").WithMessage("Password must contain lowercase letter.")
                .Matches("[0-9]").WithMessage("Password must contain digit.")
                .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain special character.");
            RuleFor(x => x.ConfirmPassword).Equal(x => x.Password);
        }
    }
}
