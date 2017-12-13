import requests, pickle
import bs4 as bs

#### This scraper gets course codes for MedFak and FilFak ####

# MedFak and FilFak doesn't have a service where you can search for all courses that are given by the faculty.
# This scraper searches all the upcoming exams and filters out the course codes, but the set will be incomplete
# since the exams listed are only ones 2 months into the future.

filfak_url = "http://www4.student.liu.se/tentasearch/" \
         "?kurskod=&kursnamn=&datum=0&inst=&fakultet=" \
         "FILL%C4R|ELLER|FILFAK&program=&ort=&part="

medfak_url = "http://www4.student.liu.se/tentasearch/" \
         "?kurskod=&kursnamn=&datum=0&inst=&fakultet=" \
         "MEDFAK|ELLER|HUGEM|ELLER|HU%D6LL&program=&ort=&part="

def get_codes(url, part_limit):
    part = 1
    codes = []
    while (part <= part_limit):
        res = requests.get("{}{}".format(url, part))
        soup = bs.BeautifulSoup(res.text, 'lxml')

        table = soup.find_all('table')
        table_rows = table[2].find_all('tr')

        for elem in table_rows[2:len(table_rows)-7]:
            if any(c.isdigit() for c in elem.text[1:7]):
                codes.append(elem.text[1:7])

        part += 30

    return codes

filfak_codes = get_codes(filfak_url, 331)
print("FilFak: gathered {} course codes".format(len(filfak_codes)))
pickle.dump(filfak_codes, open('filfak-dec-2017.p', 'wb'))

medfak_codes = get_codes(medfak_url, 121)
print("MedFak: gathered {} course codes".format(len(medfak_codes)))
pickle.dump(medfak_codes, open('medfak-dec-2017.p', 'wb'))