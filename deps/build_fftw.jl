using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libfftw3"], :libfftw3),
    LibraryProduct(prefix, ["libfftw3f"], :libfftw3f),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/FFTW_jll.jl/releases/download/FFTW-v3.3.9+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/FFTW.v3.3.9.aarch64-linux-gnu.tar.gz", "70a68ce1e89536a8ee8df427de28f527c69d31f28cd223ebf8cf7402f3b45e50"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/FFTW.v3.3.9.aarch64-linux-musl.tar.gz", "a51a44344e0e99ebde48b20495a2c44aeefa51b39a2160932c9cf267d14aa6cf"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/FFTW.v3.3.9.arm-linux-gnueabihf.tar.gz", "2ee40e4d2561f656366eb147213ed483bfd4d3b63ef07359a361ccda48baca94"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/FFTW.v3.3.9.arm-linux-musleabihf.tar.gz", "c869cdf7bf12c4f6d4d3359a1c6f14ec59ac84dc96672495f730a30800489b9e"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/FFTW.v3.3.9.i686-linux-gnu.tar.gz", "651f7d53dea2b95ae26799f352bea8bd4c17e4371c8faeb3cbb37db9d17b2a84"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/FFTW.v3.3.9.i686-linux-musl.tar.gz", "9f731365440b19edb8e462a59174a20c2f27df83ab55a2c1e6e4edcbb40a132d"),
    Windows(:i686) => ("$bin_prefix/FFTW.v3.3.9.i686-w64-mingw32.tar.gz", "644422a04bfa8c74a8cc7b3750083e645a632c80ce03f69a7cc912ee6cf91552"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/FFTW.v3.3.9.powerpc64le-linux-gnu.tar.gz", "ab5f703b110f8af01796e7f31cd11082c7bb27d7184b07f5e8da939dd1b0f2fd"),
    MacOS(:x86_64) => ("$bin_prefix/FFTW.v3.3.9.x86_64-apple-darwin14.tar.gz", "1f4f99aadb78adc4a0d7df10097a1291c478355255bdd61979b5cdd116f56dac"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/FFTW.v3.3.9.x86_64-linux-gnu.tar.gz", "ed7fbfe6abd31ba5e47569ff1ebc6b754d7adfdbc9f27478634de495dbc54d32"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/FFTW.v3.3.9.x86_64-linux-musl.tar.gz", "35babebbb69d0bdcb8865372dcbeee3f5cd690cd470be148afd4ea6cec5015c0"),
    FreeBSD(:x86_64) => ("$bin_prefix/FFTW.v3.3.9.x86_64-unknown-freebsd11.1.tar.gz", "6ff38bce55886dc4d7cf875f17bbec2b2ffa5b5eb54389ef9c5d8461f4e40c82"),
    Windows(:x86_64) => ("$bin_prefix/FFTW.v3.3.9.x86_64-w64-mingw32.tar.gz", "6793204f0d51a99948fa7983d798c2cbfa696df6e2e5452253ad874fe47b3143"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
