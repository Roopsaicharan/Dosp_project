import gleam/int
import gleam/io
import gleam/list
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

// Worker function: given #(k, max_len), return list of #(k, len, root) solutions
pub fn check_k(args: #(Int, Int)) -> List(#(Int, Int, Int)) {
  let #(k, max_len) = args

  list.fold(list.range(2, max_len), [], fn(acc, len) {
    let sum = sum_of_squares(k, len)
    let root = perfect_square_root(sum)
    case root > 0 {
      True -> [#(k, len, root), ..acc]
      False -> acc
    }
  })
}

pub fn main() -> Nil {
  let n = 1_000_000
  let max_len = 4
  let workers = 5

  // Measure the entire computation
  let #(_elapsed_time, results) =
    measure_time(fn() {
      // One task per k
      let tasks = list.map(list.range(1, n), fn(k) { #(k, max_len) })

      // Spawn workers
      let worker_results: List(List(#(Int, Int, Int))) =
        working_actors.spawn_workers(workers, tasks, check_k)

      // Flatten results and sort by starting k
      let all_solutions = list.flatten(worker_results)
      list.sort(all_solutions, fn(a, b) { int.compare(a.0, b.0) })
    })

  io.println("**** ANSWERS ****")
  // Print ALL first integers (k values) from the solutions
  list.each(results, fn(solution) {
    let #(k, _len, _root) = solution
    io.println(int.to_string(k))
  })
}
