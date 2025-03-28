namespace ClientGenerator;

internal interface IClientDataGenerator
{
    public Task Generate(string baseSrcRoot);
}