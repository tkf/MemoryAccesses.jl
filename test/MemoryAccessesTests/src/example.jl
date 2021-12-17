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

function two_arrays_dac(indices::AbstractUnitRange, xs, ys)
    if length(indices) == 0
    elseif length(indices) == 1
        i = indices[1]
        MemoryAccesses.record(pointer(xs, i))
        MemoryAccesses.record(pointer(ys, i))
    else
        f = first(indices)
        l = last(indices)
        m = (l - f + 1) ÷ 2 + f - 1
        task = Threads.@spawn two_arrays_dac(m+1:l, xs, ys)
        two_arrays_dac(f:m, xs, ys)
        wait(task)
    end
    return nothing
end

function two_arrays(nitems::Integer)
    xs = zeros(nitems)
    ys = zeros(nitems)
    MemoryAccesses.init(max(2^10, nitems))
    MemoryAccesses.reference(xs, "xs")
    MemoryAccesses.reference(ys, "ys")
    two_arrays_dac(1:nitems, xs, ys)
    @assert !MemoryAccesses.isfull()
    return MemoryAccesses.copy()
end

end  # module
