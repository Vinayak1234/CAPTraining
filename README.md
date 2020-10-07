## CAPTraining

#### Download the CAPTraining java project from git

<code>
  git clone https://github.com/Vinayak1234/CAPTraining.git 
  
  cd projects/CAPTraining
</code>

#### 1. Create CAPTraining java project
<code>
 mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining  

</code>

1. Create schema.cds under CAPTraining>db  for creating entities.

 ```
  
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

```

2. Create Admin-Service.cds under CAPTraining>srv for creating services.

```
using { sap.ibso.captraining as my } from '../db/schema';

service AdminService {

    entity Books as projection on my.Books;

    entity Authors as projection on my.Authors;
}
```

3. Remove existing dependencies and add below mentioned dependencies to CAPTraining>srv>pom.xml.

```

<dependencies>
		<dependency>
			<groupId>com.sap.cds</groupId>
			<artifactId>cds-starter-spring-boot-odata</artifactId>
		</dependency>

    <dependency>
       <groupId>com.sap.cds</groupId>
       <artifactId>cds-feature-hana</artifactId>
    </dependency>

		<dependency>
			<groupId>org.xerial</groupId>
			<artifactId>sqlite-jdbc</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>

    <dependency>
          <groupId>com.sap.cds</groupId>
          <artifactId>cds-feature-cloudfoundry</artifactId>
    </dependency>
        
	</dependencies>
  
```


#### Seup SQLITE for local development:

1. Install the sqlite

    `npm install --save-dev sqlite3`

2. Deploy the DB objects to local sqlite

    `cds deploy --to sqlite`

3. Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

    `mvn spring-boot:run`
    

#### Seup hana to deploy to cf:

1. Execute the below command to add configuration for SAP HANA deployment

    `cds add hana`

2. Execute the below command to add an mta.yaml file out of CDS models and config

    `cds add mta`
    
3. Remove the production params from build-parameters

    From:
    ```
    build-parameters:
      before-all:
       - builder: custom
         commands:
          - npm install --production
          - npx -p @sap/cds-dk cds build --production
    ```

    Change to:

    ```
    build-parameters:
      before-all:
       - builder: custom
         commands:
          - npm install
          - npx cds build
    ```

3. Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

    `mvn spring-boot:run`


