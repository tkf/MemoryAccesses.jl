baremodule MemoryAccesses

function record end
function init end
function clear end
function isfull end

function reference end

function copy end
function view end

function table end

module Internal

using ..MemoryAccesses: MemoryAccesses

import Tables
using AutoHashEquals: @auto_hash_equals

include("record.jl")
include("reference.jl")
include("table.jl")
include("plotter.jl")

function __init__()
    MemoryAccesses.init()
end

end  # module Internal

end  # baremodule MemoryAccesses
