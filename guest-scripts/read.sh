echo "Starting simple memory read benchmark"

# System info
lscpu
uname -a

# Create a simple memory-intensive loop
echo "Starting memory read operations..."

# Loop that creates memory access patterns
COUNT=0
SUM=0

echo "Running computation loop..."
for i in 1 2; do
  for j in $(seq 1 1000); do
    SUM=$((SUM + j))
    COUNT=$((COUNT + 1))
  done
  echo "Completed iteration $i, sum=$SUM, count=$COUNT"
done

echo "Final sum: $SUM"
echo "Read operations performed: $COUNT"
echo "Benchmark complete"

# Exit
m5 exit