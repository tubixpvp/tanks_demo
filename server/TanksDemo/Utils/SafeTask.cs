namespace Utils;

public static class SafeTask
{
    public static Task Run(Func<Task> func, Action<Exception>? onError)
    {
        Task task = Task.Run(func);
        return AddListeners(task, onError);
    }

    public static Task AddListeners(Task task, Action<Exception>? onError)
    {
        if (task.IsCompleted)
        {
            OnTaskCompleted(task, onError);
            return task;
        }
        task.GetAwaiter().OnCompleted(() => OnTaskCompleted(task, onError));
        return task;
    }

    private static void OnTaskCompleted(Task task, Action<Exception>? onError)
    {
        if (task.Exception != null)
        {
            if (onError != null)
            {
                onError(task.Exception);
                return;
            }
            throw task.Exception;
        }
    }
}