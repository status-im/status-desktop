from typing import Dict, Any, List
from enum import Enum
import json
from pathlib import Path

from .user_model import User, UserProfile, CryptoWallet, WalletAddress


class UserType(Enum):
    BASIC = "basic"
    OWNER = "owner"
    ADMIN = "admin"
    TOKEN_MASTER = "token_master"


class UserFactory:
    def __init__(self):
        self.reset()

    def reset(self) -> "UserFactory":
        self._profile_data = {
            "display_name": "Test User",
            "bio": None,
            "avatar_path": None,
            "status_message": None,
            "is_public": True,
        }
        self._auth_data = {
            "password": "SecurePass123!",
            "pin_code": None,
            "biometric_enabled": False,
            "recovery_phrase": None,
        }
        self._wallet_data = {
            "name": "Default Wallet",
            "primary_address": None,
            "additional_addresses": [],
            "is_backed_up": False,
        }
        self._user_data = {
            "verified": False,
            "ens_name": None,
            "device_id": None,
            "environment": "test",
            "test_context": {},
        }
        return self

    def with_display_name(self, name: str) -> "UserFactory":
        self._profile_data["display_name"] = name
        return self

    def with_bio(self, bio: str) -> "UserFactory":
        self._profile_data["bio"] = bio
        return self

    def with_avatar(self, avatar_path: str) -> "UserFactory":
        self._profile_data["avatar_path"] = avatar_path
        return self

    def with_status_message(self, message: str) -> "UserFactory":
        self._profile_data["status_message"] = message
        return self

    def with_public_profile(self, is_public: bool = True) -> "UserFactory":
        self._profile_data["is_public"] = is_public
        return self

    def with_password(self, password: str) -> "UserFactory":
        self._auth_data["password"] = password
        return self

    def with_pin_code(self, pin: str) -> "UserFactory":
        self._auth_data["pin_code"] = pin
        return self

    def with_biometric(self, enabled: bool = True) -> "UserFactory":
        self._auth_data["biometric_enabled"] = enabled
        return self

    def with_recovery_phrase(self, phrase: str) -> "UserFactory":
        self._auth_data["recovery_phrase"] = phrase
        return self

    def with_wallet_name(self, name: str) -> "UserFactory":
        self._wallet_data["name"] = name
        return self

    def with_primary_address(
        self, address: str, network: str = "ethereum"
    ) -> "UserFactory":
        self._wallet_data["primary_address"] = {
            "address": address,
            "network": network,
            "name": "Main Address",
        }
        return self

    def with_additional_address(
        self, address: str, network: str, name: str = None
    ) -> "UserFactory":
        self._wallet_data["additional_addresses"].append(
            {
                "address": address,
                "network": network,
                "name": name or f"{network.title()} Address",
            }
        )
        return self

    def with_backed_up_wallet(self, backed_up: bool = True) -> "UserFactory":
        self._wallet_data["is_backed_up"] = backed_up
        return self

    def with_verified_status(self, verified: bool = True) -> "UserFactory":
        self._user_data["verified"] = verified
        return self

    def with_ens_name(self, ens_name: str) -> "UserFactory":
        self._user_data["ens_name"] = ens_name
        return self

    def with_device_id(self, device_id: str) -> "UserFactory":
        self._user_data["device_id"] = device_id
        return self

    def with_environment(self, environment: str) -> "UserFactory":
        self._user_data["environment"] = environment
        return self

    def with_test_context(self, context: Dict[str, Any]) -> "UserFactory":
        self._user_data["test_context"].update(context)
        return self

    def create_basic_user(self, name: str = "Basic User") -> "UserFactory":
        return (
            self.reset()
            .with_display_name(name)
            .with_verified_status(False)
            .with_backed_up_wallet(False)
        )

    def create_admin_user(self, name: str = "Admin User") -> "UserFactory":
        return (
            self.reset()
            .with_display_name(name)
            .with_verified_status(True)
            .with_backed_up_wallet(True)
            .with_bio("Administrator user with full access")
        )

    def create_owner_user(self, name: str = "Owner User") -> "UserFactory":
        return (
            self.reset()
            .with_display_name(name)
            .with_verified_status(True)
            .with_backed_up_wallet(True)
            .with_bio("Owner user with ownership privileges")
            .with_test_context(
                {"owner_permissions": True, "can_manage_community": True}
            )
        )

    def create_token_master_user(
        self, name: str = "Token Master User"
    ) -> "UserFactory":
        return (
            self.reset()
            .with_display_name(name)
            .with_verified_status(True)
            .with_backed_up_wallet(True)
            .with_bio("Token master with token management privileges")
            .with_additional_address(
                "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
                "bitcoin",
                "Bitcoin Wallet",
            )
            .with_additional_address(
                "0x742d35CC6634C0532925a3b8D45B1BFA73651234",
                "ethereum",
                "Ethereum Wallet",
            )
            .with_test_context(
                {
                    "token_master_permissions": True,
                    "can_manage_tokens": True,
                    "multi_wallet_enabled": True,
                }
            )
        )

    def build(self) -> User:
        profile = UserProfile(
            display_name=self._profile_data["display_name"],
            bio=self._profile_data["bio"],
            avatar_path=self._profile_data["avatar_path"],
            status_message=self._profile_data["status_message"],
            is_public=self._profile_data["is_public"],
        )

        wallet = CryptoWallet(
            name=self._wallet_data["name"],
            is_backed_up=self._wallet_data["is_backed_up"],
        )

        if self._wallet_data["primary_address"]:
            primary_addr = WalletAddress(
                address=self._wallet_data["primary_address"]["address"],
                network=self._wallet_data["primary_address"]["network"],
                name=self._wallet_data["primary_address"]["name"],
                is_primary=True,
            )
            wallet.addresses = [primary_addr]

        for addr_data in self._wallet_data["additional_addresses"]:
            additional_addr = WalletAddress(
                address=addr_data["address"],
                network=addr_data["network"],
                name=addr_data["name"],
                is_primary=False,
            )
            wallet.add_address(additional_addr)

        user = User(
            profile=profile,
            password=self._auth_data["password"],
            crypto_wallet=wallet,
            pin_code=self._auth_data["pin_code"],
            biometric_enabled=self._auth_data["biometric_enabled"],
            recovery_phrase=self._auth_data["recovery_phrase"],
            is_verified=self._user_data["verified"],
            ens_name=self._user_data["ens_name"],
            device_id=self._user_data["device_id"],
            environment=self._user_data["environment"],
            test_context=self._user_data["test_context"].copy(),
        )

        return user

    def build_multiple(self, count: int) -> List[User]:
        users = []
        base_name = self._profile_data["display_name"]

        for i in range(count):
            self._profile_data["display_name"] = f"{base_name} {i + 1}"
            user = self.build()
            users.append(user)

        self._profile_data["display_name"] = base_name
        return users

    @classmethod
    def create_user_by_type(cls, user_type: UserType, name: str = None) -> User:
        factory = cls()

        type_methods = {
            UserType.BASIC: factory.create_basic_user,
            UserType.OWNER: factory.create_owner_user,
            UserType.ADMIN: factory.create_admin_user,
            UserType.TOKEN_MASTER: factory.create_token_master_user,
        }

        method = type_methods.get(user_type)
        if method:
            if name:
                method(name)
            else:
                method()
        else:
            raise ValueError(f"Unknown user type: {user_type}")

        return factory.build()

    @classmethod
    def load_from_file(cls, file_path: str) -> List[User]:
        path = Path(file_path)
        if not path.exists():
            raise FileNotFoundError(f"User data file not found: {file_path}")

        with open(path, "r") as f:
            data = json.load(f)

        users = []
        for user_data in data:
            user = User.from_test_data(user_data)
            users.append(user)

        return users

    @classmethod
    def save_to_file(cls, users: List[User], file_path: str) -> None:
        path = Path(file_path)
        path.parent.mkdir(parents=True, exist_ok=True)

        data = []
        for user in users:
            data.append(user.to_test_data())

        with open(path, "w") as f:
            json.dump(data, f, indent=2, default=str)


def create_basic_user(name: str = "Basic User") -> User:
    return UserFactory().create_basic_user(name).build()


def create_admin_user(name: str = "Admin User") -> User:
    return UserFactory().create_admin_user(name).build()


def create_owner_user(name: str = "Owner User") -> User:
    return UserFactory().create_owner_user(name).build()


def create_token_master_user(name: str = "Token Master User") -> User:
    return UserFactory().create_token_master_user(name).build()


def create_multi_device_users(
    count: int = 2, base_name: str = "Multi Device User"
) -> List[User]:
    return UserFactory().create_basic_user(base_name).build_multiple(count)
