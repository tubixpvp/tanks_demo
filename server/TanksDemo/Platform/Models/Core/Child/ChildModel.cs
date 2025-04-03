using Core.Model;

namespace Platform.Models.Core.Child;

[ModelEntity(typeof(ChildModelEntity))]
[Model]
public class ChildModel(long id) : ModelBase<IChildModelClient>(id)
{
    
}