from tkinter import *
from tkinter.messagebox import askokcancel
from Model.Menu import Menu
from Model.Corpus import Corpus
import json
import pickle
from random import randint
from datetime import datetime
import numpy as np
from Controller.controller import *

quest=json.loads(open('file/questions.json', encoding="utf-8").read())["questions"][:]
ans=json.loads(open('file/answers.json', encoding="utf-8").read())["answers"]
questions={i:list(q.values())[0] for i,q in enumerate(quest)}
answers={j:list(q.values())[0] for j,q in enumerate(ans)}
with open('file/doc.pkl', 'rb') as t:
    id2doc = pickle.load(t)
    t.close()
with open('file/aut.pkl', 'rb') as f:
    id2aut = pickle.load(f)
    f.close()


def View():
    LARGEUR = 700
    HAUTEUR = 530
    #window
    fenetre= Tk()
    fenetre.geometry("700x600")
    fenetre.title("moteur de recherche AYMAX")
    fenetre.resizable(width=TRUE, height=TRUE)
    #canvas
    canvas = Canvas(fenetre, width = LARGEUR, height = HAUTEUR, bg = 'white')
    canvas.pack(padx =5, pady =5)
    #initialise corpus
    corpus= Corpus("test", id2aut, id2doc, len(id2doc), len(id2aut))

    #fonction pour fermer la fenètre.
    def quitter():
        res = askokcancel("Quit the application", "Are you sure ?")
        if res:
            fenetre.quit()
            fenetre.destroy()
    #fonction qui retourne les input et output  
    def saisie():
        name=champ.get("1.0", 'end-1c').strip()
        champ.delete("0.0", END)
        if name != '':
            ChatLog.config(state=NORMAL)
            ChatLog.insert(END, "You: " + name + '\n\n')
            ChatLog.config(foreground="#442265", font=("Verdana", 12))
            menu= Menu(questions, answers, name)
            i=menu.score(name)
            j= corpus.score(name)
            if i==5 or i==4:
                res= f"\n3 top documents result : \n\n"
                for k in j:
                    doc= id2doc[k].getText()
                    res+= doc + "\n ------------- \n"
                stat= statistic(name, id2doc, id2aut)
                if stat ==-1:
                    if len(j)==0:
                        res=menu.response(2)
                else:
                    res= stat
            else:
                if i==0:
                    greetings= menu.response(i).split(",")
                    res= greetings[randint(0, len(greetings))]
                elif i==1:
                    res= menu.response(i)
                elif i==2:
                    res= "the current time is "+ str(datetime.now())
                elif i==3:
                    res= "\nthe corpus authors List: \n " + allAuteur(id2aut)
                else:
                    res="the id index is "+str(i)
            #chat log to insert bot answer
            ChatLog.insert(END, "Bot: " + res + '\n\n')
            ChatLog.config(state=DISABLED)
            ChatLog.yview(END)
    
    # création du champ de saisie
    champ = Text(fenetre, bd=0, bg="white", width="100", height="10", font="Arial")
    champ.place(x=5, y=545, height=30, width=300)
    #Create Chat window
    ChatLog = Text(canvas, bd=0, bg="white", height="530", width="600", font="Arial", wrap=WORD)
    ChatLog.config(state=DISABLED)
    #Bind scrollbar to Chat window
    scrollbar = Scrollbar(canvas, command=ChatLog.yview, cursor="heart")
    ChatLog['yscrollcommand'] = scrollbar.set
    scrollbar.place(x=670, y=6, height=500)
    ChatLog.place(x=15, y=8, height=HAUTEUR, width=LARGEUR)
    # création du bouton valider
    recherche = Button(fenetre, text="Rechercher", command=saisie, bd=0, bg="#32de97", activebackground="#3c9d9b", fg='#ffffff')
    recherche.place(x = 400 , y = 550 , width = 100)
    # création du bouton quitter
    quitte = Button(fenetre, text = 'Quitter', bd=0, bg="red", activebackground="#3c9d9b", fg='#ffffff',command = quitter)
    quitte.place(x = 550 , y = 550 , width = 100)
    # lancer la fenètre
    fenetre.mainloop()
    
    
    