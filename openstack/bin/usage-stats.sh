# /bin/bash

usage () {
cat <<USAGE
Usage:
./usage-stats.sh [-r|--regular <reg-su-usage>] \\
    [-g|--gpu <gpu-su-usage>] \\
    [-l|--large <lrg-su-usage>] \\
    [-s|--stdin] \\
    [-h|--help]

Count the number of instances of each flavor on Jetstream2 and their total SU
usage. If the current SU usage of a particular flavor type is given using the
-r, -g, or -l arguments, also calculate the total remaining (real time) hours
and estimate a tentative date for when SUs will be exhausted.

If the -s|--stdin option is not given, the script will query "openstack server
list" for all ACTIVE instances.

If the -s|--stdin option is given, the input must be a list of instances on
seperate lines where each line has at least the flavor type (i.e. m3.*, g3.*,
and r3.*).

USAGE
}

if [[ "$#" == "0" ]]; then
	usage
	exit
fi

# Temp files
SERVERLIST=/tmp/usage-stats-server-list
TMPOUT=/tmp/usage-stats

# Usage limits
REG_LIMIT=5098320
GPU_LIMIT=600000
LRG_LIMIT=400000

# Parse input arguments 
while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -r|--regular)
            REG_USAGE="$2"
            shift # past argument
            ;;
        -g|--gpu)
            GPU_USAGE="$2"
            shift # past argument
            ;;
        -l|--large)
            LRG_USAGE="$2"
            shift # past argument
            ;;
        -s|--stdin)
            STDIN=1
            cat <&0 > $SERVERLIST
            ;;
        -h|--help)
	    usage
            exit
            ;;
    esac
    shift # past argument or value
done

# Default to ACTIVE server list if not reading from stdin
if [ -z "$STDIN" ]
then
    openstack server list | grep -e "ACTIVE" > $SERVERLIST
fi

# Flavor;SU/hr
FLAVORENTRIES=("m3.tiny;1"
	"m3.small;2"
	"m3.quad;4"
	"m3.medium;8"
	"m3.large;16"
	"m3.xl;32"
	"m3.2xl;64"
	"g3.small;16"
	"g3.medium;32"
	"g3.large;64"
	"g3.xl;128"
	"r3.large;128"
	"r3.xl;256"
)

# Totals for the three resource types i.e. Regular CPU, GPU, and Large
REG_COUNT=0
REG_SUHR=0

GPU_COUNT=0
GPU_SUHR=0

LRG_COUNT=0
LRG_SUHR=0

# Generate Usage Table
echo "---------------------------------------------------"
echo "Flavor;Count;SU/hr/instance;SU/hr;Current SU Usage;SU Limit;SUs Remaining;Hours Remaining;Tentative Date" > $TMPOUT
for ENTRY in ${FLAVORENTRIES[@]}
do
	TYPE=$(echo $ENTRY | awk -F "." '{print $1}')
	FLAVOR=$(echo $ENTRY | awk -F ";" '{print $1}')
	SUHR=$(echo $ENTRY | awk -F ";" '{print $2}')
	COUNT=$(grep -ce "$FLAVOR" $SERVERLIST)
	# SU/hr "Per Flavor"
	FSUHR=$(( SUHR*COUNT ))
	case $TYPE in
		m3)
			let REG_COUNT=REG_COUNT+COUNT
			let REG_SUHR=REG_SUHR+FSUHR
			;;
		g3)
			let GPU_COUNT=GPU_COUNT+COUNT
			let GPU_SUHR=GPU_SUHR+FSUHR
			;;
		r3)
			let LRG_COUNT=LRG_COUNT+COUNT
			let LRG_SUHR=LRG_SUHR+FSUHR
			;;
	esac
	echo -e "$FLAVOR;$COUNT;$SUHR;$FSUHR;---;---;---;---;---"
done >> $TMPOUT

# For each CLI option given, calculate Hours Remaining and a tentative End date
# for when we would exhaust SUs
# Handle divide by zero
if [[ -z "$REG_USAGE" || "$REG_SUHR" == "0" ]]; then
	REG_HR_REM="N/A"; REG_END="N/A";
else
	let REG_REMAINING=REG_LIMIT-REG_USAGE
	let REG_HR_REM=REG_REMAINING/REG_SUHR
	REG_END=$(date --date="today + $REG_HR_REM hours" +%F)
fi

if [[ -z "$GPU_USAGE" || "$GPU_SUHR" == "0" ]]; then
	GPU_HR_REM="N/A"; GPU_END="N/A"
else
	let GPU_REMAINING=GPU_LIMIT-GPU_USAGE
	let GPU_HR_REM=GPU_REMAINING/GPU_SUHR
	GPU_END=$(date --date="today + $GPU_HR_REM hours" +%F)
fi

if [[ -z "$LRG_USAGE" || "$LRG_SUHR" == "0" ]]; then
	LRG_HR_REM="N/A"; LRG_END="N/A"
else
	let LRG_REMAINING=LRG_LIMIT-LRG_USAGE
	let LRG_HR_REM=LRG_REMAINING/LRG_SUHR
	LRG_END=$(date --date="today + $LRG_HR_REM hours" +%F)
fi

# Default values
REG_USAGE=${REG_USAGE:-"N/A"}
GPU_USAGE=${GPU_USAGE:-"N/A"}
LRG_USAGE=${LRG_USAGE:-"N/A"}
REG_REMAINING=${REG_REMAINING:-"N/A"}
GPU_REMAINING=${GPU_REMAINING:-"N/A"}
LRG_REMAINING=${LRG_REMAINING:-"N/A"}

echo "TOTAL REG;$REG_COUNT;---;$REG_SUHR;$REG_USAGE;$REG_LIMIT;$REG_REMAINING;$REG_HR_REM;$REG_END" >> $TMPOUT
echo "TOTAL GPU;$GPU_COUNT;---;$GPU_SUHR;$GPU_USAGE;$GPU_LIMIT;$GPU_REMAINING;$GPU_HR_REM;$GPU_END" >> $TMPOUT
echo "TOTAL LRG;$LRG_COUNT;---;$LRG_SUHR;$LRG_USAGE;$LRG_LIMIT;$LRG_REMAINING;$LRG_HR_REM;$LRG_END" >> $TMPOUT
echo "GRAND TOTAL;$((REG_COUNT+GPU_COUNT+LRG_COUNT));---;---;---;---;---;---;---" >> $TMPOUT

column -t -s ";" $TMPOUT
echo "---------------------------------------------------"
