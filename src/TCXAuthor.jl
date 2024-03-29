module Author

using Dates

export TCXAuthor, BuildVersion

"""
    BuildVersion(versionMajor, versionMinor, buildMajor, buildMinor)
Holds version and build information for the TCX Author's software.
"""
struct BuildVersion
    versionMajor::Int
    versionMinor::Int
    buildMajor::Int
    buildMinor::Int
    BuildVersion(versionMajor::Int=0, versionMinor::Int=0, buildMajor::Int=0, buildMinor::Int=0) = new(versionMajor, versionMinor, buildMajor, buildMinor)
end

"""
    TCXAuthor(name, build, langID, partNumber)
Represents the author of the TCX file with identification and build information.
"""
struct TCXAuthor
    name::String
    build::BuildVersion
    langID::String
    partNumber::String
    TCXAuthor(name::String="", build::BuildVersion=BuildVersion(), langID::String="", partNumber::String="") = new(name, build, langID, partNumber)
end

function Base.show(io::IO, bv::BuildVersion)
    print(io, "BuildVersion(VersionMajor=$(bv.versionMajor), VersionMinor=$(bv.versionMinor), BuildMajor=$(bv.buildMajor), BuildMinor=$(bv.buildMinor))")
end

function Base.show(io::IO, author::TCXAuthor)
    print(io, "TCXAuthor(Name=$(author.name), Build=$(author.build), LangID=$(author.langID), PartNumber=$(author.partNumber))")
end

end
