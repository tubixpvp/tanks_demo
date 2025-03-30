using System.Reflection;
using Utils;

namespace OSGI.Services;

public static class OSGi
{
    private static readonly Dictionary<Type, object> Services = new ();

    private static readonly Dictionary<Type, List<FieldInfo>> InjectionPoints = new();

    
    public static void RegisterService(Type key, object instance)
    {
        lock (Services)
        {
            Services.Add(key, instance);
        }

        if (InjectionPoints.TryGetValue(key, out var injectionPoints))
        {
            foreach (FieldInfo field in injectionPoints)
            {
                field.SetValue(null, instance);
            }
        }
    }

    public static T GetService<T>()
    {
        lock (Services)
        {
            return (T)Services[typeof(T)];
        }
    }

    /**
     * Initialize the services system:
     * All existing services are created and added to registry
     * All services injection points are added to the registry
     */
    public static void Init()
    {
        Services.Clear();
        InjectionPoints.Clear();

        //create services
        Type[] servicesTypes = AttributesUtil.GetTypesWithAttribute(typeof(ServiceAttribute));
        
        Console.WriteLine("Starting up the services: " + string.Join(", ",servicesTypes.Select(type => type.Name)));

        foreach (Type serviceType in servicesTypes)
        {
            Services.Add(serviceType, Activator.CreateInstance(serviceType)!);
        }
        
        //inject services
        Type[] allTypes = AttributesUtil.GetAllTypes();

        foreach (Type type in allTypes)
        {
            foreach (FieldInfo field in type.GetFields(BindingFlags.Static | BindingFlags.Public |
                                                       BindingFlags.NonPublic))
            {
                InjectServiceAttribute? injectAttribute = field.GetCustomAttribute<InjectServiceAttribute>();
                if (injectAttribute != null)
                {
                    AddInjectionPoint(field);
                }
            }
        }

        foreach (object serviceImpl in Services.Values)
        {
            if (serviceImpl is IOSGiInitListener listener)
            {
                listener.OnOSGiInited();
            }
        }
    }

    private static void AddInjectionPoint(FieldInfo field)
    {
        Type serviceKey = field.FieldType;
        
        //Console.WriteLine($"Added injection point of {serviceKey.Name}");

        if (!InjectionPoints.TryGetValue(serviceKey, out var injectionPoints))
        {
            InjectionPoints.Add(serviceKey, injectionPoints = new());
        }
        
        injectionPoints.Add(field);

        //do injection if service already exists
        if (Services.TryGetValue(serviceKey, out var serviceInstance))
        {
            //Console.WriteLine("Value written to field " + field.Name);
            field.SetValue(null, serviceInstance);
        }
    }
}