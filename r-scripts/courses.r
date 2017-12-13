library(plotly)

data = read.csv("../exam_results.csv", header = TRUE, 
                sep = ",", dec = ".", fill = TRUE)

get_pie=function(name, desc = "")
{
  vals = c(courses[name, ]$U, courses[name, ]$X3, courses[name, ]$X4, courses[name, ]$X5)
  pie = plot_ly(courses[name, ], labels = c("U", "3", "4", "5"), values = vals, type = 'pie',
                marker = list(colors=c("#E41A1C", "#FF7F00", "#377EB8", "#33A02C"))) %>%
        layout(title = paste("Grade distribution in", name, desc, sep=" "),
               showlegend = TRUE,
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  return (pie)
}

# sum all exam results within a specific course
courses = data.frame(
  U = tapply(c(data$U), data$course_code, FUN=sum),
  X3 = tapply(c(data$X3), data$course_code, FUN=sum),
  X4 = tapply(c(data$X4), data$course_code, FUN=sum),
  X5 = tapply(c(data$X5), data$course_code, FUN=sum)
)

# get distribution of each grade within courses
courses.fractions = data.frame(
  U = apply(courses, 1, function(x) return (x["U"] / sum(x))),
  X3 = apply(courses, 1, function(x) return (x["X3"] / sum(x))),
  X4 = apply(courses, 1, function(x) return (x["X4"] / sum(x))),
  X5 = apply(courses, 1, function(x) return (x["X5"] / sum(x)))
)

# plot of grade 5 vs grade U
plot(courses.fractions$U, courses.fractions$X5, xlab="Percentage of grade U", ylab="Percentage of grade 5")

# get the grade U ratio of each course
courses.fail = apply(courses, 1, function(x) return (x["U"] / sum(x)))
# get the grade 5 ratio of each course
courses.success = apply(courses, 1, function(x) return (x["X5"] / sum(x)))

# ten courses with highest ratio of U's
courses.fail = sort(courses.fail)
courses.top_fail = courses.fail[(length(courses.fail)-10):length(courses.fail)-1]
cat("\nTop ten courses with highest ratio of U's:\n")
print(courses.top_fail)

# ten courses highest ratio of 5's
courses.success = sort(courses.success)
courses.top_success = courses.success[(length(courses.success)-11):length(courses.success)-1]
cat("\nTop ten courses highest ratio of 5's:\n")
print(courses.top_success)

# courses with no fails
courses.no_fail = courses.fail[courses.fail == 0]
cat("\nCourses with 0% fail rate:\n")
print(courses.no_fail)
cat("Total:", length(courses.no_fail), "\n")

# -- fitting a polynomial curve to the data

#courses.fractions = courses.fractions[-which(courses.fractions$U == 1), ] # one broken observation/bad data
#courses.fractions = courses.fractions[-which(courses.fractions$X5 > 0.6), ] # testing without 60%+ ratio of grade 5

set.seed(12345)
n = nrow(courses.fractions)
id = sample(1:n, floor(n*0.5))
train = courses.fractions[id, ]
test = courses.fractions[-id, ]

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

# plots for some of the courses with highest ratio of U's
# TATA68 = get_pie("TATA68") # TATA68:Matematisk grundkurs 6.0 hp
# TATA68
# TFYA35 = get_pie("TFYA35") # TFYA35:Molekylfysik 6.0 hp
# TFYA35
# TATA43 = get_pie("TATA43") # TATA43:Flervariabelanalys 8.0 hp
# TATA43
# 
# # ~94% grade 5 in this course:
# NBID61 = get_pie("NBID61") # NBID61:Primate Ethology 9.0 hp
# NBID61

# subset IDA courses
ida_ = data[which(data$institution == "IDA"), ]
ida = data.frame(
  U = tapply(c(ida_$U), ida_$course_code, FUN=sum),
  X3 = tapply(c(ida_$X3), ida_$course_code, FUN=sum),
  X4 = tapply(c(ida_$X4), ida_$course_code, FUN=sum),
  X5 = tapply(c(ida_$X5), ida_$course_code, FUN=sum)
)

# get the grade U ratio of each IDA course
ida.fail = apply(ida, 1, function(x) return (x["U"] / sum(x)))
# get the grade 5 ratio of each IDA course
ida.success = apply(ida, 1, function(x) return (x["X5"] / sum(x)))

# ten courses with highest ratio of U's
ida.fail = sort(ida.fail)
ida.top_fail = ida.fail[(length(ida.fail)-10):length(ida.fail)]
cat("\nTop ten IDA courses with highest ratio of U's:\n")
print(ida.top_fail)

# ten courses highest ratio of 5's
ida.success = sort(ida.success)
ida.top_success = ida.success[(length(ida.success)-10):length(ida.success)]
cat("\nTop ten IDA courses highest ratio of 5's:\n")
print(ida.top_success)

# TDDC75 = get_pie("TDDC75") # TDDC75:Diskreta strukturer 8.0 hp
# TDDC75 = get_pie("TDDD74") # TDDD74:Databaser för bioinformatik 6.0 hp
# TDDD08 = get_pie("TDDD08") # TDDD08:Logikprogrammering 6.0 hp
# TDDD65 = get_pie("TDDD65") # TDDD65:Introduction to the Theory of Computation 6.0 hp
# TDDD65
# TDDD38 = get_pie("TDDD38") # TDDD38:Avancerad programmering i C++ 6.0 hp
# TDDD38
# TDDD07 = get_pie("TDDD07") # TDDD07:Realtidssystem 6.0 hp
# TDDD07
# TBMI26 = get_pie("TBMI26", "Neural Networks and Learning Systems") # 	Neural Networks and Learning Systems
# TBMI26
# TDDB68 = get_pie("TDDB68", "Concurrent Programming and Operating Systems") # 	Concurrent Programming and Operating Systems
# TDDB68
# TDDD38 = get_pie("TDDD38", "Advanced Programming in C++") #  Advanced Programming in C++
# TDDD41 = get_pie("TDDD41", "Data Mining - Clustering and Association Analysis") # 	Data Mining - Clustering and Association Analysis
# TDDD41
# TDDD48 = get_pie("TDDD48", "Automated Planning") # 	Automated Planning
# TDDD48
# TDDE31 = get_pie("TDDE31", "Big Data Analytics") # 	Big Data Analytics
# TDDE31
# TAIU10 = get_pie("TAIU10", "Analys i en variabel")
# TAIU10

