--PROCEDURE 1
CREATE OR REPLACE PROCEDURE pro_print_borrower AS
    borrower_name VARCHAR2(20);
    book_name VARCHAR2(40);
    issue_date DATE;
    days_issued NUMBER;

    CURSOR TCursor IS
        SELECT  BR.name, BK.book_title, I.issue_date
        FROM    Books BK, Borrower BR, Issue I
        WHERE   I.book_id = BK.book_id AND I.Borrower_id = BR.Borrower_id AND I.return_date IS NULL AND I.issue_date < CURRENT_DATE;

    BEGIN
        dbms_output.put_line('Borrower Name' || '    ' || 'Book Title' || '    ' || 'No. of Days');
        dbms_output.put_line('-------------' || '    ' || '----------' || '    ' || '-----------');

        OPEN TCursor;
        LOOP
            FETCH TCursor INTO borrower_name, book_name, issue_date;
            EXIT WHEN TCursor%NOTFOUND;
            days_issued := CURRENT_DATE-issue_date;
            dbms_output.put_line(borrower_name || '    ' || book_name || '    ' || ROUND(days_issued));
        END LOOP;
        CLOSE TCursor;
    END pro_print_borrower;
/

--PROCEDURE 2
CREATE OR REPLACE PROCEDURE pro_print_fine(curr_date IN DATE) AS
    borrower_name VARCHAR2(20);
    b_id NUMBER;
    i_date DATE;
    r_date DATE;
    fine NUMBER := 0;

    CURSOR TCursor IS
        SELECT  BR.name, BK.book_id, I.issue_date, I.return_date
        FROM    Borrower BR, Books BK, Issue I
        WHERE   BR.borrower_id = I.borrower_id AND I.book_id = BK.book_id AND I.borrower_id = BR.borrower_id AND I.issue_date < curr_date;

    BEGIN
        dbms_output.put_line('Borrower Name' || '    ' || 'Book ID' || '    ' || 'Issue Date' || '    ' || 'Fine');
        dbms_output.put_line('-------------' || '    ' || '-------' || '    ' || '----------' || '    ' || '----');

        OPEN TCursor;
        LOOP
            FETCH TCursor INTO borrower_name, b_id, i_date, r_date;
            EXIT WHEN TCursor%NOTFOUND;
            IF r_date IS NULL THEN
                IF (curr_date - i_date > 5) THEN
                    fine := (curr_date - i_date - 5)*5;
                END IF;
            ELSE
                IF (r_date - i_date > 5) THEN
                    fine := (r_date - i_date -5)*5;
                END IF;
            END IF;
            dbms_output.put_line(borrower_name || '    ' || b_id || '    ' || i_date || '    ' || fine);
            fine := 0;
        END LOOP;
        CLOSE TCursor;
    END pro_print_fine;
/
                
--PROCEDURE 3
CREATE OR REPLACE PROCEDURE pro_listborr_mon(br_id IN NUMBER, month IN NUMBER, year IN NUMBER) AS
    br_name VARCHAR2(20);
    b_id NUMBER;
    b_title VARCHAR2(40);
    i_date DATE;
    r_date DATE;
    string_year VARCHAR2(4) := TO_CHAR(year);
    sub_y VARCHAR(2) := SUBSTR(string_year, 3, 2);

    start_date DATE := to_date(TO_CHAR(month, '99') || '/' || TO_CHAR(01, '99') || '/' || sub_y, 'MM/DD/YY');
    end_date DATE := to_date(TO_CHAR(month+1, '99') || '/' || TO_CHAR(01, '99') || '/' || sub_y, 'MM/DD/YY');

    CURSOR TCursor IS
        SELECT  BR.name, BK.book_id, BK.book_title, I.issue_date, I.return_date
        FROM    Borrower BR, Books BK, Issue I
        WHERE   BR.borrower_id = br_id AND I.borrower_id = BR.borrower_id AND I.book_id = BK.book_id AND I.issue_date >= start_date AND I.issue_date < end_date;

    BEGIN
        dbms_output.put_line('Borrower ID' || '    ' || 'Borrower Name' || '    ' || 'Book ID' || '    ' || 'Book Title' || '    ' || 'Issue Date' || '    ' || 'Return Date');
        dbms_output.put_line('-----------' || '    ' || '-------------' || '    ' || '-------' || '    ' || '----------' || '    ' || '----------' || '    ' || '-----------');

        OPEN TCursor;
        LOOP
            FETCH TCursor INTO br_name, b_id, b_title, i_date, r_date;
            EXIT WHEN TCursor%NOTFOUND;
            dbms_output.put_line(br_id || '    ' || br_name || '    ' || b_id || '    ' || b_title || '    ' || i_date || '    ' || r_date);
        END LOOP;
        CLOSE TCursor;
    END pro_listborr_mon;
/

--PROCEDURE 4
CREATE OR REPLACE PROCEDURE pro_listborr AS
    br_name VARCHAR2(20);
    b_id NUMBER;
    i_date DATE;

    CURSOR TCursor IS
        SELECT  BR.name, BK.book_id, I.issue_date
        FROM    Borrower BR, Books BK, Issue I
        WHERE   I.borrower_id = BR.borrower_id AND I.book_id = BK.book_id AND I.return_date IS NULL;

    BEGIN
        dbms_output.put_line('Borrower Name' || '    ' || 'Book ID' || '    ' || 'Issue Date');
        dbms_output.put_line('-------------' || '    ' || '-------' || '    ' || '----------');

        OPEN TCursor;
        LOOP
            FETCH TCursor INTO br_name, b_id, i_date;
            EXIT WHEN TCursor%NOTFOUND;
            dbms_output.put_line(br_name || '    ' || b_id || '    ' || i_date);
        END LOOP;
        CLOSE TCursor;
    END pro_listborr;
/

--PROCEDURE 5
CREATE OR REPLACE PROCEDURE pro_list_popular AS
    a_name VARCHAR2(20);
    num_editions NUMBER;
    year NUMBER := 17;

    BEGIN
        dbms_output.put_line('Month' || '    ' || 'Year' || '    ' || 'Author Name' || '    ' || 'Number of Editions');
        FOR i IN 1..12 LOOP    
            DECLARE
                mostpop_id varchar2(100) := fun_most_popular(i, year);
                v_array apex_application_global.vc_arr2;
                v_string varchar2(2000);
            BEGIN    
                v_array := apex_util.string_to_table(mostpop_id, ',');
                for j in 1..v_array.count loop
                    BEGIN
                        SELECT  A.name, COUNT(BK.edition) INTO a_name, num_editions
                        FROM    Author A, Books BK
                        WHERE   A.author_id = BK.author_id AND BK.book_id = v_array(j)
                        GROUP BY A.name;

                    EXCEPTION
                        WHEN no_data_found THEN
                            raise_application_error(-20005, 'No popular book exists for this month and year');
                    END;
                    dbms_output.put_line(i || '        ' || year || '        ' || a_name || '        ' || num_editions);
                end loop;
            END;
            IF i = 12 THEN
                year := year + 1;
            END IF;
        END LOOP;
    END pro_list_popular;
/
