from conans import ConanFile, CMake


class StatusDesktop(ConanFile):
    name = "status-desktop"
    settings = "os", "compiler", "build_type", "arch"

    requires = "gtest/1.11.0", "nlohmann_json/3.10.5" # "fruit/3.6.0", 

    # cmake_find_package and cmake_find_package_multi should be substituted with CMakeDeps
    # as soon as Conan 2.0 is released and all conan-center packages are adapted
    generators = "CMakeToolchain", "cmake_find_package", "cmake_find_package_multi"

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
