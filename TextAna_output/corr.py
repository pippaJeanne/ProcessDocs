import pandas as pd 
import numpy as num
file = open("TextAna_output/1543_fin_MFalaiscsv.txt", encoding="utf-8")
data = file.read()
list = data.split(", ")
#print(list)
df = pd.DataFrame(num.matrix(list))
print(df)
corr = df.corr(method="pearson")

print(corr)
