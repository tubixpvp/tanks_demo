using Core.Model;

namespace Projects.Tanks.Models.Users.Profile;

[Model(ServerOnly = true)]
internal class UserProfileModel(long modelId) : ModelBase<object>(modelId)
{
}