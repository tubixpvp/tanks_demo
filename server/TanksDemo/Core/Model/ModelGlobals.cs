using Core.Model.Communication;
using Core.Model.Registry;
using OSGI.Services;

namespace Core.Model;

public abstract class ModelGlobals
{
    public static ModelRegistry ModelRegistry;
    
    [InjectService]
    protected static IModelCommunicationService ModelCommunicationService;


    public static ModelContext Context => _currentContext;

    private static readonly Stack<ModelContext?> ContextStack = new();
    
    private static ModelContext? _currentContext;

    public static void PutContext(ModelContext context)
    {
        lock (ContextStack)
        {
            ContextStack.Push(_currentContext);
            _currentContext = context;
        }
    }

    public static void PopContext()
    {
        lock (ContextStack)
        {
            _currentContext = ContextStack.Pop();
        }
    }
}