import ray
import time

ray.init(f"ray://localhost:10001")

# Define the actor - Inference Server.
@ray.remote(num_cpus=1, num_gpus=0.1)
class Inference_Server:
    def __init__(self):
        self.i = 0

    def get(self):
        return self.i

    def inference(self, value):
        actor_id = ray.get_runtime_context().get_actor_id()
        print(f"Inference by actor {actor_id}")
        self.i += value

# Launch 8 ranks for distributed inference or training
s0 = Inference_Server.remote()
s1 = Inference_Server.remote()
s2 = Inference_Server.remote()
s3 = Inference_Server.remote()
s4 = Inference_Server.remote()
s5 = Inference_Server.remote()
s6 = Inference_Server.remote()
s7 = Inference_Server.remote()

# Run inference on all actors
for _ in range(10):
    s0.inference.remote(1)
    s1.inference.remote(1)
    s2.inference.remote(1)
    s3.inference.remote(1)
    s4.inference.remote(1)
    s5.inference.remote(1)
    s6.inference.remote(1)
    s7.inference.remote(1)
    time.sleep(1)


print ( ray.get(s0.get.remote()) )
print ( ray.get(s1.get.remote()) )
print ( ray.get(s2.get.remote()) )
print ( ray.get(s3.get.remote()) )
print ( ray.get(s4.get.remote()) )
print ( ray.get(s5.get.remote()) )
print ( ray.get(s6.get.remote()) )
print ( ray.get(s7.get.remote()) )
