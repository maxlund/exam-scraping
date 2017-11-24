data = read.csv("~/exam-scraping/exam_results.csv", header = TRUE, 
                sep = ",", dec = ".", fill = TRUE)

#plot(data$institution, data$U)
data.ordered = data[order(data$U),]

results.u = tapply(c(data$U), data$course_code, FUN=sum)
results.3 = tapply(c(data$X3), data$course_code, FUN=sum)
results.4 = tapply(c(data$X4), data$course_code, FUN=sum)
results.5 = tapply(c(data$X5), data$course_code, FUN=sum)

print(names(results.5))

tmp = data.frame(
  U = results.u,
  X3 = results.3,
  X4 = results.4,
  X5 = results.5
)

num_fail = apply(tmp, 1, function(x) {return (x["U"] / sum(x))})
sorted = sort(num_fail)
plot(sorted)

print(num_fail["TSIT02"])


top_ten = sorted[(length(sorted)-11):length(sorted)-1]
print(top_ten)