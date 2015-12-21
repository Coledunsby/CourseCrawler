# CourseCrawler
uOttawa Course Crawler Application for iOS

This application collects data for TimetablePlanner by crawling the University of Ottawa website to collect sessions, courses and timeslots. The application exports 3 files:

1. Session.json (name, identifier)
2. Course.json (code, name, sessions)
3. Timeslot.json (sessionIdentifier, courseCode, section, activity, place, professor, day)

This data can then be imported to Parse via the Parse Dashboard. Originally I wanted to have the entire process automated however that isn't practical due to Parse 1800 query per minute limit. Over 20000 objects need to be saved. I suppose I could create a script to save them in batches, however it would take over 10 minutes to run if everything is successful. The problem is that there is no way to find out how many queries you have left until you reach the limit. In addition, the requests from the TimetablePlanner application would count towards it also. Given the complexity of the problem, I decided that it was much simpler and faster to just export them to json and upload them manually.

All the logic of the web crawler is in Spider.swift. To run it, simply call `Spider.crawl()`
