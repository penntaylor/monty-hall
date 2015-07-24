#!/usr/bin/env ruby

TRIALS = 100_000  # Total number of iterations. < 10_000 yields crap stats;
                  # 1_000_000 is pretty solid, but can take a while if exploring
                  # many strategies
NUM_DOORS = 5  # Standard problem has 3

# Standard problem uses MAX_CHOICES = NUM_DOORS - 1
# (include initial guess). Related problems can be explored by
# changing this property.
MAX_CHOICES = NUM_DOORS - 1


# Note that MAX_CHOICES includes the initial guess, and that in the
# choices array, the *initial guess* is always the first
# entry. So if there are N chances to switch or stay, there will be N+1
# entries in the choices array.
#
# In a few places, I have chosen to use less-compact code forms in order to
# make the overall flow easier to understand.
#
def run_sim(&switch_strategy_block)

  # Stats counters
  chosen = 0
  other = 0
  choice_count = Array.new(MAX_CHOICES,0)

  # Set the initial doors
  doors = (0...NUM_DOORS).to_a

  TRIALS.times do
    prize = rand(doors.size)

    # Since the prize location is random, we can fix the initial guess without
    # changing any important feature of the problem
    choices = [0]

    available_switches = doors - choices

    end_of_game = MAX_CHOICES
    (1..end_of_game).each do |reveal|
      # Monty Hall opens a door
      montys_options = available_switches - [prize]
      montys_choice = montys_options[rand(montys_options.size)]
      available_switches.delete(montys_choice)

      if (!available_switches.empty?  && reveal != end_of_game)
        new_choice = switch_strategy_block.call(choices, available_switches, reveal)
        available_switches.delete(new_choice)
        available_switches << choices.last if new_choice != choices.last
        choices << new_choice
      end
    end

    # Statistics
    choices.last == prize ? chosen += 1 : other += 1
    choices.each_with_index{|c,idx| choice_count[idx] += 1 if c == prize }

  end

  return [chosen, other, choice_count]
end


#### Strategies ####
#
# Strategies should take in the array of previous choices,
# the array of available choices, and the reveal number, and should
# return the new choice without altering any of the arrays. Reveal numbers
# are 1-based, so take that into account if using them to address array
# indices.

def always_stay(choices, available, reveal)
  return choices.last
end


def random_switch(choices, available, reveal)
  return available[rand(available.size)]

end


def never_repeat(choices, available, reveal)
  unused = available - choices
  # Stay if only other choice is to repeat a previous move
  return choices.last if unused.empty?
  return unused[rand(unused.size)]
end


def never_repeat_and_return_to_original_if_available_at_end(choices, available, reveal)
  if (reveal == (MAX_CHOICES - 1) && available.include?(choices.first))
    return choices.first
  else
    return random_switch(choices, available, reveal)
  end
end


# Metafunction to generate explicit strategy functions based on
# "stay_stay_switch" and the like. This is not limited to 3-operation
# strings.
def generate_strategy(strategy_string)
  define_method(strategy_string) do |choices, available, reveal|
    strategy = strategy_string.split('_')
    action = strategy[reveal - 1]
    case action
    when 'stay'
      return always_stay(choices, available, reveal)
    when 'switch'
      return random_switch(choices, available, reveal)
    end
  end
end


#### Running and reporting ####
@rankings = []

def report(strategy_name, &strategy)
  chosen, other, choice_count = run_sim(&strategy)
  cbd = choice_count.map{|c| Float(c) / Float(TRIALS)}
  puts ""
  puts "Strategy: #{strategy_name}"
  puts "  Success: #{chosen} (#{Float(chosen) / Float(TRIALS)})"
  puts "  Failure:  #{other}  (#{Float(other) / Float(TRIALS)})"
  puts "  Choice breakdown: #{cbd}"
  @rankings << [strategy_name, Float(chosen) / Float(TRIALS)]
end


puts "######################################################"
puts "Doors: #{NUM_DOORS}"
puts "Trials: #{TRIALS}"
puts ""
puts "Choice breakdown stats represent the probability of finding prize behind"
puts "each of the chosen doors, starting on the left with the original guess,"
puts "and showing the final choice on the far right."


# Define and run all possible stay/switch possibilities given
# the number of choices available
max_switches = MAX_CHOICES - 1

all_strategies = ['stay','switch'].repeated_permutation(max_switches).to_a

puts "\nThere are #{all_strategies.size} auto-generated unique strategies."

all_strategies.each do |strategy|
  strat_str = strategy.join('_')
  generate_strategy(strat_str)
  report(strat_str, &method(strat_str.to_sym))
end

# Manually report any additional strategies
report("never repeat", &method(:never_repeat))
report("return to original door at end if available", &method(:never_repeat_and_return_to_original_if_available_at_end))

@rankings = @rankings.sort_by{|a| a.last}
puts ""
puts "Ranked results, least effective to most effective:"
@rankings.each{|r| puts r.inspect}
