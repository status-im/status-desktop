import ../../../../../app_service/service/bookmarks/service_interface as bookmark_service

# Defines how parent module accesses this module
include ./private_interfaces/module_base_interface
include ./private_interfaces/module_access_interface

# Defines how this module view communicates with this module
include ./private_interfaces/module_view_delegate_interface

# Defines how this controller communicates with this module
include ./private_interfaces/module_controller_delegate_interface
