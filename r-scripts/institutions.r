library(plotly)

data = read.csv("../exam_results.csv", header = TRUE, 
                sep = ",", dec = ".", fill = TRUE)

get_pie=function(name)
{
  vals = c(inst[name, ]$U, inst[name, ]$X3, inst[name, ]$X4, inst[name, ]$X5)
  pie = plot_ly(inst[name, ], labels = c("U", "3", "4", "5"), values = vals, type = 'pie') %>%
        layout(title = paste("Grade distribution in", name, sep=" "),
               showlegend = TRUE,
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  return (pie)
}

inst = data.frame(
  U = tapply(c(data$U), data$institution, FUN=sum),
  X3 = tapply(c(data$X3), data$institution, FUN=sum),
  X4 = tapply(c(data$X4), data$institution, FUN=sum),
  X5 = tapply(c(data$X5), data$institution, FUN=sum)
)

inst.fractions = data.frame(
  U = apply(inst, 1, function(x) return (x["U"] / sum(x))),
  X3 = apply(inst, 1, function(x) return (x["X3"] / sum(x))),
  X4 = apply(inst, 1, function(x) return (x["X4"] / sum(x))),
  X5 = apply(inst, 1, function(x) return (x["X5"] / sum(x)))
)

print(rownames(inst))

pie = plot_ly(inst, labels = rownames(inst), values = inst$U, type = 'pie') %>%
      layout(title = "Distribution of all U's (fail) handed out by all institutions", showlegend = TRUE,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
pie

pie = plot_ly(inst, labels = rownames(inst), values = inst$X5, type = 'pie') %>%
      layout(title = "Distribution of all 5's (highest grade) handed out by all institutions", showlegend = TRUE,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
pie

cat("\nDistribution of grades within institutions:\n")
print(inst.fractions)

most_fail = inst.fractions[which.max(inst.fractions$U), ]
cat("\nInstitution with highest ratio of U's:\n")
print(most_fail)

least_fail = inst.fractions[which.min(inst.fractions$U), ]
cat("\nInstitution with lowest ratio of U's:\n")
print(least_fail)

most_fives = inst.fractions[which.max(inst.fractions$X5), ]
cat("\nInstitution with highest ratio of 5's:\n")
print(most_fives)

least_fives = inst.fractions[which.min(inst.fractions$X5), ]
cat("\nInstitution with lowest ratio of 5's:\n")
print(least_fives)

IDA = get_pie("IDA")
MAI = get_pie("MAI")
IKE = get_pie("IKE")
IKK = get_pie("IKK")
IEI = get_pie("IEI")
IDA
MAI
IKE
IKK
IEI

cat("\nIKK has had a total of one person failing an exam since 2007. This happend on 2017-10-20 in the course TRTE17: Visuell kultur och designhistoria.
    \nAll exam results within IKK:\n")
print(data[which(data$institution=="IKK"), ])

