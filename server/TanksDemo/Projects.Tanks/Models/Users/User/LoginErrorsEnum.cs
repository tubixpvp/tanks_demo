using Core.Generator;

namespace Projects.Tanks.Models.Users.User;

[ClientExport]
public enum LoginErrorsEnum
{
    CriticalLoginError,
    HashLoginFailed,
    UidLoginFailed,
    NameMinLength,
    NameMaxLength,
    UserAlreadyLoggedIn
}