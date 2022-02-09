# We cannot have interface defined here, bacause of Nim limitation in terms of
# multiple inheritances, since this service already inherits from QtObject

# Concepts cannot be used also because of other limitation cause we cannot
# forward this class to appropriate submodule, cause Nim doesn't support
# nested types which depends on concepts.

