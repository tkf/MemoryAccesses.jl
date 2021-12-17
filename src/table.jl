@auto_hash_equals struct AccessRecordTable
    access::Vector{UInt}
    time::Vector{TimeNS}
    threadid::Vector{Int}
    referenceid::Vector{Int}
end

function MemoryAccesses.table(record = MemoryAccesses.view())
    accesses = record.accesses
    references = record.references

    n = sum(length, accesses)
    table = AccessRecordTable(
        Vector{UInt}(undef, n),
        Vector{TimeNS}(undef, n),
        Vector{Int}(undef, n),
        Vector{Int}(undef, n),
    )

    fill_table!(accessid_factory(references), table, accesses)

    p = sortperm(table.time; alg = MergeSort)
    permute!(table.access, p)
    permute!(table.time, p)
    permute!(table.threadid, p)
    permute!(table.referenceid, p)

    return table
end

function fill_table!(accessid, table, accesses)
    j = 1
    for (tid, a) in enumerate(accesses)
        for i in eachindex(a)
            @inbounds begin
                r = a[i]
                table.access[j], table.referenceid[j] = accessid(r.ptr)
                table.time[j] = r.time
                table.threadid[j] = tid
            end
            j += 1
        end
    end
end

@inline raw_accessid(ptr) = (ptr, 0)

"""
    accessid_factory(references) -> ptr -> (access, referenceid)

Compile a ptr-to-(access, metadata) mapping from an iterable of
`ReferenceRecord`-like values.
"""
function accessid_factory(references)
    accessid = raw_accessid
    id = 1
    for refrec in references
        accessid = let id = id, fallback = accessid, accessid
            @inline function accessid(ptr)
                if refrec.first <= ptr <= refrec.last
                    return (ptr - refrec.first, id)
                else
                    return fallback(ptr)
                end
            end
        end
        id += 1
    end
    return accessid
end

function Base.show(io::IO, ::MIME"text/plain", table::AccessRecordTable)
    print(io, MemoryAccesses)
    print(io, ".table()")
    println(io)
    print(io, "  #records: ", length(table.access))
    println(io)
    print(io, "  duration: ", table.time[end] - table.time[1], " ns")
end

const COLUMN_NAMES = fieldnames(AccessRecordTable)
const COLUMN_TYPES = Tuple{fieldtypes(AccessRecordTable)...}

Tables.istable(::Type{AccessRecordTable}) = true
Tables.columnaccess(::Type{AccessRecordTable}) = true
Tables.columns(table::AccessRecordTable) = table
Tables.schema(::AccessRecordTable) = Tables.Schema(COLUMN_NAMES, COLUMN_TYPES)
