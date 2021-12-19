module TestPlotter

using ..Example: schedule_timings
using MemoryAccesses
using Plots
using Test

function test_show()
    table = MemoryAccesses.table(schedule_timings(100))
    io = IOBuffer()
    origin = position(io)
    show(io, "text/plain", table)
    @test position(io) > origin
end

function test_plot()
    @testset for transform in [:collapse, :pack, :none]
        check_plot(transform)
    end
end

function check_plot(transform::Symbol)
    table = MemoryAccesses.table(schedule_timings(100); transform = transform)
    plt = plot(table)
    io = IOBuffer()
    origin = position(io)
    show(io, "image/png", plt)
    @test position(io) > origin
end

end  # module
