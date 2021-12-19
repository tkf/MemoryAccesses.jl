struct Encoding{Data}
    data::Data
    title::String
end

struct Plot2D{Kind,X<:Encoding,Y<:Encoding,Color<:Union{Nothing,Encoding}}
    kind::Kind
    x::X
    y::Y
    color::Color
end

encoding(x) = Encoding(x.data, x.title)

plot2d(kind; x, y, color = nothing) =
    Plot2D(kind, encoding(x), encoding(y), color === nothing ? nothing : encoding(color))

struct LocationTimeKind end
const LocationTimePlot = Plot2D{LocationTimeKind}

function rescale(t::Period, unit::Type{<:Period})
    t, u = promote(t, unit(1))
    return t / u
end

function ascolumntable(table)
    if Tables.columnaccess(table)
        return table
    else
        return Tables.columntable(table)
    end
end

function MemoryAccesses.location_time(table; timeunit = Microsecond)::LocationTimePlot
    table = ascolumntable(table)

    unitstr = replace(string(timeunit(0)), r"^0 +" => "")
    xs = rescale(Nanosecond(1), timeunit) .* (table.time .- table.time[1])

    lb = minimum(table.access)
    ys = table.access .- lb

    zs = table.threadid

    return plot2d(
        LocationTimeKind();
        x = (data = xs, title = "Time [$unitstr]"),
        y = (data = ys, title = "Memory location"),
        color = (data = zs, title = "Thread ID"),
    )
end

function Base.show(io::IO, ::MIME"text/plain", plt::Plot2D)
    print(io, "Plot2D{", nameof(typeof(plt.kind)), ", …}")
    println(io)
    print(io, "  x: ", plt.x.title)
    println(io)
    print(io, "  y: ", plt.y.title)
    if plt.color !== nothing
        println(io)
        print(io, "  color: ", plt.color.title)
    end
    return
end
