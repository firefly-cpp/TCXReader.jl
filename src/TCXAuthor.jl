module Author

using Dates

export TCXAuthor, BuildVersion

"""
Constructs version information for the TCX file's author.

# Parameters
- `versionMajor`: Major version number.
- `versionMinor`: Minor version number.
- `buildMajor`: Major build number.
- `buildMinor`: Minor build number.
"""
struct BuildVersion
    versionMajor::Int
    versionMinor::Int
    buildMajor::Int
    buildMinor::Int
    BuildVersion(versionMajor::Int=0, versionMinor::Int=0, buildMajor::Int=0, buildMinor::Int=0) = new(versionMajor, versionMinor, buildMajor, buildMinor)
end

"""
    TCXAuthor(name::String, build::BuildVersion, langID::String, partNumber::String)

Represents the author of the TCX file.

# Fields
- `name`: Name of the authoring application or device.
- `build`: A `BuildVersion` struct detailing the software build version.
- `langID`: Language ID of the authoring software.
- `partNumber`: Part number of the authoring software or device.
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
