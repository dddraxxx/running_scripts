touch vscode_tunnel.log

# Create Python script for wandb monitoring
cat > wandb_monitor.py << 'EOF'
import wandb
import time
import os
import sys

# Initialize wandb
run = wandb.init(project="vscode-tunnel-monitoring", job_type="monitoring")

log_file = "vscode_tunnel.log"
print(f"Monitoring {log_file} and saving to wandb...")

try:
    while True:
        # Optionally log file size as a metric
        if os.path.exists(log_file):
            wandb.save(log_file, policy="live")
            file_size = os.path.getsize(log_file)
        # Sleep for a while before checking again
        time.sleep(60)  # Check every minute
except KeyboardInterrupt:
    print("Monitoring stopped")
    wandb.finish()
except Exception as e:
    print(f"Error in monitoring: {e}")
    wandb.finish()
EOF

# Start the wandb monitoring script in the background
echo "Starting wandb monitoring script..."
python wandb_monitor.py > wandb_monitor.log 2>&1 &
WANDB_PID=$!
echo "Wandb monitoring started with PID: $WANDB_PID"

# Continue with normal tunneling process
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz

tar -xf vscode_cli.tar.gz
./code tunnel --accept-server-license-terms | tee vscode_tunnel.log

# When tunneling ends, stop the wandb monitor
echo "Tunneling process completed, stopping wandb monitor..."
kill $WANDB_PID || echo "Wandb monitor already stopped"
