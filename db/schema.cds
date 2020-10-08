namespace sap.ibso.captraining;


entity Books {
  key ID : Integer;
  title  : String(111);
  descr  : String(1111);
  author_ID : Integer;
  stock  : Integer;
  price  : Decimal(9,2);
  author : Association to Authors  on author.ID = author_ID;
}

entity Authors {
  key ID : Integer;
  name   : String(111);
  dateOfBirth  : Date;  
  placeOfBirth : String;  
  books  : Association to many Books on books.author_ID = ID;
}