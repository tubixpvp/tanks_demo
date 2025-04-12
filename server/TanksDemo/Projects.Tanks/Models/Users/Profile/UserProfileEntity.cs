namespace Projects.Tanks.Models.Users.Profile;

internal class UserProfileEntity
{
    public required string UserName { get; init; }

    public int Experience { get; set; }
}