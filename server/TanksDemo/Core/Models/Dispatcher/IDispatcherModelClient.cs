using Core.Model.Communication;

namespace Core.Models.Dispatcher;

internal interface IDispatcherModelClient
{
    [NetworkMethod(CustomMethodId=0)]
    public void InitSpace(long spaceId);
}