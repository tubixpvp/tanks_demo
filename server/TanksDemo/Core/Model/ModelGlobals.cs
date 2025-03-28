using Core.Model.Registry;
using OSGI.Services;

namespace Core.Model;

public abstract class ModelGlobals
{
    [InjectService] 
    protected static ModelRegistry ModelRegistry;
}