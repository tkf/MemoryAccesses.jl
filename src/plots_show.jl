function Base.show(io::IO, mime::MIME, plt::Plot2D)
    show(io, mime, Plots.plot(plt))
    return
end

Base.showable(::MIME, ::Plot2D) = false
Base.showable(::MIME"text/plain", ::Plot2D) = true
Base.showable(::MIME"image/png", ::Plot2D) = true
Base.showable(::MIME"image/jpeg", ::Plot2D) = true
