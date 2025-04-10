using ClientGenerator.Flash;

namespace ClientGenerator;

internal interface IClientDataGenerator
{
    public Task Generate(string baseSrcRoot);

    public void GenerateActivator(FlashCodeGenerator generator);
}