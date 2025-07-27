import transformers
import torch
from dotenv import load_dotenv
load_dotenv()

#https://huggingface.co/meta-llama/Llama-3.3-70B-Instruct

model_id = "meta-llama/Llama-3.3-70B-Instruct"
#model_id = "meta-llama/Llama-3.1-8B-Instruct"


from transformers import AutoModelForCausalLM
model = AutoModelForCausalLM.from_pretrained(
    model_id,
    device_map="auto",
    torch_dtype=torch.bfloat16
    
)
print(model.hf_device_map)