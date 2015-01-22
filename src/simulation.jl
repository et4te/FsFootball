#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export simulate_seq

#------------------------------------------------------------------------------
# Types
#------------------------------------------------------------------------------

type Goal
    home_goal::Bool
    away_goal::Bool
    time::Int
end

type Match
    home_team::String
    away_team::String
    final_home_score::Int
    final_away_score::Int
    goals::Array{Goal}
end

#------------------------------------------------------------------------------
# Data Generation
#------------------------------------------------------------------------------

function sum_home_goals (goals)
    acc = 0
    for i = 1:length(goals)
        if goals[i].home_goal
            acc += 1
        end
    end
    acc
end

function sum_away_goals (goals)
    acc = 0
    for i = 1:length(goals)
        if goals[i].away_goal
            acc += 1
        end
    end
    acc
end

# The next outcome is determined by the probability of home score 'hp'
# and the probability of away scoring 'ap'.
# Both scoring is a possibility.

const home_strength = (2.27 * 0.36 * 1.37) / 90
const away_strength = (2.55 * 0.28) / 90

function next_outcome (time::Integer)
    # random number limit ?
    r = rand(Float32, 2)
    home_probability = (home_strength + (0.70 * time))
    away_probability = (away_strength + (0.65 * time))
    home_outcome = r[1] < home_probability
    away_outcome = r[2] < away_probability
    Goal(home_outcome, away_outcome, time)
end

function seq (typ, f, range)
    output::Array{typ} = Array(typ, length(range))
    for i in range
        output[i] = f(i)
    end
    output
end

function next_match (match_index)
    timeline_lim = 90 + rand(0:5)
    
    goals = seq(Goal, next_outcome, 1:timeline_lim)
    home_score = sum_home_goals(goals)
    away_score = sum_away_goals(goals)

    Match("", "", home_score, away_score, goals)
end

function simulate_seq (niter)
    out = seq(Match, next_match, 1:niter)

    total_home_score = 0
    total_away_score = 0
    for i in 1:niter
        total_home_score += out[i].final_home_score
        total_away_score += out[i].final_away_score
    end

    (uint32(total_home_score), uint32(total_away_score))
end

