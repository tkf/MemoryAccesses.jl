module TestPlotter

using ..Example: schedule_timings
using MemoryAccesses
using Plots
using Test

function shows_something(mime, obj)
    io = IOBuffer()
    origin = position(io)
    show(io, mime, obj)
    return position(io) > origin
end

function test_show()
    table = MemoryAccesses.table(schedule_timings(100))
    @test shows_something("text/plain", table)
end

function test_plot()
    @testset for transform in [:collapse, :pack, :none]
        check_plot(transform)
    end
end

function check_plot(transform::Symbol)
    table = MemoryAccesses.table(schedule_timings(100); transform = transform)
    @test shows_something("image/png", plot(table))
    @test shows_something("image/png", MemoryAccesses.location_time(table))
    @test shows_something("text/plain", MemoryAccesses.location_time(table))
end

end  # module
