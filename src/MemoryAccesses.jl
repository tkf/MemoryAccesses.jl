baremodule MemoryAccesses

function record end
function init end
function clear end
function isfull end

function copy end
function view end

function table end

module Internal

using ..MemoryAccesses: MemoryAccesses
import Tables

include("record.jl")
include("table.jl")
include("plotter.jl")

function __init__()
    MemoryAccesses.init()
end

end  # module Internal

end  # baremodule MemoryAccesses
