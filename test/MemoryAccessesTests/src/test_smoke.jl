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
    table = MemoryAccesses.table(schedule_timings(100))
    plt = plot(table)
    io = IOBuffer()
    origin = position(io)
    show(io, "image/png", plt)
    @test position(io) > origin
end

end  # module
