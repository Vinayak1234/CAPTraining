
@cds.persistence.exists
entity TF_GET_BOOKDETAILS (AUTHOR_NAME:String(50)){
    key BOOK_ID : Integer;
    TITLE :        String(111);
    DESCR :        String(1111);
    STOCK :        Integer;
    PRICE :        Decimal(9,2);
    AUTHOR_NAME:   String(50);
}