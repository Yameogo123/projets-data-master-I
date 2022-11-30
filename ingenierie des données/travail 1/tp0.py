import pandas as pd 
import numpy as np

df = pd.read_csv("iris.csv")

#les doublons
dups= df.duplicated()

#affichage des doublons
print("les doublons")
print(df[dups])

#suppression des doublons
df.drop_duplicates(inplace=True)


