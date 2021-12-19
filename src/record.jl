const TimeNS = typeof(time_ns())

struct ThreadLocalAccessRecord
    ptr::UInt
    time::TimeNS
    tag::UInt
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
        fill!(a, ThreadLocalAccessRecord(0, 0, 0))
    end
    init_reference()
    return
end

function MemoryAccesses.clear()
    fill!(LENGTHS, 0)
    for a in ACCESSES
        fill!(a, ThreadLocalAccessRecord(0, 0, 0))
    end
    clear_reference()
    return
end

"""
    MemoryAccesses.record(x, [tag = UInt(0)])

Record that `x` is accessed.

* If `x` is an array, `pointer(x, 1)` is recorded.
  (TODO: record the first and the last pointers?)
* Otherwise `x` is assumed to be convertable to an `UInt` (e.g., `Ptr`) whose
  value is recorded.

Optionally, arbitrary value `tag` that is convertable to an `UInt` can be passed
as the second argument.
"""
MemoryAccesses.record

MemoryAccesses.record(xs::AbstractArray, tag = UInt(0)) =
    MemoryAccesses.record(pointer(xs, 1), tag)

MemoryAccesses.record(ptr, tag = UInt(0)) = MemoryAccesses.record(UInt(ptr), tag)
function MemoryAccesses.record(ptr::UInt, tag = UInt(0))
    tid = Threads.threadid()
    i = LENGTHS[8*tid] += 1
    ACCESSES[tid][min(i, end)] = ThreadLocalAccessRecord(ptr, time_ns(), UInt(tag))
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
