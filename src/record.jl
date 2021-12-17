const TimeNS = typeof(time_ns())

struct ThreadLocalAccessRecord
    ptr::UInt
    time::TimeNS
end

const ACCESSES = Vector{ThreadLocalAccessRecord}[]
const LENGTHS = Int[]

function MemoryAccesses.init(n = 2^10)
    if length(ACCESSES) != Threads.nthreads() || length(LENGTHS) != 8 * Threads.nthreads()
        append!(empty!(ACCESSES), (Union{}[] for _ in 1:Threads.nthreads()))
        resize!(LENGTHS, 8 * Threads.nthreads())
    end
    fill!(LENGTHS, 0)
    for a in ACCESSES
        resize!(a, n)
        fill!(a, ThreadLocalAccessRecord(0, 0))
    end
    init_reference()
    return
end

function MemoryAccesses.clear()
    fill!(LENGTHS, 0)
    for a in ACCESSES
        fill!(a, ThreadLocalAccessRecord(0, 0))
    end
    clear_reference()
    return
end

MemoryAccesses.record(ptr) = MemoryAccesses.record(UInt(ptr))
function MemoryAccesses.record(ptr::UInt)
    tid = Threads.threadid()
    i = LENGTHS[8*tid] += 1
    ACCESSES[tid][min(i, end)] = ThreadLocalAccessRecord(ptr, time_ns())
    return
end

Base.@propagate_inbounds accesslength(tid) = LENGTHS[8*tid]

MemoryAccesses.isfull() =
    any(length(a) < accesslength(tid) for (tid, a) in enumerate(ACCESSES))

function checkfull()
    MemoryAccesses.isfull() || return
    n = length(ACCESSES[1])
    @warn """
    Buffer is full. Call `MemoryAccesses.clear(n)` to increase the buffer size.
    Currently, `n = $n`.
    """
end

function MemoryAccesses.view()
    checkfull()
    accesses = [@view(a[1:min(end, accesslength(tid))]) for (tid, a) in enumerate(ACCESSES)]
    references = Iterators.flatten(REFERENCES)
    return (; accesses, references)
end

function MemoryAccesses.copy()
    v = MemoryAccesses.view()
    return (; accesses = map(copy, v.accesses), references = collect(v.references))
end
