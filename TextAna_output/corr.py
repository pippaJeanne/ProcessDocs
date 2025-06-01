import pandas as pd 
import numpy as num
file = open("TextAna_output/1542_05_M_le_curéX.txt", encoding="utf-8")
data = file.read()
list = data.split(", ")
#print(list)
df = pd.DataFrame(num.matrix(list))
print(df)
corr = df.corr(method="pearson")

print(corr)
