from bs4 import BeautifulSoup
import json
import tqdm
import time
from requests_tor import RequestsTor

data = {
    "data": []
}

req = RequestsTor()

for page in range(0, 5):
    url = f"https://hh.ru/search/vacancy?text=python+разработчик&clusters=true&ored_clusters=true&enable_snippets" \
          f"=true&page={page}&hhtmFrom=vacancy_search_list "
    resp = req.get(url)

    soup = BeautifulSoup(resp.text, "lxml")
    tags = soup.find_all(attrs={"data-qa": "serp-item__title"})
    for it in tqdm.tqdm(tags):
        time.sleep(2)

        url_object = it.attrs["href"]
        resp_object = req.get(url_object)

        soup_object = BeautifulSoup(resp_object.text, "lxml")
        try:
            tag_compensation = soup_object.find(attrs={'data-qa': 'vacancy-salary'}).find(attrs={'data-qa': "vacancy-salary-compensation-type-net"}).text
        except:
            tag_compensation = "None"
        try:
            tag_region = soup_object.find(attrs={'data-qa': 'vacancy-view-link-location'}).find(attrs={'data-qa': "vacancy-view-raw-address"}).text
        except:
            tag_region = "None"
        try:
            tag_experience = soup_object.find(class_='vacancy-description-list-item').find(attrs={'data-qa': "vacancy-experience"}).text
        except:
            tag_experience = 'None'

        data["data"].append({"title": it.text, "salary": tag_compensation, "region": tag_region})
        with open("data.json", "w") as file:
            json.dump(data, file, ensure_ascii=False)
        print(data)
