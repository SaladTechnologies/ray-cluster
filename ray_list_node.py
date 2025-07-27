import ray

ray.init(f"ray://localhost:10001")

# Get the list of all Ray nodes
nodes = ray.nodes()

# Extract and print the name of each worker node
for node in nodes:
    # node['NodeID'] refers to the worker's node ID (for identification purposes)
    # node['Resources'] contains the resources available on that node
    if node['Alive'] == True:
        print()
        print(node)