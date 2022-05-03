module EventUtils

#################################
# module EventUtils.EventEmitter #
#################################
export EventEmitter, on!, remove!, emit

"type EventEmitter = Dict(:eventName => [event1(), event2(), ...])"
const EventEmitter = Dict{Symbol, Vector{Function}}

"""
    on!(self::EventEmitter, eventName::Symbol, eventFunction::Function)

Append an event function corresponding to the event name.
"""
on!(self::EventEmitter, eventName::Symbol, eventFunction::Function) = haskey(self, eventName) ?
    push!(self[eventName], eventFunction) :
    self[eventName] = [eventFunction]

"""
    remove!(self::EventEmitter, eventName::Symbol)

Remove all events corrensponding to the event name.
"""
remove!(self::EventEmitter, eventName::Symbol) = haskey(self, eventName) && pop!(self, eventName)

"""
    emit(self::EventEmitter, arguments...)

Emit events corresponding to the event name.
"""
emit(self::EventEmitter, eventName::Symbol, arguments...) = haskey(self, eventName) && map(self[eventName]) do event event(arguments...) end

end # module
