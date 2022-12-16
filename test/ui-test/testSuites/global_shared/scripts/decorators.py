import drivers.SquishDriverVerification as verifier
import os
from typing import Dict, Any
from .global_names import mainWindow_RighPanel


def verify_screenshot(func, obj: Dict[str, Any] = mainWindow_RighPanel):
    def inner(*args, **kwargs):
        context = args[0]
        func(*args, **kwargs)
        
        scenario = context.userData["feature_name"].lower().replace(" ", "_")
        step = context.userData["step_name"].lower().replace(" ", "_")
        filename = f"{step}_{'_'.join(args[1:])}"
        path = os.path.join(scenario, filename)
#         verifier.verify_or_create_screenshot(path, obj)
     
    return inner
