#!/bin/bash

# Check the required arguments
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <executable | gleam run> [args...]"
  exit 1
fi

# Case 1: If the first argument is 'gleam', run gleam directly
if [ "$1" = "gleam" ]; then
  cmd="$@"
else
  filePath="$1"
  shift
  # Check if the file exists
  if [ ! -f "$filePath" ]; then
    echo "File not found: $filePath"
    exit 1
  fi
  cmd="$filePath $@"
fi

# Run and measure with /usr/bin/time
/usr/bin/time -p $cmd 2> time_output.txt

# Extract timings
real_time=$(grep 'real' time_output.txt | awk '{print $2}')
user_time=$(grep 'user' time_output.txt | awk '{print $2}')
sys_time=$(grep 'sys' time_output.txt | awk '{print $2}')

# Total CPU time
cpu_time=$(echo "$user_time + $sys_time" | bc)

# Exit if real-time is too small
if (( $(echo "$real_time < 0.01" | bc -l) )); then
  echo "Real Time too small to measure. Cores used: N/A"
  exit 0
fi

# CPU time / Real time ratio
cpu_real_ratio=$(echo "scale=2; $cpu_time / $real_time" | bc -l)

# Detect number of CPU cores (macOS vs Linux)
if command -v sysctl >/dev/null 2>&1; then
  num_cores=$(sysctl -n hw.logicalcpu)   # macOS
else
  num_cores=$(nproc)                     # Linux
fi

# Parallelism check
if (( $(echo "$cpu_real_ratio < 1.00" | bc -l) )); then
  echo "Parallelism is very low (CPU time is close to Real-time)"
elif (( $(echo "$cpu_real_ratio > $num_cores" | bc -l) )); then
  echo "Exceeded the number of available cores"
else
  effective_cores=$(echo "$cpu_real_ratio" | awk '{printf "%d", $1}')
  echo "Parallelism with approximately $effective_cores cores"
fi

# Print results
echo "Real Time: $real_time seconds"
echo "User Time: $user_time seconds"
echo "System Time: $sys_time seconds"
echo "CPU Time: $cpu_time seconds"
echo "CPU Time to Real Time Ratio: $cpu_real_ratio"
echo "Available cores: $num_cores"