data = read.csv("~/python/exam-scraping/exam_results.csv", header = TRUE, 
                sep = ",", dec = ".", fill = TRUE)

plot(data$institution, data$U)

exam = data[which.max(data$U),]
print(exam)

data.ordered = data[order(data$U),]

data.worst = data.ordered[(nrow(data)-100):nrow(data),]
print(data.worst)

plot(data.worst$U, data.worst$X5)
print(unique(data.worst$course_code)) # courses with top 101 most num of fails

print(length(which(data.worst$level == "G1"))) # 100 courses are G1
print(length(which(data.worst$level == "G2"))) # 1 is G2
print(length(which(data.worst$level == "A")))  # 0 are A


courses = unique(data$course_code)

