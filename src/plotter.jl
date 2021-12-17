module Plotter

using Dates: Dates, Period, Microsecond, Nanosecond
using RecipesBase
using ..Internal: AccessRecordTable, MemoryAccesses

function rescale(t::Period, unit::Type{<:Period})
    t, u = promote(t, unit(1))
    return t / u
end

@recipe function plot(rec::AccessRecordTable; timeunit = Microsecond)
    color --> rec.threadid
    seriestype --> :scatter

    unitstr = replace(string(timeunit(0)), r"^0 +" => "")
    xlabel --> "Time [$unitstr]"
    ylabel --> "Memory location"
    label --> nothing
    markershape --> :x

    lb = minimum(rec.ptr)
    ys = rec.ptr .- lb
    xs = rescale(Nanosecond(1), timeunit) .* (rec.time .- rec.time[1])

    (xs, ys)
end

end  # module
