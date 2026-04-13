## Environment for projects

Use uv .venv in the project for python commands.

### Install Python Packages

`uv pip install` to install the packages if needed.

## Long-Running Training Jobs
For formal or long-running training runs, do not keep the job attached to an interactive PTY/session that may terminate the process when the session closes.
Prefer launching real training in a persistent environment such as `tmux`, or an equivalent stable background process, and always write stdout/stderr to a log file.
If possible, also save checkpoints in a dedicated run directory so training can be resumed after interruption.
