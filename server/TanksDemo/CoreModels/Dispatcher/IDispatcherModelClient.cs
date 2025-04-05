using Core.Model.Communication;

namespace CoreModels.Dispatcher;

internal interface IDispatcherModelClient
{
    [NetworkMethod(CustomMethodId=0)]
    public void InitSpace(long spaceId);
}