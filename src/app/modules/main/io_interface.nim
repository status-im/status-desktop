# Defines how parent module accesses this module
include ./private_interfaces/module_base_interface
include ./private_interfaces/module_access_interface

# Defines how this module view communicates with this module
include ./private_interfaces/module_view_delegate_interface

# Defines how this controller communicates with this module
include ./private_interfaces/module_controller_delegate_interface

# Defines how submodules of this module communicate with this module
include ./private_interfaces/module_chat_section_delegate_interface
include ./private_interfaces/module_app_search_delegate_interface
include ./private_interfaces/module_browser_section_delegate_interface
include ./private_interfaces/module_communities_section_delegate_interface
include ./private_interfaces/module_node_section_delegate_interface


# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.mainDidLoad()
