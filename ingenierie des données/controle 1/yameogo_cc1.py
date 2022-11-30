import pandas as pd
import numpy as np
from sklearn.feature_selection import VarianceThreshold, SelectKBest, f_classif, RFE
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.impute import SimpleImputer 
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeRegressor
from sklearn.pipeline import Pipeline
from sklearn.metrics import mean_absolute_error
from sklearn.svm import SVR

print("=== Question 1")
chemin=""
Data= pd.read_csv(chemin+"autos_data.csv")
print(Data.head())
print("?")


print("=== Question 2")
Data.replace("?", np.nan, inplace=True)
print(Data.isna().sum())
print("normalized-losses")


print("=== Question 3")
print("la B est la plus appropriée car elle supprime uniquement la colone ayant le plus de données manquantes (ce qui garde la base suffisament grande) tandis que la A supprime toutes les lignes ayant des valeurs manquantes (ce qui reduit les données d'entrée de jeu")
Data.drop(columns=["normalized-losses"], inplace=True)
print("individus= ",Data.shape[0], " variables= ", Data.shape[1])
Data.dropna(inplace=True)
print("individus= ",Data.shape[0], " variables= ", Data.shape[1])


print("=== Question 4")
Doublons= Data.duplicated()
print(Data[Doublons])
Data.drop_duplicates(inplace=True)
print("individus= ",Data.shape[0], " variables= ", Data.shape[1])


print("=== Question 5")
VarTypes=Data.dtypes.name
DataCont, DataDisc= pd.DataFrame(), pd.DataFrame()
NbObs, NbVar= Data.shape
for v in range(NbVar):
    Type=Data.iloc[:,v].dtypes.name
    Name= Data.iloc[:,v].name
    if Type == "int64" or Type == "float64":
        DataCont[Name]= Data.iloc[:,v]
    else:
        DataDisc[Name]= Data.iloc[:,v]
print(DataCont.info())
print(DataDisc.info())


print("=== Question 6")
XCont= DataCont.values
SupVar= VarianceThreshold(threshold=0.5)
SupVar.fit(XCont)
XCont= SupVar.transform(XCont)
print(XCont.mean(axis=0))
print("la commande XCont.mean(axis=0) permet de calculer la moyenne par colone des valeurs de XCont")


print("=== Question 7")
y=DataDisc["price"].astype(float)
print("la commande DataDisc['price'].astype(float) permet de caster le type de la colonne price du dataframe DataDisc qui était un objet en un type float")
DataDisc.drop(columns=["price"])
XDisc= DataDisc.values
print(XDisc)
XCtrain, XCtest, yCtrain, yCtest= train_test_split(XCont, y, test_size=0.2, random_state=123)
XDtrain, XDtest, yDtrain, yDtest= train_test_split(XDisc, y, test_size=0.2, random_state=123)


print("=== Question 8")
ModelsContRef={}
Reg=DecisionTreeRegressor(random_state=123)
ModelsContRef["ContStand"]= Pipeline([("standard", StandardScaler()), ("tree", Reg)])
ModelsContRef["ContNorm"]= Pipeline([("maxmin", MinMaxScaler()), ("tree", Reg)])
for k in ModelsContRef.keys():
    Model= ModelsContRef[k]
    Model.fit(XCtrain, yCtrain)
    ypred=Model.predict(XCtest)
    print("Erreur MAE du modèle ", k, ":", mean_absolute_error(yCtest, ypred))

    
print("=== Question 9")
ModelsDiscReg={}
ModelsDiscReg["DiscSKB"]= Pipeline([("anova", SelectKBest(f_classif, k=7)), ("tree", Reg)])
ModelsDiscReg["DiscRFE"]= Pipeline([("rfe", RFE(SVR(kernel="linear"), n_features_to_select=7)), ("tree", Reg)])


for k in ModelsDiscReg.keys():
    Model= ModelsDiscReg[k]
    Model.fit(XCtrain, yCtrain)
    ypred=Model.predict(XCtest)
    print("Erreur MAE du modèle ", k, ":", mean_absolute_error(yCtest, ypred))






















