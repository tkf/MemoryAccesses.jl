struct AccessRecordTable
    ptr::Vector{UInt}
    time::Vector{TimeNS}
    threadid::Vector{Int}
end

function MemoryAccesses.table(record = MemoryAccesses.view())
    n = sum(length, record)
    table = AccessRecordTable(
        Vector{UInt}(undef, n),
        Vector{TimeNS}(undef, n),
        Vector{Int}(undef, n),
    )

    j = 1
    for (tid, a) in enumerate(record)
        for i in eachindex(a)
            @inbounds begin
                r = a[i]
                table.ptr[j] = r.ptr
                table.time[j] = r.time
                table.threadid[j] = tid
            end
            j += 1
        end
    end

    p = sortperm(table.time; alg = MergeSort)
    permute!(table.ptr, p)
    permute!(table.time, p)
    permute!(table.threadid, p)

    return table
end

function Base.show(io::IO, ::MIME"text/plain", table::AccessRecordTable)
    print(io, MemoryAccesses)
    print(io, ".table()")
    println(io)
    print(io, "  #records: ", length(table.ptr))
    println(io)
    print(io, "  duration: ", table.time[end] - table.time[1], " ns")
end

const COLUMN_NAMES = fieldnames(AccessRecordTable)
const COLUMN_TYPES = Tuple{fieldtypes(AccessRecordTable)...}

Tables.istable(::Type{AccessRecordTable}) = true
Tables.columnaccess(::Type{AccessRecordTable}) = true
Tables.columns(table::AccessRecordTable) = table
Tables.schema(::AccessRecordTable) = Tables.Schema(COLUMN_NAMES, COLUMN_TYPES)
