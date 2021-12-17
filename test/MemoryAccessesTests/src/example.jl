module Example

using MemoryAccesses

function schedule_timings_dac(indices::AbstractUnitRange)
    if length(indices) == 0
    elseif length(indices) == 1
        MemoryAccesses.record(indices[1])
    else
        f = first(indices)
        l = last(indices)
        m = (l - f + 1) ÷ 2 + f - 1
        task = Threads.@spawn schedule_timings_dac(m+1:l)
        schedule_timings_dac(f:m)
        wait(task)
    end
    return nothing
end

function schedule_timings(nitems::Integer)
    MemoryAccesses.init(max(2^10, nitems))
    schedule_timings_dac(1:nitems)
    @assert !MemoryAccesses.isfull()
    return MemoryAccesses.copy()
end

end  # module
