export ArrayRecorder, records

"""
配列式記録者
- 記録取得: () -> (記録)
- 記録実行: (状態, 次の行動)!
"""
Base.@kwdef mutable struct ArrayRecorder <: RLRecorder
    records = NamedTuple[] # [(state = 状態, action = 行動), ...]
end

records(recorder::ArrayRecorder) = recorder.records

(recorder::ArrayRecorder)(state, next_action) = push!(recorder.records, (state = state, action = next_action))
