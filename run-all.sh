#!/bin/bash 

# read.sh
# ./run-sim.sh -c 2 -s read.sh &
# ./run-sim.sh -c 2 --ilat 4 --olat 4 -s read.sh &
# ./run-sim.sh -c 2 --ilat 4 --olat 1 -s read.sh &
# ./run-sim.sh -c 2 --ilat 1 --olat 4 -s read.sh &
./run-sim.sh -c 2 --ilat 8 --olat 1 -s read.sh &



# write.sh
# ./run-sim.sh -c 2 -s write.sh &
# ./run-sim.sh -c 2 --ilat 4 --olat 4 -s write.sh &
# ./run-sim.sh -c 2 --ilat 4 --olat 1 -s write.sh &
# ./run-sim.sh -c 2 --ilat 1 --olat 4 -s write.sh &
./run-sim.sh -c 2 --ilat 8 --olat 1 -s write.sh &
