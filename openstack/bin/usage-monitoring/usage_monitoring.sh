OPENRC_PATH=/path/to/openrc.sh
CONDA_PATH=/path/to/conda/bin
USAGE_MONITORING_PATH=/path/to/usage_monitoring.py

export PATH="/home/rocky/miniconda3/bin:$PATH"
source $OPENRC_PATH

conda run -n usage-monitoring python $USAGE_MONITORING_PATH --write
