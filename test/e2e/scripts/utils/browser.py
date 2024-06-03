import webbrowser

import requests


def open_link(url):
    webbrowser.open(url)


def get_response(url):
    response = requests.get(
        url)
    return response
