import ray

ray.init(f"ray://localhost:10001")

@ray.remote(num_cpus=1, num_gpus=0.1)
def square(x):    
    task_id = ray.get_runtime_context().get_task_id()
    return f"{x * x} by Worker {task_id}"
  
futures = [square.remote(i) for i in range(10)]

results = ray.get(futures)
for temp in results:
    print(temp)

