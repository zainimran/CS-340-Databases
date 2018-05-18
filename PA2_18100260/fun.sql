--FUNCTION 1
CREATE OR REPLACE FUNCTION fun_issue_book(borr_id IN NUMBER, b_id IN NUMBER, curr_date IN DATE) RETURN NUMBER AS
    temp NUMBER := 0;
    b_status Books.status%TYPE;

    BEGIN
        SELECT  status INTO b_status
        FROM    Books
        WHERE   book_id = b_id;

        IF b_status = 'not_issued' THEN
            INSERT INTO Issue VALUES(b_id, borr_id, curr_date, NULL);
            UPDATE Books SET status = 'issued' WHERE book_id = b_id;
            temp := 1;
        ELSIF b_status = 'issued' THEN
            INSERT INTO Pending_request VALUES(b_id, borr_id, curr_date, NULL);
        END IF;

        RETURN temp;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN temp;
    END fun_issue_book;
/

--Function 2
CREATE OR REPLACE FUNCTION fun_issue_anyedition(borr_id number, b_title varchar2, author_name varchar2, curr_date date) RETURN number AS
    temp number;
    b_id number;

    BEGIN	
        BEGIN
            SELECT B1.book_id INTO b_id
            FROM Books B1, Author A1
            WHERE B1.book_title = b_title AND A1.name = author_name AND A1.author_id = B1.author_id AND B1.status = 'not_issued'
                AND B1.edition =
                    (SELECT MAX(B.edition)
                    FROM Books B , Author A
                    WHERE B.book_title = b_title AND A.name = author_name AND A.author_id = B.author_id AND B.status = 'not_issued');
        
        EXCEPTION
            WHEN no_data_found THEN
                temp := 0;
        END;

        IF temp > 0 THEN
            INSERT INTO Issue VALUES(b_id, borr_id, curr_date, NULL);
            UPDATE Books SET status = 'issued' WHERE book_id = b_id;
            temp := 1;
        ELSE
            BEGIN
                SELECT B.book_id INTO b_id
                FROM Issue I, Books B
                WHERE B.book_title = b_title AND I.book_id = B.book_id AND return_date IS NULL AND rownum = 1
                ORDER BY issue_date;
                
                INSERT INTO Pending_request VALUES(b_id, borr_id, curr_date, NULL);
            
            EXCEPTION
                WHEN no_data_found THEN
                    raise_application_error(-20005, 'Perhaps the book doesnt exist in the library');
            END;
            temp := 0;
        END IF;

        RETURN temp;
    END fun_issue_anyedition;
/

--FUNCTION 3
CREATE OR REPLACE FUNCTION fun_most_popular(month IN NUMBER, year in NUMBER) RETURN VARCHAR2 AS
    start_date date := to_date(TO_CHAR(month, '99') || '/' || TO_CHAR(01, '99') || '/' || TO_CHAR(year, '99'), 'MM/DD/YY');
    end_date date := to_date(TO_CHAR(month+1, '99') || '/' || TO_CHAR(01, '99') || '/' || TO_CHAR(year, '99'), 'MM/DD/YY');
    b_id NUMBER;
    mostPopular_idList VARCHAR2(50) := '';

    CURSOR TCursor IS
        SELECT  book_id
        FROM    Issue
        WHERE   issue_date >= start_date AND issue_date <= end_date
        GROUP BY book_id
        HAVING  Count(*) = (SELECT  MAX(timesIssued)
                            FROM    (SELECT Count(*) AS timesIssued
                                    FROM    Issue
                                    WHERE   issue_date >=start_date AND issue_date < end_date
                                    GROUP BY book_id));
        
    BEGIN   
        OPEN TCursor;
        LOOP
            FETCH TCursor INTO b_id;
            EXIT WHEN TCursor%NOTFOUND;
            mostPopular_idList := mostPopular_idList || TO_CHAR(b_id) || ',';
        END LOOP;
        CLOSE TCursor;

        RETURN mostPopular_idList;
    END fun_most_popular;
/

--FUNCTION 4
CREATE OR REPLACE FUNCTION fun_return_book(b_id IN NUMBER, curr_date IN DATE) RETURN NUMBER AS
    b_id_2 NUMBER;
    temp NUMBER := 0;
    next_burrower NUMBER;

    BEGIN
        BEGIN
            SELECT  book_id INTO b_id_2
            FROM    Issue
            WHERE   book_id = b_id AND return_date is NULL;
            
            EXCEPTION
                WHEN no_data_found THEN
                    RETURN temp;
        END;

        temp := 1;
        UPDATE Issue SET return_date = curr_date WHERE book_id = b_id_2 AND return_date is NULL;
        UPDATE Books SET status = 'not_issued' WHERE book_id = b_id_2;
        
        BEGIN
            SELECT  requester_id INTO next_burrower
            FROM    Pending_request
            WHERE   book_id = b_id_2 AND issue_date is NULL AND rownum = 1 
                    AND request_date = (SELECT  min(request_date)
                                        FROM    Pending_request
                                        WHERE   book_id = b_id_2 AND issue_date is NULL);

            EXCEPTION
                WHEN no_data_found THEN
                    RETURN temp;
        END;

        UPDATE Pending_request SET issue_date = curr_date WHERE requester_id = next_burrower AND book_id = b_id_2;
        INSERT INTO Issue VALUES(b_id_2, next_burrower, curr_date, NULL);
        UPDATE Books SET status = 'issued' WHERE book_id = b_id_2;

        RETURN temp;
    END fun_return_book;
/

--FUNCTION 5
CREATE OR REPLACE FUNCTION fun_renew_book(borr_id IN NUMBER, b_id IN NUMBER, curr_date in DATE) RETURN NUMBER AS
    temp NUMBER := 0;
    b_id_2 NUMBER;

    BEGIN
        BEGIN
            SELECT  book_id INTO b_id_2
            FROM    Issue
            WHERE   book_id = b_id AND borrower_id = borr_id AND return_date IS NULL;
        
        EXCEPTION
            WHEN no_data_found THEN
                RETURN temp;
        END;

        BEGIN
            SELECT  book_id into b_id_2
            FROM    Pending_request
            WHERE   book_id = b_id_2 AND issue_date IS NULL AND ROWNUM = 1;

        EXCEPTION
            WHEN no_data_found THEN
                temp := 1;
        END;
        
        IF temp = 1 THEN
            UPDATE Issue SET issue_date = curr_date WHERE book_id = b_id_2 AND borrower_id = borr_id AND return_date is NULL;
            RETURN temp;
        ELSE
            RETURN temp;
        END IF;
    END fun_renew_book;
/
