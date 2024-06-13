import allure
import requests
import webbrowser

from bs4 import BeautifulSoup


@allure.step('Open link in default browser')
def open_link(url):
    webbrowser.open(url)


@allure.step('Get response')
def get_response(url):
    response = requests.get(
        url)
    return response


@allure.step('Get page content')
def get_page_content(url):
    request = requests.get(url)
    src = request.text
    soup = BeautifulSoup(src, 'html.parser')
    return soup
