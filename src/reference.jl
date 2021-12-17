struct ReferenceRecord
    first::UInt
    last::UInt
    metadata::Any
end

const REFERENCES = Vector{ReferenceRecord}[]

function init_reference()
    if length(REFERENCES) != Threads.nthreads()
        append!(empty!(REFERENCES), (ReferenceRecord[] for _ in 1:Threads.nthreads()))
    end
    clear_reference()
end

function clear_reference()
    foreach(empty!, REFERENCES)
end

function MemoryAccesses.reference(a::AbstractArray, metadata = nothing)
    f = UInt(pointer(a, firstindex(a)))
    l = UInt(pointer(a, lastindex(a)))
    rec = ReferenceRecord(f, l, metadata)
    push!(REFERENCES[Threads.threadid()], rec)
    return
end
