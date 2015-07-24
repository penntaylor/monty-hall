Monty Hall Problem Simulator
============================

This simple Ruby program simulates the Monty Hall Problem. The number of
initial doors, the number of stay/switch opportunites, and the total
number of trial runs can be configured via constants in the code.

Out of the box, the simulator is set up to report ensemble probabilities
of finding the prize behind each of the sequential choices in a
stay/switch strategy. By default, the program generates an exhaustive
list of all possible simple stay/switch strategies for a set number
of stay/switch opportunites. Custom strategies (switch-back,
don't repeat, switch or stay based on some external criterion, etc.)
can easily be added as normal Ruby methods and passed into the simulation.


How is the problem modeled?
===========================

For each trial, we keep track of the location of the prize, the doors
available for switching to, and the choice history. After every reveal
(when Monty Hall opens a door), we call into the passed
`switch_strategy_block` to determine which door the contestant chooses
(options are always to either stay with current door or switch to one of
the `available_switches`).

After each trial, we check the location of the prize against the choice
history, and track statistics of where the prize was.


Result reporting
================

Results are reported in the following format (this is for 100,000 trials
on a 5-door problem):

    Strategy: stay_stay_stay
      Success: 19891 (0.19891)
      Failure:  80109  (0.80109)
      Choice breakdown: [0.19891, 0.19891, 0.19891, 0.19891]

    Strategy: stay_stay_switch
      Success: 79939 (0.79939)
      Failure:  20061  (0.20061)
      Choice breakdown: [0.20061, 0.20061, 0.20061, 0.79939]


* `Strategy` is the name of the stay/switch strategy being reported.
* `Success` shows first the absolute number of events
  in which the prize was found behind the last-chosen door. The
  number in parentheses is the normalized probability of successfully
  winning the prize using that strategy.
* `Failure` shows the absolute number of events in which the prize
  was *not* found behind the last-chosen door, followed by the
  probability of failing to win the prize using that strategy.
* `Choice breakdown` shows the probability of finding the prize behind
  each of the doors chosen in sequence throughout the game. The first
  entry is the original guess, the second is the door chosen during the
  first stay/switch opportunity, etc. Since the last entry is always the
  last-chosen door, its probability is exactly the same as the overall
  `success` probability.

Following the detailed results for each strategy is a sorted list of all
the strategies and their associated success rates, with the least
successful strategy listed first and the most successful strategy listed
last.
