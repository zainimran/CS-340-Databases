



CREATE TABLE CATEGORIES
       ( cat number,
       	 subcat	number,
	 subcatname	varchar2(50),
	 catnameshort	varchar2(20),
	 catnamelong	varchar2(100),
	 PRIMARY KEY (cat, subcat) );

CREATE TABLE COMPANY
       ( assignee	number,
      	 compname	varchar2(50),
	 PRIMARY KEY (assignee));



CREATE TABLE PATENT
	( pat_id	number,
	  gyear		number,
	  assignee	number,
	  asscode	number,
	  claims	number,
	  nclass	number,
	  cat		number,
	  subcat	number,
	PRIMARY KEY ( pat_id ),
	FOREIGN KEY (assignee) REFERENCES COMPANY (assignee), 
	FOREIGN KEY (cat, subcat) REFERENCES CATEGORIES (cat, subcat) ) ;

CREATE TABLE INVENTOR
       ( patentnum	number,
       	 lastname	varchar2(20),
	 firstname	varchar2(20),
	 midname	varchar2(10),
	 city		varchar2(25),
	 postate	varchar2(10),
	 country	varchar2(20),
	 invseq		number,
	 PRIMARY KEY (patentnum,lastname, firstname, invseq),
	 FOREIGN KEY (patentnum) REFERENCES PATENT (pat_id)  );


	

CREATE TABLE CITATIONS
       ( citing number,
       	 cited number,
	 FOREIGN KEY (citing) REFERENCES PATENT (pat_id),
	 FOREIGN KEY (cited) REFERENCES PATENT (pat_id),
	 PRIMARY KEY (citing, cited));

	  
