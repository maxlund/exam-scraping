#!/usr/bin/env python3

import requests, pickle, csv
import bs4 as bs

# first run get_codes.py to generate the dict of course codes found in 'course_codes.p'

def get_exam_results(course_code):

    res = requests.get("http://www4.student.liu.se/tentaresult/?kurskod=" + course_code + "&search=S%F6k")

    try:
        res.raise_for_status()
    except Exception as e:
        print(course_code + " raised an exception %s" % (e))

    soup = bs.BeautifulSoup(res.text, "lxml")

    # get tables from course's results/grades page
    tables = soup.find_all("table")[4:5][0].text.split(":")

    # include only course's exam results
    exams = list()
    [exams.append(res.split("\n")) for res in tables[1:] if "tentamen" in res]

    # set up dict for all exam results
    all_dates = dict()

    for ex in exams:
        valid = True
        # get this exam's results, split results into grade/score
        results = [res.split(" ") for res in ex[ex.index("BetygAntal")+1:len(ex)-1]]
        # get this exam's date
        date = ex[0][-10:]

        for res in results:
            if len(res) < 2 or res[0] not in "U345":
                valid = False

        # insert exam results if valid
        if valid:
            all_dates[date] = {res[0]: int(res[1]) for res in results}

    return all_dates

all_codes = pickle.load(open("course_codes.p", "rb"))

all_results = dict()
for institution, levels in all_codes.items():
    all_results[institution] = dict()
    for level, courses in levels.items():
        all_results[institution][level] = dict()
        if len(courses) > 0:
            print("processing {} courses at level {}".format(institution, level))
            for course_code in courses:
                all_results[institution][level][course_code] = get_exam_results(course_code)

f = open("exam_results.csv", "wt")
writer = csv.writer(f)
writer.writerow(("id", "institution", "course_code", "level", "date", "U", "3", "4", "5"))

id = 1
result = dict()
for inst, levels in all_results.items():
    for level, codes in levels.items():
        for code, dates in codes.items():
            for date, grades in dates.items(): # a specific exam processed here
                result = {"U": 0, "3": 0, "4": 0, "5": 0}
                for grade, num_of_people in grades.items():
                    result[grade] = num_of_people
                writer.writerow((id, inst, code, level, date, result["U"], result["3"], result["4"], result["5"]))
                id += 1

f.close()

print("Processed {} exams written to 'exam_results.csv'".format(id))
