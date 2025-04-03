using Core.Model;
using Core.Model.Communication;

namespace Projects.Tanks.Models.Users.User;

[ModelEntity(typeof(UserModelEntity))]
[Model]
internal class UserModel(long modelId) : ModelBase<IUserModelClient>(modelId)
{
    
    [NetworkMethod]
    private void LoginByName(string name)
    {
        
    }

    [NetworkMethod]
    private void LoginByUid(string name, string password)
    {
        
    }

    [NetworkMethod]
    private void RegisterUser(string name, string login, string mail, string password, string repPassword)
    {
        
    }

    [NetworkMethod]
    private void LoginByHash(string userHash)
    {
        
    }
}