from bs4 import BeautifulSoup


def remove_tags(html):
    # Handle None or empty input
    if html is None:
        return ""
    
    # Convert to string if not already
    html_str = str(html)
    
    # If empty string, return empty
    if not html_str.strip():
        return ""
    
    # parse html content
    soup = BeautifulSoup(html_str, "html.parser")

    for data in soup(['style', 'script']):
        # Remove tags
        data.decompose()

    # return data by retrieving the tag content
    return ' '.join(soup.stripped_strings)
