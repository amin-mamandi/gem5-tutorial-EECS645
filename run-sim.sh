#!/bin/bash

# Root directories
export GIT_ROOT=$(pwd)
GEM5_DIR=${GIT_ROOT}/gem5
GUEST_SCRIPT_DIR=${GIT_ROOT}/guest-scripts
RESOURCES=${GIT_ROOT}/resources-linux
RUNDIR_BASE="${GIT_ROOT}/runDir"

# default parameters based on ARM Cortex-A72
num_threads=1
num_cpus=2
Freq="2GHz"  # Typical A72 frequency
GUEST_SCRIPT="read.sh" #"write.sh"
RESTORE=1

# memory hierarchy parameters (A72 typical configs)
L1D_SIZE="64kB"
L1I_SIZE="64kB"
L2_SIZE="2MB"
L1D_ASSOC=8 # number of ways 
L1I_ASSOC=8 # number of ways 
L2_ASSOC=16 # number of ways 

# default bank parameters
ENABLE_BANKS="False"
ENABLE_BW_REGULATION="False"
NUM_BANKS=4


# Cortex-A72 core parameters
INT_REGS=128
FLOAT_REGS=128
VEC_REGS=128
ROB_ENTRIES=128
BTB_SIZE=4096
DTB_SIZE=32
ITB_SIZE=48
IQ_SIZE=44  # A72 spec
LQ_SIZE=64  # A72 spec
SQ_SIZE=36  # A72 spec

# Pipeline width parameters (A72 is 5-wide)
WIDTH=3
FETCH_WIDTH=$WIDTH
DECODE_WIDTH=$WIDTH
RENAME_WIDTH=$WIDTH
ISSUE_WIDTH=$WIDTH
WB_WIDTH=$WIDTH
DISPATCH_WIDTH=$WIDTH
COMMIT_WIDTH=$WIDTH
SQUASH_WIDTH=$WIDTH

# Cache configuration
CACHE_CONFIG="
    --caches
    --l2cache
    --cacheline_size=64
    --l1d_size=$L1D_SIZE
    --l1i_size=$L1I_SIZE
    --l1d_assoc=$L1D_ASSOC
    --l1i_assoc=$L1I_ASSOC
    --l2_size=$L2_SIZE
    --l2_assoc=$L2_ASSOC
"

function usage {
    echo "gem5 Simulation Runner - Quick Demo Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c, --num-cpus N        Number of CPU cores (default: $num_cpus)"
    echo "  -f, --freq FREQ         CPU frequency (default: $Freq)"
    echo "  -l, --l2size SIZE       L2 cache size (default: $L2_SIZE)"
    echo "  --olat N                Operation latency for functional units (default: 3)"
    echo "  --ilat N                Issue latency for functional units (default: 1)"
    echo "  -s, --script NAME       Guest script to run (default: $GUEST_SCRIPT)"
    echo "  -r, --restore N         Restore from checkpoint N (default: $RESTORE)"
    echo "  -k, --checkpoint        Take checkpoint"
    echo "  -h, --help              Show this help message"
    exit 1
}

# Default functional unit latencies
OP_LAT=3
ISSUE_LAT=1

# Parse command line arguments
TEMP=$(getopt -o 'c:t:f:l:b:s:n:r:d:kh' --long num-cpus:,num-threads:,freq:,l2size:,banks:,olat:,ilat:,script:,name:,restore:,script-dir:,checkpoint,help -n 'run-sim.sh' -- "$@")

eval set -- "$TEMP"

while true; do
    case "$1" in
        -c | --num-cpus) num_cpus="$2"; shift 2 ;;
        -t | --num-threads) num_threads="$2"; shift 2 ;;
        -f | --freq) Freq="$2"; shift 2 ;;
        -l | --l2size) L2_SIZE="$2"; shift 2 ;;
        -b | --banks) ENABLE_BANKS="True"; NUM_BANKS="$2"; shift 2 ;;
        --olat) OP_LAT="$2"; shift 2 ;;
        --ilat) ISSUE_LAT="$2"; shift 2 ;;
        -s | --script) GUEST_SCRIPT="$2"; shift 2 ;;
        -n | --name) name="$2"; shift 2 ;;
        -r | --restore) RESTORE="$2"; shift 2 ;;
        -d | --script-dir) GUEST_SCRIPT_DIR="$2"; shift 2 ;;
        -k | --checkpoint) checkpoint=1; shift 1 ;;
        -h | --help) usage ;;
        --) shift; break ;;
        *) break ;;
    esac
done

CKPT_DIR=${GIT_ROOT}/checkpoints/$GUEST_SCRIPT
RUNDIR=""

function setup_dirs {
    mkdir -p "$CKPT_DIR"
    mkdir -p "$RUNDIR"
    # Create parent directories for the simout file to ensure redirection works
    mkdir -p "$(dirname "$RUNDIR/simout")"
}

# Setup RUNDIR based on parameters outside of run_simulation
if [[ -n "$checkpoint" ]]; then
    RUNDIR=${GIT_ROOT}/ckptDir/$GUEST_SCRIPT
else
    
    RUNDIR=${GIT_ROOT}/runDir/$GUEST_SCRIPT
fi

# Functional unit latency configuration
FU_LAT_CONFIG="
    --param=system.cpu[:].executeFuncUnits.funcUnits[:].opLat=$OP_LAT
    --param=system.cpu[:].executeFuncUnits.funcUnits[:].issueLat=$ISSUE_LAT
"

function run_simulation {

    # Set up simulation parameters
    if [[ -n "$checkpoint" ]]; then
        GEM5TYPE="fast"
        CPUTYPE="AtomicSimpleCPU"
        EXTRA_CONFIG="--max-checkpoints 1 --cpu-type=$CPUTYPE"
    else
        RESTORE_CPU="MinorCPU" # CPU to restore from checkpoint with (can be "ArmO3CPU")
        SWITCH_CPU="MinorCPU" # CPU to switch to after restoring
        GEM5TYPE="fast"
        EXTRA_CONFIG="
            -r $RESTORE 
            --restore-with-cpu=$RESTORE_CPU
            --cpu-type=$SWITCH_CPU
        "
    fi
    
    RUNDIR+="_op${OP_LAT}_issue${ISSUE_LAT}"

    setup_dirs
    
    echo "Starting gem5 simulation in directory: $RUNDIR"
    "$GEM5_DIR/build/ARM/gem5.$GEM5TYPE" \
        --outdir="$RUNDIR" \
        "$GEM5_DIR"/configs/deprecated/example/fs.py \
        --kernel="$RESOURCES/vmlinux" \
        --disk="$RESOURCES/rootfs.ext2" \
        --bootloader="$RESOURCES/boot.arm64" \
        --root=/dev/sda \
        --num-cpus=$num_cpus \
        --num-l2caches=1 \
        --mem-type=DDR4_2400_16x4 \
        --mem-channels=1 \
        --mem-size=2048MB \
        --script="$GUEST_SCRIPT_DIR/$GUEST_SCRIPT" \
        --checkpoint-dir="$CKPT_DIR" \
        --cpu-clock=$Freq \
        $CACHE_CONFIG \
        --param=system.l2.enable_banks=True \
        --param=system.l2.enable_bw_regulation=False \
        --param=system.l2.num_banks=4 \
        --param=system.l2.bank_intlv_high_bit=7 \
        --param=system.cpu[:].icache.enable_banks=False \
        --param=system.cpu[:].dcache.enable_banks=False \
        $EXTRA_CONFIG \
        $FU_LAT_CONFIG

}

# Make sure RUNDIR exists before attempting redirection
mkdir -p "$RUNDIR"
# Now RUNDIR is defined and created before run_simulation is called
run_simulation > ${RUNDIR}/simout