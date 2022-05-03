using Test, EventUtils

@testset "EventUtils.EventEmitter" begin
    event = EventEmitter()

    # register 2 functions to :test event.
    on!(event, :test, array -> push!(array, 1))
    on!(event, :test, array -> push!(array, 2))

    @test haskey(event, :test)

    # call :test events.
    array = Vector{Int}()
    @test emit(event, :test, array) == [[1, 2], [1, 2]]
    @test array == [1, 2]

    # remove :test events.
    remove!(event, :test)
    @test !haskey(event, :test)
end
