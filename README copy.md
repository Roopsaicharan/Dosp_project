# COP5615 Project 1

## Team Members

- **ROOP SAI CHARAN KOTHAMASU** 
- UFID: 29397251

- **SAI NARASIMHA CHOWDARY YALAMANCHILI**
- UFID: 96675756

## GitHub Repository
[GitHub Link]()



## PROJECT DESCRIPTION

- This project explores parallel computing with actors in Gleam. The problem is to find all sequences of consecutive integers whose squares sum up to another perfect square (e.g., 3^2 + 4^2 = 5^2).

- The solution is implemented using actors and workers, where tasks are divided into smaller units and executed in parallel. Each worker actor checks a range of numbers, while the boss actor coordinates and collects the results. This setup demonstrates how to effectively distribute computational tasks across multiple cores using the actor model.



## OVERVIEW

- The program spawns multiple worker actors. Each worker checks whether the sum of squares of sequences starting at a given number is itself a perfect square. A boss actor manages distributing tasks among the workers and merges the results into the final output.

- The program also records both real time and CPU time to analyze efficiency and parallel performance.



## Actors and Functionality

### Boss Actor
- **Purpose**: Manages the division of work and assigns tasks to workers.

- **Responsibilities**:
    Splits the problem into tasks (k, max_len).
    Distributes tasks among worker actors.
    Collects results and merges them into the final output.

### Worker Actor
- **Purpose**: Processes a given range of tasks.

- **Responsibilities**:
    For each starting number k, checks sequences up to length max_len.
    Uses a closed-form formula for the sum of squares.
    Determines if the sum is a perfect square using an integer square root.
    Sends results back to the boss actor.

### HELPER FUNCTIONS
- **sum_of_squares(k, m)**: Int
- computes (\sum_{i=k}^{k+m-1} i^2) using a closed formula.

- **int_sqrt(n)**: Int
- Computes the integer square root of n with binary search.

- **perfect_square_root(n)**: Int
- Returns the root if n is a perfect square, otherwise 0.


## Performance Optimization

- **Work Unit Size** :
- Each worker processes one starting value k at a time.
- Ensures balanced load distribution.
- Prevents some workers from idling while others handle large chunks.

- **Efficient Algorithms** :
- Sum of squares is computed using a direct formula, avoiding slow loops.
- Integer square root is calculated using binary search, which is faster than naive methods.

- **Best Performance**:
- Achieved with 1 task per k, using 5–100 workers depending on the number of CPU cores available.


## EXAMPLE USAGE
- **STEP 1** : CREATE THE NEW GLEAM PROJECT 
- 1. gleam new hello_gleam


- **STEP 2** : ADD THE NECESSARY PACKAGES 
- 1. gleam add working_actors@1.
  2. gleam add gleam_erlang@1.


- **STEP 3** : PROCESS FOR THE EXECUTION OF PROJECT
-  1. CHANGE THE INPUT IN THE CODE ACCORDING TO USER DESIRE.
   2. OPEN TERMINAL AND RUN THIS COMMAND: gleam build
   3. NOW THE FINAL STEP, RUN THIS COMMANDS TO GET THE OUTPUT:
      - 1. chmod +x time.sh
        2. ./time.sh gleam run  


## OUTPUT 

![Output](./output.jpeg)

