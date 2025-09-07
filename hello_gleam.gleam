import gleam/int
import gleam/io
import gleam/list
import gleam/string
import working_actors

// Simple timing using Erlang's system_time
@external(erlang, "erlang", "system_time")
fn get_time_nanoseconds() -> Int

pub fn measure_time(work: fn() -> a) -> #(Int, a) {
  let start_time = get_time_nanoseconds()
  let result = work()
  let end_time = get_time_nanoseconds()
  let elapsed = end_time - start_time
  #(elapsed, result)
}

// Sum of squares from k to k + m - 1 using formula
fn sum_of_squares(k: Int, m: Int) -> Int {
  let end = k + m - 1
  let sum_end = { end * { end + 1 } * { 2 * end + 1 } } / 6
  let sum_start_minus1 = { { k - 1 } * k * { 2 * { k - 1 } + 1 } } / 6
  sum_end - sum_start_minus1
}

// Integer square root using binary search
fn int_sqrt_helper(n: Int, low: Int, high: Int) -> Int {
  case low > high {
    True -> high
    False -> {
      let mid = { low + high } / 2
      case mid * mid <= n {
        True -> int_sqrt_helper(n, mid + 1, high)
        False -> int_sqrt_helper(n, low, mid - 1)
      }
    }
  }
}

fn int_sqrt(n: Int) -> Int {
  int_sqrt_helper(n, 0, n)
}

// Check if n is perfect square
fn perfect_square_root(n: Int) -> Int {
  let root = int_sqrt(n)
  case root * root == n {
    True -> root
    False -> 0
  }
}

// Worker function: only checks for EXACT length
pub fn check_k(args: #(Int, Int)) -> List(#(Int, Int, Int)) {
  let #(k, fixed_len) = args
  let sum = sum_of_squares(k, fixed_len)
  let root = perfect_square_root(sum)

  case root > 0 {
    True -> [#(k, fixed_len, root)]
    False -> []
  }
}

// Print a sequence like "2^2 + 3^2 = 13 = root^2"
fn print_sequence(k: Int, len: Int, root: Int) -> Nil {
  let seq = list.range(k, k + len - 1)
  let parts = list.map(seq, fn(x) { int.to_string(x) <> "^2" })
  let squares_str = string.join(parts, " + ")

  let sum_val = sum_of_squares(k, len)
  io.println(
    squares_str
    <> " = "
    <> int.to_string(sum_val)
    <> " = "
    <> int.to_string(root)
    <> "^2",
  )
}

pub fn main() -> Nil {
  let n = 1_000_000
  // input N
  let fixed_len = 4
  // input k (exact length)
  let workers = 100
  // number of parallel workers

  // Measure the entire computation
  let #(_elapsed_time, results) =
    measure_time(fn() {
      let tasks = list.map(list.range(1, n), fn(k) { #(k, fixed_len) })
      let worker_results: List(List(#(Int, Int, Int))) =
        working_actors.spawn_workers(workers, tasks, check_k)

      let all_solutions = list.flatten(worker_results)
      list.sort(all_solutions, fn(a, b) { int.compare(a.0, b.0) })
    })

  io.println("****ANSWER****")

  // Print result or "No solutions found"
  case list.first(results) {
    Ok(#(k, len, root)) -> {
      io.println("Smallest starting k: " <> int.to_string(k))
      print_sequence(k, len, root)
    }
    Error(_) -> io.println("No solutions found")
  }
}
