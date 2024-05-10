OPENRC_PATH=/path/to/openrc.sh
CONDA_PATH=/path/to/conda/bin # run a `which conda` to confirm path
USAGE_MONITORING_PATH=/path/to/usage_monitoring.py

export PATH="${CONDA_PATH}:$PATH"
source $OPENRC_PATH

conda run -n usage-monitoring python $USAGE_MONITORING_PATH --write
