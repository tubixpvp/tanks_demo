namespace Projects.Tanks.Models.Users.User;

public interface IUserModelClient
{
    public void LoginFailed(LoginErrorsEnum loginError);
    public void RegistrFailed(RegisterErrorsEnum registrationError);


    public void SetHash(string hash);
}