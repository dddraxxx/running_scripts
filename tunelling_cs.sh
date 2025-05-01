source ~/.bashrc

if [ -d ~/.cursor ]; then
    echo "Found previous cursor installation. Removing..."
    rm -r ~/.cursor
fi

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
        if os.path.exists('wandb_monitor.log'):
            wandb.save('wandb_monitor.log', policy="live")
        if os.path.exists(os.environ.get("RUN_LOG", "./RUN_LOG")):
            wandb.save(os.environ.get("RUN_LOG"), policy="live")
        if os.path.exists(os.environ.get("EXTRA_LOG", "./EXTRA_LOG")):
            wandb.save(os.environ.get("EXTRA_LOG"), policy="live")
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
curl -Lk 'https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64' --output vscode_cli.tar.gz

tar -xf vscode_cli.tar.gz
./cursor tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter --install-extension eamodio.gitlens --install-extension kisstkondoros.vscode-gutter-preview | tee vscode_tunnel.log
# ivanarjona.cloudflaretunnel

wait $WANDB_PID
# When tunneling ends, stop the wandb monitor
echo "Tunneling process completed, stopping wandb monitor..."
kill $WANDB_PID || echo "Wandb monitor already stopped"
