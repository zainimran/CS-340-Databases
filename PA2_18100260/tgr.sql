--TRIGGER 1
CREATE OR REPLACE TRIGGER trg_maxbooks
    BEFORE INSERT ON Issue
    FOR EACH ROW

    DECLARE
        books_issued number;
        borrower_status Borrower.status%TYPE;
    BEGIN
        SELECT count(*) INTO books_issued
        FROM Issue
        WHERE borrower_id = :NEW.borrower_id AND return_date IS NULL;
        
        SELECT status INTO borrower_status
        FROM Borrower
        WHERE borrower_id = :NEW.borrower_id;

        IF((borrower_status = 'faculty' AND books_issued > 2) OR (borrower_status = 'student' AND books_issued > 1)) THEN
            raise_application_error(-20001, 'Cannot Issue: Max books allowed exceeded');
        END IF;
    END trg_maxbooks;
/

--TRIGGER 2
CREATE OR REPLACE TRIGGER trg_issue
    AFTER INSERT ON Issue
    FOR EACH ROW
    
    BEGIN
        UPDATE  Books
        SET     status = 'issued'
        WHERE   book_id = :NEW.book_id;
    END trg_issue;
/

--TRIGGER 3
CREATE OR REPLACE TRIGGER trg_notissue
    AFTER UPDATE OF return_date ON Issue
    FOR EACH ROW

    BEGIN
        UPDATE  Books
        SET     status = 'not_issued'
        WHERE   book_id = :OLD.book_id;
    END trg_notissue;
/

        