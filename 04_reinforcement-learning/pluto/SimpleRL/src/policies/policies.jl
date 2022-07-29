"""
# 強化学習の方策

## Policy interfaces

"次の行動を決定"
next_action(policy::AbstractPolicy, action_space, current_state) -> action
"""

export next_action

include("./TablerPolicy.jl")
