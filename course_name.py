import requests, pickle, csv
import bs4 as bs


# first run get_codes.py to generate the dict of LiTH course codes found in 'course_codes.p'

def get_course_name(course_code):
    res = requests.get("http://www4.student.liu.se/tentaresult/en/?kurskod=" + course_code + "&search=Search")
    try:
        res.raise_for_status()
    except Exception as e:
        print("{} raised an exception: {}".format(course_code, e))

    soup = bs.BeautifulSoup(res.text, "lxml")

    # get tables from course's results/grades page
    tables = soup.find_all("table")[4:5][0].text.split(":")
    exam_name = tables[1].split(" ")[:-2]
    exam_name = " ".join(exam_name).strip()
    print(exam_name)