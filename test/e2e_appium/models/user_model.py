from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid
import secrets
import hashlib


@dataclass
class WalletAddress:
    address: str
    network: str = "ethereum"
    name: str = "Main Address"
    balance: float = 0.0
    is_primary: bool = True
    created_at: datetime = field(default_factory=datetime.now)

    def __post_init__(self):
        if not self.address:
            raise ValueError("Wallet address cannot be empty")

        if self.network.lower() == "ethereum":
            if not (len(self.address) == 42 and self.address.startswith("0x")):
                raise ValueError(f"Invalid Ethereum address format: {self.address}")

    @classmethod
    def generate_ethereum_address(cls, name: str = "Main Address") -> "WalletAddress":
        random_bytes = secrets.token_bytes(20)
        address = "0x" + random_bytes.hex()
        return cls(
            address=address, network="ethereum", name=name, balance=0.0, is_primary=True
        )


@dataclass
class CryptoWallet:
    wallet_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = "Default Wallet"
    addresses: List[WalletAddress] = field(default_factory=list)
    seed_phrase: Optional[str] = None
    is_backed_up: bool = False
    created_at: datetime = field(default_factory=datetime.now)

    def __post_init__(self):
        if not self.addresses:
            self.addresses.append(
                WalletAddress.generate_ethereum_address("Main Address")
            )

    def add_address(self, address: WalletAddress) -> None:
        if address.is_primary:
            for addr in self.addresses:
                addr.is_primary = False
        self.addresses.append(address)

    def get_primary_address(self) -> Optional[WalletAddress]:
        for address in self.addresses:
            if address.is_primary:
                return address
        return self.addresses[0] if self.addresses else None

    def get_addresses_by_network(self, network: str) -> List[WalletAddress]:
        return [
            addr for addr in self.addresses if addr.network.lower() == network.lower()
        ]


@dataclass
class UserProfile:
    display_name: str
    bio: Optional[str] = None
    avatar_path: Optional[str] = None
    status_message: Optional[str] = None
    is_public: bool = True
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)

    def __post_init__(self):
        if not self.display_name or len(self.display_name.strip()) == 0:
            raise ValueError("Display name cannot be empty")

        if len(self.display_name) > 50:
            raise ValueError("Display name cannot exceed 50 characters")

    def update_display_name(self, new_name: str) -> None:
        if not new_name or len(new_name.strip()) == 0:
            raise ValueError("Display name cannot be empty")

        self.display_name = new_name.strip()
        self.updated_at = datetime.now()


@dataclass
class User:
    user_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    profile: UserProfile = field(default_factory=lambda: UserProfile("Test User"))
    password: str = "SecurePass123!"
    chat_key: str = field(default_factory=lambda: secrets.token_hex(32))
    crypto_wallet: CryptoWallet = field(default_factory=CryptoWallet)

    private_key: Optional[str] = field(default_factory=lambda: secrets.token_hex(32))
    recovery_phrase: Optional[str] = None
    pin_code: Optional[str] = None
    biometric_enabled: bool = False

    public_key: str = field(default_factory=lambda: secrets.token_hex(64))
    ens_name: Optional[str] = None
    contact_code: str = field(default_factory=lambda: secrets.token_hex(16))

    is_verified: bool = False
    is_active: bool = True
    account_created_at: datetime = field(default_factory=datetime.now)
    last_login_at: Optional[datetime] = None

    test_context: Dict[str, Any] = field(default_factory=dict)
    device_id: Optional[str] = None
    environment: str = "test"

    def __post_init__(self):
        self._validate_password()
        self._generate_derived_keys()

    def _validate_password(self) -> None:
        if len(self.password) < 8:
            raise ValueError("Password must be at least 8 characters long")

        has_upper = any(c.isupper() for c in self.password)
        has_lower = any(c.islower() for c in self.password)
        has_digit = any(c.isdigit() for c in self.password)

        if not (has_upper and has_lower and has_digit):
            raise ValueError("Password must contain uppercase, lowercase, and digit")

    def _generate_derived_keys(self) -> None:
        chat_seed = f"{self.user_id}:chat_key"
        self.chat_key = hashlib.sha256(chat_seed.encode()).hexdigest()

        contact_seed = f"{self.user_id}:contact_code"
        self.contact_code = hashlib.sha256(contact_seed.encode()).hexdigest()[:16]

    def update_password(self, new_password: str) -> None:
        old_password = self.password
        self.password = new_password
        try:
            self._validate_password()
        except ValueError:
            self.password = old_password
            raise

    def login(self) -> None:
        self.last_login_at = datetime.now()
        self.is_active = True

    def add_wallet_address(self, network: str, name: str = None) -> WalletAddress:
        address_name = name or f"{network.title()} Address"
        if network.lower() == "ethereum":
            new_address = WalletAddress.generate_ethereum_address(address_name)
        else:
            random_bytes = secrets.token_bytes(20)
            address = f"{network[:3]}:" + random_bytes.hex()
            new_address = WalletAddress(
                address=address,
                network=network.lower(),
                name=address_name,
                is_primary=False,
            )

        self.crypto_wallet.add_address(new_address)
        return new_address

    def get_primary_wallet_address(self) -> Optional[WalletAddress]:
        return self.crypto_wallet.get_primary_address()

    def to_test_data(self) -> Dict[str, Any]:
        primary_address = self.get_primary_wallet_address()

        return {
            "user_id": self.user_id,
            "display_name": self.profile.display_name,
            "password": self.password,
            "chat_key": self.chat_key,
            "wallet_address": primary_address.address if primary_address else None,
            "public_key": self.public_key,
            "contact_code": self.contact_code,
            "is_verified": self.is_verified,
            "created_at": self.account_created_at.isoformat(),
            "test_context": self.test_context,
        }

    @classmethod
    def from_test_data(cls, data: Dict[str, Any]) -> "User":
        profile = UserProfile(
            display_name=data.get("display_name", "Test User"),
            bio=data.get("bio"),
            avatar_path=data.get("avatar_path"),
        )

        wallet = CryptoWallet()
        if data.get("wallet_address"):
            primary_address = WalletAddress(
                address=data["wallet_address"],
                network=data.get("network", "ethereum"),
                name="Main Address",
                is_primary=True,
            )
            wallet.addresses = [primary_address]

        return cls(
            user_id=data.get("user_id", str(uuid.uuid4())),
            profile=profile,
            password=data.get("password", "SecurePass123!"),
            chat_key=data.get("chat_key", secrets.token_hex(32)),
            crypto_wallet=wallet,
            public_key=data.get("public_key", secrets.token_hex(64)),
            is_verified=data.get("is_verified", False),
            test_context=data.get("test_context", {}),
        )
