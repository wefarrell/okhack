library('klaR');
frame = read.csv("profile_matrix.csv",header=FALSE)
profile_matrix <- as.matrix(frame)

(cl <- kmodes(frame, 7))

write.csv(cl$cluster, "cluster.csv")
write.csv(cl$modes, "centroids.csv")