drop trigger TRG_MAXBOOKS;
drop trigger TRG_ISSUE;
drop trigger TRG_NOTISSUE;

drop FUNCTION FUN_ISSUE_BOOK;
drop FUNCTION FUN_ISSUE_ANYEDITION;
drop FUNCTION FUN_MOST_POPULAR;
drop FUNCTION FUN_RETURN_BOOK;
drop FUNCTION FUN_RENEW_BOOK;

DROP PROCEDURE pro_list_popular;
DROP PROCEDURE pro_listborr;
DROP PROCEDURE pro_listborr_mon;
DROP PROCEDURE pro_print_fine;
DROP PROCEDURE pro_print_borrower;

drop table AUTHOR cascade constraints;
drop table BOOKS cascade constraints;
drop table BORROWER cascade constraints;
drop table ISSUE cascade constraints;
drop table PENDING_REQUEST cascade constraints;
