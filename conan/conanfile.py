from conans import ConanFile

def addCafeSharedCompileOptions(conanfile: ConanFile):
    if conanfile.settings.compiler == "Visual Studio":
        conanfile.cpp_info.cxxflags.append("/utf-8")

class CafeCommon(ConanFile):
    name = "CafeCommon"
    version = "0.1"
    license = "MIT"
    author = "akemimadoka <chino@hotococoa.moe>"
