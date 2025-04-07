import torch
import argparse
import time

def allocate_and_calculate(gpu_indices, target_memory_gb=40):
    # Convert target memory to bytes
    target_memory_bytes = target_memory_gb * 1024**3

    # Calculate memory per GPU
    memory_per_gpu = target_memory_bytes // len(gpu_indices)

    while True:  # Endless loop
        for gpu_idx in gpu_indices:
            if not torch.cuda.is_available():
                print("CUDA is not available!")
                return

            if gpu_idx >= torch.cuda.device_count():
                print(f"GPU {gpu_idx} is not available!")
                continue

            torch.cuda.set_device(gpu_idx)
            device = torch.device(f'cuda:{gpu_idx}')

            # Allocate memory
            try:
                # Calculate matrix dimensions for 40GB
                # Each float32 element is 4 bytes
                # For matrix multiplication, we need two matrices
                # Let's create square matrices: n x n
                n = int((memory_per_gpu // 4 // 2) ** 0.5) * 2

                # Create two large matrices
                matrix1 = torch.randn(n, n, dtype=torch.float32, device=device)
                matrix2 = torch.randn(n, n, dtype=torch.float32, device=device)

                print(f"Allocated {2 * n * n * 4 / 1024**3:.2f} GB on GPU {gpu_idx}")

                # Perform matrix multiplication
                start_time = time.time()
                result = torch.matmul(matrix1, matrix2)  # Matrix multiplication
                elapsed_time = time.time() - start_time

                print(f"Matrix multiplication ({n}x{n}) on GPU {gpu_idx} completed in {elapsed_time:.4f} seconds")


            except RuntimeError as e:
                print(f"Failed to allocate memory on GPU {gpu_idx}: {str(e)}")
                break

        # Add a small delay between iterations
        time.sleep(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Allocate GPU memory and perform calculations")
    parser.add_argument('--gpus', nargs='+', type=int, default=[4, 5, 6, 7],
                        help='List of GPU indices to use (default: 4 5 6 7)')
    args = parser.parse_args()

    allocate_and_calculate(args.gpus)
