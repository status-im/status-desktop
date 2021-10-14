# Defines how parent module accesses this module
include ./private_interfaces/module_base_interface
include ./private_interfaces/module_access_interface

# Defines how this module view communicates with this module
include ./private_interfaces/module_view_delegate_interface

# Defines how this controller communicates with this module
include ./private_interfaces/module_controller_delegate_interface

# Defines how submodules of this module communicate with this module
# will be added if needed
include ./private_interfaces/module_provider_delegate_interface
include ./private_interfaces/module_bookmark_delegate_interface
