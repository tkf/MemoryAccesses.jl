module Plotter

using Dates: Dates, Microsecond, Nanosecond
using RecipesBase
using ..Internal: AccessRecordTable, MemoryAccesses

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
    xs = Dates.value.(round.(Nanosecond.(rec.time .- rec.time[1]), timeunit))

    (xs, ys)
end

end  # module
