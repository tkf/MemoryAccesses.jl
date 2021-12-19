baremodule MemoryAccesses

function record end
function init end
function clear end
function isfull end

function reference end

function copy end
function view end

function table end

function location_time end

module Internal

using ..MemoryAccesses: MemoryAccesses

import Tables
using AutoHashEquals: @auto_hash_equals
using Dates: Dates, Period, Microsecond, Nanosecond
using Requires: @require

if !@isdefined(Returns)
    Returns(x) = (_args...; _kwargs...) -> x
end

include("record.jl")
include("reference.jl")
include("table.jl")
include("analysis.jl")
include("plotter.jl")

function __init__()
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plots_show.jl")

    MemoryAccesses.init()
end

end  # module Internal

end  # baremodule MemoryAccesses
