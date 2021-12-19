module RecipesInterop

using ..Internal: AccessRecordTable, MemoryAccesses, Plot2D
using Dates: Microsecond
using RecipesBase

@recipe function plot(plt::Plot2D)
    color --> plt.color.data
    seriestype --> :scatter

    xlabel --> plt.x.title
    ylabel --> plt.y.title
    label --> nothing
    markershape --> :x

    (plt.x.data, plt.y.data)
end

@recipe function plot(table::AccessRecordTable; timeunit = Microsecond)
    MemoryAccesses.location_time(table; timeunit = timeunit)
end

end  # module
