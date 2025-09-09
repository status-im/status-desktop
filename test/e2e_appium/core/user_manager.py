from typing import List, Optional

from .models import TestUser


class UserManager:
    def __init__(self, ctx) -> None:
        self._ctx = ctx
        self._profiles: List[TestUser] = []
        self._active_index: Optional[int] = None

    def create(
        self,
        method: Optional[str] = None,
        display_name: Optional[str] = None,
        password: Optional[str] = None,
        seed_phrase: Optional[str] = None,
    ) -> TestUser:
        user = self._ctx.create_user_profile(
            method=method,
            display_name=display_name,
            password=password,
            seed_phrase=seed_phrase,
        )
        self._profiles.append(user)
        self._active_index = len(self._profiles) - 1
        return user

    def add_existing(self, display_name: str, password: str) -> TestUser:
        user = TestUser(
            display_name=display_name, password=password, source="existing_profile"
        )
        self._profiles.append(user)
        if self._active_index is None:
            self._active_index = 0
        return user

    def list(self) -> List[TestUser]:
        return list(self._profiles)

    def active(self) -> Optional[TestUser]:
        if self._active_index is None:
            return None
        return self._profiles[self._active_index]

    def switch(self, index: int, password: Optional[str] = None) -> bool:
        if index < 0 or index >= len(self._profiles):
            raise IndexError("Profile index out of range")
        target = self._profiles[index]
        if not self._ctx.main_app.restart_app():
            return False
        self._ctx._wait_for_app_ready(timeout=20)
        self._ctx._detect_app_state()
        if not self._ctx.app_state.has_existing_profiles:
            self._ctx.logger.warning(
                "No existing profiles detected after restart; cannot switch"
            )
            return False
        if not self._ctx.welcome_back.perform_login(password or target.password):
            return False
        self._active_index = index
        self._ctx.user = target
        self._ctx.app_state.is_main_app_loaded = True
        self._ctx.app_state.current_screen = "main_app"
        return True
