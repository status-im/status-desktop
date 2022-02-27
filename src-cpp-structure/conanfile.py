from conans import ConanFile

class StatusConan(ConanFile):
    name = "status-desktop"
    settings = "os", "compiler", "build_type"
    generators = "cmake"

    def requirements(self):
        self.requires("di/1.2.0")
        self.requires("gtest/1.10.0")