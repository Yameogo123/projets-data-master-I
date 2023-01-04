
/* 1- Import des fichiers  */
/* import de multi sheet Hospi_2017 */
Libname h17 xlsx "/home/u62482117/TD6/Hospi_2017.xlsx";
/* import de multi sheet Hospi_2018 */
Libname h18 xlsx "/home/u62482117/TD6/Hospi_2018.xlsx";
/* import de multi sheet Hospi_2019 */
Libname h19 xlsx "/home/u62482117/TD6/Hospi_2019.xlsx";
/* affichage */
proc print data=h17."activité globale"n; run;
proc print data=h17.etablissement; run;
proc print data=h17.indicateur; run;
proc print data=h17."lits et places"n; run;



/* 2- description */
proc freq data=h17."activité globale"n;
    table _all_ / missing norow;
run;	
	
	
	
/* 3- comparaison 2019 et 2018 ou 2017*/
/* comparaison 2019 et 2018 */
proc sql;
	select count(*) from h19.etablissement as e19 where e19.finess not in 
	(select e18.finess from h18.etablissement as e18);
quit;
/* comparaison 2019 et 2017 */
proc sql;
	select count(*) from h19.etablissement as e19 where e19.finess not in 
	(select e17.finess from h17.etablissement as e17);
quit;
/* il n'ya aucun nouvel établissement  */



/* 4-  */
/* --comparaison entre les taille de 2017 et de 2018 */
PROC COMPARE  BASE=h17.etablissement COMP=h18.etablissement;
  var taille_MCO taille_M taille_C taille_O;
RUN;
/* --remarque:  No unequal values were found. All values compared are exactly equal
les tailles n'ont pas varié entre ces deux dates */

/* --comparaison entre les taille de 2018 et de 2019 */
PROC COMPARE  BASE=h18.etablissement COMP=h19.etablissement;
  var taille_MCO taille_M taille_C taille_O;
RUN;
/* --remarque: No unequal values were found. All values compared are exactly equal
 les tailles n'ont pas varié entre ces deux dates */



/*5-*/
proc sort data=h17."lits et places"n;
	by finess;
run;
PROC TRANSPOSE DATA=h17."lits et places"n
	OUT=h17t;
	VAR Valeur;
	by finess;
	ID Indicateur;
RUN;
proc sql;
	create table h17exo5 as 
	select t.finess,  
		sum(input(t.CI_AC1, comma9.), input(t.CI_AC5, comma9.)) as taillem, 
		e.taille_M, 
		sum(input(t.CI_AC6, comma9.), input(t.CI_AC7, comma9.)) as taillec, 
		e.taille_C, 
		sum(input(t.CI_AC8, comma9.), input(t.CI_AC9, comma9.)) as tailleo, 
		e.taille_O
	from h17T as t inner join h17.etablissement as e on t.finess=e.finess;
run;
/*  les seuils de taille_M */
proc sql;
	select taille_M, min(taillem) as min, max(taillem) as max from h17exo5
	group by taille_M
	;
run;
/*  les seuils de taille_C */
proc sql;
	select taille_C, min(taillec) as min, max(taillec) as max from h17exo5
	group by taille_C
	;
run;
/*  les seuils de taille_O */
proc sql;
	select taille_O, min(tailleo) as min, max(tailleo) as max from h17exo5
	group by taille_O
	;
run;



/*6  */
/* en se basant sur la question 4 on sait que les tailles sont invariées par rapport aux années*/ 
proc sql;
	create table H as
		select distinct h1.finess, e.cat, h1.indicateur as indicateur, h1.valeur as valeur17, 
			h2.valeur as valeur18, 
			h3.valeur as valeur19 from h17."lits et places"n as h1,
		h18."lits et places"n as h2, h19."lits et places"n as h3, h17.etablissement as e
		where h1.finess= h2.finess and h2.finess= h3.finess and h1.indicateur= h2.indicateur
		and h2.indicateur= h3.indicateur and e.finess=h1.finess
		;
run;
/* on transpose la table*/
proc sort data=H;
	by finess cat;
run;
PROC TRANSPOSE DATA=H
	OUT=H6;
	VAR valeur17 valeur18 valeur19;
	by finess cat;
	ID Indicateur;
RUN;	
/* on groupe par medecine obstretique et chirurgie*/
proc sql;
	create table H61 as 
		select t.finess, t._NAME_,
			sum(input(t.CI_AC1, comma9.), input(t.CI_AC5, comma9.)) as medecine, 
			sum(input(t.CI_AC6, comma9.), input(t.CI_AC7, comma9.)) as chirurgie, 
			sum(input(t.CI_AC8, comma9.), input(t.CI_AC9, comma9.)) as obstétrique
		from H6 as t group by t.cat;
run;



/* 7- */
proc sql;	
	create table exo7 as
		select distinct cat, substr(finess, 1, 2) as newfiness, count(substr(finess, 1, 2)) as etablissement
		from h17.etablissement 
		group by cat order by newfiness;
run;



/* 8- Les 5 premierès lignes sont les établissements avec le plus d'activités en obstrétique */
/* année 2017*/
proc sql /*outobs=5;*/;
	create table exo8a as
		select e.cat as cat , e.rs as nom,
			input(ag.CI_A11, comma9.) as nbAccouchement, 
			input(lp.valeur, comma9.) as nbLitObstretique
		from h17."activité globale"n as ag, 
			h17."lits et places"n as lp, 
			h17.etablissement as e
		where ag.finess=lp.finess and lp.indicateur="CI_AC8" and lp.finess=e.finess
		group by cat order by nbLitObstretique DESC;
run;
/* année 2018*/
proc sql;
	create table exo8b as
		select e.cat as cat , e.rs as nom,
		input(ag.CI_A11, comma9.) as nbAccouchement, 
		input(lp.valeur, comma9.) as nbLitObstretique
		from h18."activité globale"n as ag, 
		h18."lits et places"n as lp, 
		h18.etablissement as e
		where ag.finess=lp.finess and lp.indicateur="CI_AC8" and lp.finess=e.finess
		group by cat order by nbLitObstretique DESC;
run;
/* année 2019*/
proc sql;
	create table exo8c as
		select e.cat as cat , e.rs as nom,
		input(ag.CI_A11, comma9.) as nbAccouchement, 
		input(lp.valeur, comma9.) as nbLitObstretique
		from h19."activité globale"n as ag, 
		h19."lits et places"n as lp, 
		h19.etablissement as e
		where ag.finess=lp.finess and lp.indicateur="CI_AC8" and lp.finess=e.finess
		group by cat order by nbLitObstretique DESC;
run;



/* 9- min et max, par region de la question 8 */
/* pour l'année 2017 */
proc sql;
	create table exo9a as
		select cat, min(nbAccouchement) as min_accouche, 
		max(nbAccouchement) as max_accouche,
		sum(nbAccouchement) as total_accouche,
		sum(nbLitObstretique) as total_obstretique
		from exo8a group by cat;
run;
/* pour l'année 2018 */
proc sql;
	create table exo9b as
		select cat, min(nbAccouchement) as min_accouche, 
		max(nbAccouchement) as max_accouche,
		sum(nbAccouchement) as total_accouche,
		sum(nbLitObstretique) as total_obstretique
		from exo8b group by cat;
run;	
/* pour l'année 2019 */
proc sql;
	create table exo9c as
		select cat, min(nbAccouchement) as min_accouche, 
		max(nbAccouchement) as max_accouche,
		sum(nbAccouchement) as total_accouche,
		sum(nbLitObstretique) as total_obstretique
		from exo8c group by cat;
run; 	
	


/* 10- Calcul de score
le score que l'on propose ici est le rapport entre le nombre d'accouchement de la région
et le nombre de lit en Obstrétique. Plus ce score est grand plus l'établlissement a une
grande importance. POur ce faire on utilise les tables créées à la question 8 */
/* Pour l'année 2017*/
proc score data=exo8a score=scores out=score17;
	var nbAccouchement nbLitObstretique;
	id nom cat;
run;
proc sql;
	create table score17 as 
		select nom, cat, factor1
		from score17 
		where factor1 > 0;
run;
/*ON REMARQUE QUE LES ETABLISSEMENTS IMPORTANT DANS LE DOMAINE DE 
L'OBSTRETIQUE SONT CLASSES DE HAUT EN BAS: AP-HP, HOSPICES CIVILS DE LYON, 	CHU DE LA REUNION,...*/

/* Pour l'année 2018*/
proc score data=exo8b score=scores out=score18;
	var nbAccouchement nbLitObstretique;
	id nom cat;
run;
proc sql;
	create table score18 as 
		select nom, cat, factor1
		from score18 
		where factor1 > 0;
run;
/*ON REMARQUE QUE LES ETABLISSEMENTS IMPORTANT DANS LE DOMAINE DE 
L'OBSTRETIQUE SONT CLASSES DE HAUT EN BAS: AP-HP, HOSPICES CIVILS DE LYON, CH DE CAYENNE,...*/	

/* Pour l'année 2019*/
proc score data=exo8c score=scores out=score19;
	var nbAccouchement nbLitObstretique;
	id nom cat;
run;
proc sql;
	create table score19 as 
		select nom, cat, factor1
		from score19 
		where factor1 > 0;
run;
/*ON REMARQUE QUE LES ETABLISSEMENTS IMPORTANT DANS LE DOMAINE DE 
L'OBSTRETIQUE SONT CLASSES DE HAUT EN BAS: AP-HP, HOSPICES CIVILS DE LYON, 	CHU DE LA REUNION,...*/	



/* 11- comparison of the score of the 3 years*/
proc sql;
	create table comparescore as
	select s1.nom, s1.cat, (s2.factor1-s1.factor1) + (s3.factor1-s2.factor1) as diff_score
	from score17 as s1 
	inner join score18 as s2 on s1.nom=s2.nom
	inner join score19 as s3 on s1.nom=s3.nom
	order by diff_score ;
run;
/* lets select the hospitals with evolution of score between -0.1 and 0.1 */
proc sql;
	select nom, diff_score 
	from comparescore 
	where diff_score between -0.1 and 0.1
	order by diff_score ;
run;
/* On remarque que CH HENRI DUFFAUT AVIGNON a une difference de 
score null donc son score reste stable sur les 3 ans. 
Aussi tous les autres établissements  
sont à 0.1 près du score null donc il peuvent être considéré 
comme stable sur un intervalle de rejet de 10%
*/



/*il suffit de grouper nos scores par categorie */
/*12 */
/*2017*/
proc sql;
	create table exo11a as
	select cat, sum(score) as score
	from score17
	group by cat;
run;
/*2018*/
proc sql;
	create table exo11b as
	select cat, sum(score) as score
	from score18
	group by cat;
run;
/*2019*/
proc sql;
	create table exo11c as
	select cat, sum(score) as score
	from score19
	group by cat;
run;

/*Puis on les rassemble pour les 3 ans et on trouve le score*/
proc sql;
	create table regionScore as
	select s1.cat, (s2.score-s1.score) + (s3.score-s2.score) as diff_score
	from exo11a as s1 
	inner join exo11b as s2 on s1.cat=s2.cat
	inner join exo11c as s3 on s1.cat=s3.cat
	;
run;
/*On remarque que le CHR Centre Hospitalier Régional a un score plus faible que les autres.
*/






