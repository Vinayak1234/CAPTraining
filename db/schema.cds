namespace sap.ibso.captraining;


entity Books {
  key ID : Integer;
  title  : String(111);
  descr  : String(1111);
  author : Association to Authors;
  stock  : Integer;
  price  : Decimal(9,2);
}

entity Authors {
  key ID : Integer;
  name   : String(111);
  dateOfBirth  : Date;  
  placeOfBirth : String;  
  books  : Association to many Books on books.author = $self;
}