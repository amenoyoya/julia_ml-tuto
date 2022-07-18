export ArrayTrajectory

"""
配列式軌道
- 記録取得: () -> (記録)
- 記録実行: (状態, 次の行動)!
"""
Base.@kwdef mutable struct ArrayTrajectory <: Trajectory
    records = NamedTuple[] # [(state = 状態, action = 行動), ...]
end

(trajectory::ArrayTrajectory)() = trajectory.records
(trajectory::ArrayTrajectory)(state, next_action) = push!(trajectory.records, (state = state, action = next_action))
