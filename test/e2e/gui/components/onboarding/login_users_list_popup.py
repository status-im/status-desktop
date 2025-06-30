import driver
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import onboarding_names


class OnboardingLoginUsersPopup(QObject):
    def __init__(self):
        super().__init__(onboarding_names.statusDropdown)
        self.user_login_item = QObject(onboarding_names.userLoginItem)
        self.create_profile_button = Button(onboarding_names.createProfileButton)
        self.login_button = Button(onboarding_names.returningLoginButton)

    def select_user_by_name(self, user_name):
        raw_data = driver.findAllObjects(self.user_login_item.real_name)
        if not raw_data:
            raise ValueError(f"Can't find {user_name} in list of users as the list is empty")
        for _user in raw_data:
            name_label = str(QObject(_user).object.label)
            if name_label == user_name:
                try:
                    QObject(_user).click()
                    return self
                except RuntimeError as e:
                    raise RuntimeError(f'Could not click user with user name "{user_name}": {e}')
        else:
            raise ValueError(f'User "{user_name}" was not found')
