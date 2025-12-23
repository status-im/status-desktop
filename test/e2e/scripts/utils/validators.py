import allure
from urllib.parse import urlparse


@allure.step('Verify community link format')
def verify_community_link_format(link: str, expected_domain: str = 'status.app') -> bool:
    """
    Verify that a community link has the correct format.
    This is more reliable than checking HTTP status codes which may be blocked by bot protection.
    
    Args:
        link: The community link to verify
        expected_domain: Expected domain (default: 'status.app')
    
    Returns:
        True if link format is valid, raises AssertionError otherwise
    """
    assert link, f'Community link should not be empty'
    assert isinstance(link, str), f'Community link should be a string, got {type(link)}'
    
    # Parse the URL
    parsed = urlparse(link)
    
    # Verify it's a valid URL with https scheme
    assert parsed.scheme == 'https', f'Community link should use https scheme, got {parsed.scheme}'
    assert parsed.netloc == expected_domain, f'Community link should be from {expected_domain}, got {parsed.netloc}'
    
    # Verify it's a community link (starts with /c/)
    assert parsed.path.startswith('/c/'), f'Community link should start with /c/, got {parsed.path}'
    
    # Verify it has a path component after /c/
    path_parts = parsed.path.split('/')
    assert len(path_parts) >= 3 and path_parts[1] == 'c' and path_parts[2], \
        f'Community link should have a community identifier after /c/, got {parsed.path}'
    
    return True

