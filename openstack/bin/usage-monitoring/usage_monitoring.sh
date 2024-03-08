OPENRC_PATH=/path/to/openrc.sh
USAGE_MONITORING_PATH=/path/to/usage_monitoring.py

source $OPENRC_PATH

conda run -n usage-monitoring python $USAGE_MONITORING_PATH --write
