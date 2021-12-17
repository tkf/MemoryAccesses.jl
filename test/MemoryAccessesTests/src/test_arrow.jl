module TestArrow

import Arrow
import MemoryAccesses
using ..Example: schedule_timings, two_arrays
using Test

function check_table(record1)
    io = IOBuffer()
    Arrow.write(io, [(sample = record1,)])
    seekstart(io)
    record2 = Arrow.Table(io).sample[1]

    table1 = MemoryAccesses.table(record1)
    table2 = MemoryAccesses.table(record2)
    @test table2 == table1
end

function test_table()
    @testset "$f" for f in [schedule_timings, two_arrays]
        check_table(f(100))
    end
end

end  # module
