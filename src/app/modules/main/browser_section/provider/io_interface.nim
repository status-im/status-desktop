# Defines how parent module accesses this module
include ./private_interfaces/module_base_interface
include ./private_interfaces/module_access_interface

# Defines how this module view communicates with this module
include ./private_interfaces/module_view_delegate_interface
