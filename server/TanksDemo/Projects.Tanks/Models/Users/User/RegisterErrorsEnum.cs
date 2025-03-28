using Core.Generator;

namespace Projects.Tanks.Models.Users.User;

[ClientExport]
public enum RegisterErrorsEnum
{
    EmailLdapUnique,
    EmailNotValid,
    NameMaxLength,
    NameMinLength,
    PasswordMaxLength,
    PasswordMinLength,
    UidLdapUnique,
    UidMaxLength,
    UidMinLength,
    UidNotValid,
    PasswordsNotEqual
}