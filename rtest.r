data = read.csv("~/python/exam-scraping/exam_results.csv", header = TRUE, 
                sep = ",", dec = ".", fill = TRUE)

#plot(data$institution, data$U)
data.ordered = data[order(data$U), ]

# sum all exam results within a course
courses.u = tapply(c(data$U), data$course_code, FUN=sum)
courses.3 = tapply(c(data$X3), data$course_code, FUN=sum)
courses.4 = tapply(c(data$X4), data$course_code, FUN=sum)
courses.5 = tapply(c(data$X5), data$course_code, FUN=sum)

courses = data.frame(
  U = courses.u,
  X3 = courses.3,
  X4 = courses.4,
  X5 = courses.5
)

# get the fail ratio of each course
courses.fail = apply(courses, 1, function(x) return (x["U"] / sum(x)))
# get the grade 5 ratio of each course
courses.success = apply(courses, 1, function(x) return (x["X5"] / sum(x)))

# plot of grade 5 vs grade U
plot(courses.fail, courses.success, xlab="Percentage of grade U", ylab="Percentage of grade 5")

# ten courses with highest ratio of U's
courses.fail = sort(courses.fail)
courses.top_fail = courses.sorted[(length(courses.fail)-10):length(courses.fail)-1]
cat("\nTop ten courses with highest ratio of U's:\n")
print(courses.top_fail)

# ten courses highest ratio of 5's
courses.success = sort(courses.success)
courses.top_success = courses.success[(length(courses.success)-10):length(courses.success)]
cat("\nTop 10 courses highest ratio of 5's:\n")
print(courses.top_success)

# courses with no fails
courses.no_fail = courses.fail[courses.fail == 0]
cat("\nCourses with 0% fail rate:\n")
print(courses.no_fail)
cat("Total:", length(courses.no_fail), "\n")


# -- fitting a polynomial curve to the data
courses.fractions = courses
courses.fractions$U = apply(courses, 1, function(x) return (x["U"] / sum(x)))
courses.fractions$X3 = apply(courses, 1, function(x) return (x["X3"] / sum(x)))
courses.fractions$X4 = apply(courses, 1, function(x) return (x["X4"] / sum(x)))
courses.fractions$X5 = apply(courses, 1, function(x) return (x["X5"] / sum(x)))

#courses.fractions = courses.fractions[-which(courses.fractions$U == 1), ] # one broken observation/bad data
#courses.fractions = courses.fractions[-which(courses.fractions$X5 > 0.6), ] # testing without 60%+ ratio of grade 5

set.seed(12345)
n = nrow(courses.fractions)
id = sample(1:n, floor(n*0.5))
train = courses.fractions[id,]
test = courses.fractions[-id,]

mse = numeric(6)
for (i in 1:16)
{
  model = lm(formula = X5 ~ poly(U, i), data=train)
  predictions = predict(model, test)
  mse[i] = mean((test$X5 - predictions)^2)
}

# best polynomial fit at i = 2
degree = which(mse==min(mse))
cat("best polynomial at i =",degree)
model = lm(formula = X5 ~ poly(U, degree), data=train)
#summary(model)
preds = predict(model, test)
plot(test$U, test$X5, col="deepskyblue4", xlab="Percentage of grade U", ylab="Percentage of grade 5")
points(test$U, preds, col="red")
legend("bottomright",c("Observ.","Predicted"), 
       col=c("deepskyblue4","red"), lwd=3)