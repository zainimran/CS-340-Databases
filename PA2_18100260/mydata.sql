VARIABLE n VARCHAR2(100)

begin
:n := '';
:n := :n || ' ' || TO_CHAR(fun_issue_book(1, 1, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(2, 2, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(3, 3, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(4, 4, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(5, 5, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(6, 6, to_date('09/10/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(7, 1, to_date('09/11/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(8, 2, to_date('09/15/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(9, 3, to_date('09/13/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(10, 4, to_date('09/14/17','MM/DD/YY')));
:n := :n || ' ' || TO_CHAR(fun_issue_book(11, 10, to_date('09/15/17','MM/DD/YY')));
end;
/
print :n;