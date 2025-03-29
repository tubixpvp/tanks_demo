namespace Utils;

public static class SafeTask
{
    public static Task Run(Func<Task> func)
    {
        Task task = Task.Run(func);
        if (task.IsCompleted)
        {
            OnTaskCompleted(task);
            return task;
        }
        task.GetAwaiter().OnCompleted(() => OnTaskCompleted(task));
        return task;
    }

    private static void OnTaskCompleted(Task task)
    {
        if (task.Exception != null)
        {
            throw task.Exception;
        }
    }
}