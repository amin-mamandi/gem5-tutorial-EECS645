echo "Starting simple memory write benchmark"

# System info
lscpu
uname -a

# Create a simple memory-intensive write loop
echo "Starting memory write operations..."

# Loop that creates memory write patterns
COUNT=0
VALUE=0

echo "Running computation loop..."
for i in 1 2; do
  for j in $(seq 1 1000); do
    # Write operation - we assign a new value instead of reading
    VALUE=$((j * i))
    COUNT=$((COUNT + 1))
  done
  echo "Completed iteration $i, last value=$VALUE, count=$COUNT"
done

echo "Final value: $VALUE"
echo "Write operations performed: $COUNT"
echo "Benchmark complete"

# Exit
m5 exit