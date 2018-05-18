rem CS 340 Programming Assignment 1
rem Zain Imran
rem s18100260

--QUERY 1
prompt query1;
SELECT  pat_id
FROM    PATENT P
WHERE   ((P.cat, P.subcat) IN (
        SELECT C.cat, C.subcat
        FROM CATEGORIES C
        WHERE C.catnamelong='Drugs AND Medical' OR c.catnamelong='Chemical') 
);

--QUERY 2
prompt query2;
SELECT  DISTINCT I.lastname, I.firstname, I.country, I.postate
FROM    INVENTOR I
WHERE   I.patentnum IN (SELECT P.pat_id
                        FROM    PATENT P
                        WHERE   (P.cat, P.subcat) IN (
                                SELECT C.cat, C.subcat
                                FROM CATEGORIES C
                                WHERE C.catnamelong='Chemical' OR C.catnamelong='Drugs AND Medical'
                        )
);

--QUERY 3
prompt query3;
(SELECT DISTINCT I.lastname, I.firstname, I.country, I.postate
FROM    INVENTOR I
WHERE   I.patentnum IN (SELECT  P.pat_id
                        FROM    PATENT P
                        WHERE   (P.cat, P.subcat) IN (
                                SELECT C.cat, C.subcat
                                FROM CATEGORIES C
                                WHERE C.catnamelong='Chemical'
                        )
))
MINUS
(SELECT DISTINCT I.lastname, I.firstname, I.country, I.postate
FROM    INVENTOR I
WHERE   I.patentnum IN (SELECT  P.pat_id
                        FROM    PATENT P
                        WHERE   (P.cat, P.subcat) IN (
                                SELECT C.cat, C.subcat
                                FROM CATEGORIES C
                                WHERE C.catnamelong<>'Chemical'
                        )
));

--QUERY 4
prompt query4;
SELECT  DISTINCT P.pat_id
FROM    PATENT P
WHERE   P.pat_id IN (
        SELECT  I.patentnum
        FROM    INVENTOR I
        WHERE   I.postate='CA' OR I.postate='NJ'
);

--QUERY 5
prompt query5;
SELECT  DISTINCT P.pat_id
FROM    PATENT P
WHERE   P.pat_id IN (
        SELECT I.patentnum
        FROM INVENTOR I
        WHERE (I.postate='CA' OR I.postate='NJ') AND (I.invseq=1 OR I.invseq=2)
);

--QUERY 6
prompt query6;
SELECT  TEMP.compname, TEMP.num_patents
FROM    (SELECT C.compname, Count(*) as num_patents
        FROM PATENT P, COMPANY C
        WHERE P.assignee=C.assignee
        GROUP BY C.compname) TEMP
WHERE   TEMP.num_patents in (SELECT MAX(TEMP2.num_patents)
                            FROM    (SELECT     C.compname, Count(*) as num_patents
                                    FROM        PATENT P, COMPANY C
                                    WHERE       P.assignee=C.assignee
                                    GROUP BY    C.compname) TEMP2);

--Query 7
prompt query7;
SELECT TEMP.compname, TEMP.num_patents
FROM    (SELECT C.compname, Count(*) as num_patents
        FROM PATENT P, COMPANY C, CATEGORIES CAT
        WHERE (P.assignee=C.assignee AND P.cat=CAT.cat AND P.subcat=CAT.subcat AND CAT.catnamelong='Chemical') 
        GROUP BY C.compname) TEMP
WHERE   TEMP.num_patents in (SELECT  MAX(TEMP2.num_patents)
                            FROM    (SELECT     C.compname, Count(*) as num_patents
                                    FROM        PATENT P, COMPANY C, CATEGORIES CAT
                                    WHERE       (P.assignee=C.assignee AND P.cat=CAT.cat AND P.subcat=CAT.subcat AND CAT.catnamelong='Chemical') 
                                    GROUP BY    C.compname) TEMP2);

--Query 8
prompt query8;
SELECT  TEMP.compname, TEMP.num_patents
FROM    (SELECT     C.compname, Count(*) as num_patents
        FROM        PATENT P, COMPANY C, CATEGORIES CAT
        WHERE       (P.assignee=C.assignee AND P.cat=CAT.cat AND P.subcat=CAT.subcat AND CAT.catnamelong='Chemical') 
        GROUP BY    C.compname
        HAVING Count(*)>=3) TEMP;

--Query 9
prompt query9;
SELECT  *
FROM    (SELECT CAT.subcatname, C.compname, Count(*) as num_patents
        FROM PATENT P, COMPANY C, CATEGORIES CAT
        WHERE (P.assignee=C.assignee AND P.cat=CAT.cat AND P.subcat=CAT.subcat AND CAT.catnamelong='Chemical') 
        GROUP BY CAT.subcatname, C.compname) TEMP
WHERE   (TEMP.subcatname, TEMP.num_patents) IN (SELECT TEMP2.subcatname, MAX(TEMP2.num_patents)
                            FROM    (SELECT     CAT.subcatname, C.compname, Count(*) as num_patents
                                    FROM        PATENT P, COMPANY C, CATEGORIES CAT
                                    WHERE       (P.assignee=C.assignee AND P.cat=CAT.cat AND P.subcat=CAT.subcat AND CAT.catnamelong='Chemical') 
                                    GROUP BY    CAT.subcatname, C.compname) TEMP2
                            GROUP BY TEMP2.subcatname);

--Query 10
prompt query10;
SELECT  *
FROM    (SELECT  I.lastname, I.firstname, Count(*) as nPat
        FROM    INVENTOR I, PATENT P, CATEGORIES C 
        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Electrical AND Electronic'
        GROUP BY I.lastname, I.firstname) T2
WHERE T2.nPat = (SELECT  MAX(nPat)
                FROM    (SELECT  I.lastname, I.firstname, Count(*) as nPat
                        FROM    INVENTOR I, PATENT P, CATEGORIES C 
                        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Electrical AND Electronic'
                        GROUP BY I.lastname, I.firstname) T);

--Query 11
prompt query11;
SELECT  *
FROM    (SELECT C.catnamelong, I.lastname, I.firstname, Count(*) as nPat
        FROM    INVENTOR I, PATENT P, CATEGORIES C 
        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat
        GROUP BY C.catnamelong, I.lastname, I.firstname) T2
WHERE (T2.catnamelong, T2.nPat) IN (SELECT  T.catnamelong, MAX(nPat)
                                FROM    (SELECT  C.catnamelong, I.lastname, I.firstname, Count(*) as nPat
                                        FROM    INVENTOR I, PATENT P, CATEGORIES C 
                                        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat
                                        GROUP BY C.catnamelong, I.lastname, I.firstname) T
                                GROUP BY T.catnamelong);

--Query 12
prompt query12
SELECT  T.compname
FROM    (SELECT DISTINCT CM.compname, C.subcatname
        FROM    COMPANY CM, PATENT P, CATEGORIES C
        WHERE   CM.assignee=P.assignee AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Electrical AND Electronic') T
GROUP BY T.compname 
HAVING  Count(*)=(SELECT  Count(*)
                FROM    CATEGORIES C2
                WHERE   C2.catnamelong='Electrical AND Electronic');

--Query 13
prompt query13
SELECT  T.lastname, T.firstname
FROM    (SELECT DISTINCT I.lastname, I.firstname, C.subcatname
        FROM    INVENTOR I, PATENT P, CATEGORIES C
        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Chemical') T
GROUP BY T.lastname, T.firstname 
HAVING  Count(*) >= 2;

--Query 14
prompt query14
SELECT  *
FROM    (SELECT C.cited as Patent_Id, Count(*) as cite_count
        FROM    CITATIONS C
        GROUP BY C.cited) T2
WHERE T2.cite_count = (SELECT  MAX(T.cite_count)
                FROM    (SELECT Count(*) as cite_count
                        FROM    CITATIONS C 
                        GROUP BY C.cited) T);

--Query 15
prompt query15
SELECT  *
FROM    (SELECT C.catnamelong, CT.cited as Patent_Id, Count(*) as cite_count
        FROM    PATENT P, CITATIONS CT, CATEGORIES C 
        WHERE   P.pat_id=CT.cited AND P.cat=C.cat AND P.subcat=C.subcat
        GROUP BY C.catnamelong, CT.cited) T2
WHERE (T2.catnamelong, T2.cite_count) IN (SELECT  T.catnamelong, MAX(cite_count)
                                FROM    (SELECT  C.catnamelong, CT.cited, Count(*) as cite_count
                                        FROM    PATENT P, CITATIONS CT, CATEGORIES C
                                        WHERE   P.pat_id=CT.cited AND P.cat=C.cat AND P.subcat=C.subcat
                                        GROUP BY C.catnamelong, CT.cited) T
                                GROUP BY T.catnamelong);

--Query 16
prompt query16
SELECT  *
FROM    (SELECT C.citing as Patent_Id, Count(*) as citing_count
        FROM    CITATIONS C
        GROUP BY C.citing) T2
WHERE T2.citing_count = (SELECT   MAX(T.citing_count)
                        FROM    (SELECT Count(*) as citing_count
                                FROM    CITATIONS C 
                                GROUP BY C.citing) T);

--Query 17
prompt query17
SELECT  T33.lastname, T33.firstname, T33.postate, T33.city, T33.invseq, T33.sum_cited
FROM    (SELECT I.lastname, I.firstname, I.postate, I.city, I.invseq, SUM(T.cite_count) as sum_cited
        FROM    (SELECT C.cited, Count(*) as cite_count
                FROM    CITATIONS C 
                GROUP BY C.cited) T INNER JOIN INVENTOR I ON T.cited = I.patentnum
        GROUP BY I.lastname, I.firstname, I.postate, I.city, I.invseq) T33 
WHERE T33.sum_cited =   (SELECT  MAX(T33.sum_cited)
                        FROM    (SELECT  SUM(T.cite_count) as sum_cited
                                FROM    (SELECT C.cited, Count(*) as cite_count
                                        FROM    CITATIONS C 
                                        GROUP BY C.cited) T INNER JOIN INVENTOR I ON T.cited = I.patentnum
                                GROUP BY I.lastname, I.firstname, I.postate, I.city, I.invseq) T33);

--Query 18
prompt query18
SELECT  *
FROM    (SELECT I.lastname, I.firstname, I.city, I.postate, Count(*) as num_patents
        FROM    INVENTOR I
        WHERE   I.invseq=1
        GROUP BY I.lastname, I.firstname, I.city, I.postate)
WHERE   num_patents =   (SELECT  MAX(num_patents)
                        FROM    (SELECT  Count(*) as num_patents
                                FROM    INVENTOR I
                                WHERE   I.invseq=1
                                GROUP BY I.lastname, I.firstname, I.city, I.postate));

--Query 19
prompt query19
SELECT  *
FROM    (SELECT C.catnamelong, I.lastname, I.firstname, I.city, I.postate, Count(*) as num_patents
        FROM    INVENTOR I, PATENT P, CATEGORIES C
        WHERE   I.invseq = 1 AND I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat
        GROUP BY C.catnamelong, I.lastname, I.firstname, I.city, I.postate) T2
WHERE   (T2.catnamelong, T2.num_patents) IN (SELECT  T.catnamelong, MAX(num_patents)
                        FROM    (SELECT C.catnamelong, Count(*) as num_patents
                                FROM    INVENTOR I, PATENT P, CATEGORIES C
                                WHERE   I.invseq=1 AND I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat
                                GROUP BY C.catnamelong, I.lastname, I.firstname, I.city, I.postate) T
                        GROUP BY T.catnamelong);

--Query 20
prompt query20
SELECT  P.pat_id
FROM    PATENT P, CATEGORIES C
WHERE   C.catnamelong='Chemical' AND P.pat_id NOT IN    (SELECT  P.pat_id
                                                        FROM    PATENT P, CATEGORIES C, CITATIONS CT
                                                        WHERE   P.pat_id=CT.cited AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Chemical'
                                                        GROUP BY P.pat_id);

--Query 21
prompt query21
SELECT  C.catnamelong, C.subcatname, Count(DISTINCT P.pat_id)
FROM    CATEGORIES C, INVENTOR I, PATENT P
WHERE   P.cat=C.cat AND P.subcat=C.subcat AND I.patentnum=P.pat_id AND I.postate='CA'
GROUP BY C.catnamelong, C.subcatname;

--Query 22
prompt query22
SELECT  AVG(num_patents)
FROM    (SELECT  C.compname, Count(*) as num_patents
        FROM    COMPANY C, PATENT P, INVENTOR I  
        WHERE   C.assignee=P.assignee AND I.patentnum=P.pat_id AND I.invseq=1 AND C.compname NOT IN     (SELECT  DISTINCT C.compname
                                                                                                        FROM    COMPANY C, INVENTOR I, PATENT P
                                                                                                        WHERE   P.pat_id=I.patentnum AND C.assignee=P.assignee AND I.postate<>'NJ')
        GROUP BY C.compname);

--Query 23
prompt query23
SELECT  C.compname
FROM    COMPANY C, PATENT P  
WHERE   C.assignee=P.assignee
GROUP BY C.compname 
HAVING  Count(*)>(SELECT  AVG(num_patents)
                FROM    (SELECT  C.compname, Count(*) as num_patents
                        FROM    COMPANY C, PATENT P  
                        WHERE   C.assignee=P.assignee AND C.compname NOT IN     (SELECT  DISTINCT C.compname
                                                                                FROM    COMPANY C, INVENTOR I, PATENT P
                                                                                WHERE   P.pat_id=I.patentnum AND C.assignee=P.assignee AND I.postate<>'NY')
                        GROUP BY C.compname));

--Query 24
prompt query24
SELECT  AVG(num_invs)
FROM    (SELECT Count(*) as num_invs
        FROM    INVENTOR I, PATENT P, CATEGORIES C
        WHERE   I.patentnum=P.pat_id AND P.cat=C.cat AND P.subcat=C.subcat AND C.catnamelong='Electrical AND Electronic'
        GROUP BY I.patentnum);

--Query 25
prompt query25
SELECT  DISTINCT I2.lastname, I2.firstname
FROM    INVENTOR I2
WHERE   NOT EXISTS      (SELECT cited
                        FROM CITATIONS C, PATENT P, INVENTOR I
                        WHERE C.cited=I2.patentnum AND P.pat_id=C.cited AND P.pat_id=I.patentnum AND I.lastname=I2.lastname AND I.firstname=I2.firstname);

--ViewA
prompt viewA
CREATE VIEW VIEWA AS
SELECT  i.patentnum, i.firstname, i.lastname, p.gyear, co.compname, c.catnamelong, c.subcatname
FROM    CATEGORIES c, COMPANY co, PATENT p, INVENTOR i
WHERE   i.invseq='1' AND i.patentnum=p.pat_id AND p.cat=c.cat AND p.subcat=c.subcat AND p.assignee=co.assignee;

--ViewB
prompt ViewB
CREATE VIEW VIEWB AS
SELECT  p.assignee, co.compname, c.catnamelong, c.subcatname, T.num_patents
FROM    ((SELECT p.assignee,COUNT(*) as num_patents
        FROM    PATENT p, COMPANY cc
        WHERE   p.assignee = cc.assignee
        GROUP BY p.assignee) T), CATEGORIES c, COMPANY co, PATENT p
WHERE   p.cat=c.cat AND p.subcat=c.subcat AND p.assignee=co.assignee;

