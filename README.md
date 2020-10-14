## CAP java service with parameterized table function

#### Download the CAPTraining java project from git

```
  git clone https://github.com/Vinayak1234/CAPTraining.git  
  cd projects/CAPTraining
  git checkout capjavaUnit3
```

Or you can follow the below steps to create and run/deploy this hands-on exercise.

To complete this exercise Connect to Cloud connector and add your hanatrial subaccount:
https://localhost:8443/


#### 1.  Create CAPTraining java project
To create CAPTraining project navigate to projects folder and execute the below maven command.

1. Create CAPTraining java project

```

mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining

```

&nbsp;

This will initialize the application using the maven archetype `cds-services-archetype` and create your project as follows:

* The project is named `CAPTraining`.
* The `db` folder stores database-related artifacts.
* The `srv` folder stores your Java application.

&nbsp;

2. Create the schema.cds and cvschema.cds files under CAPTraining>db  for creating entities.

 * schema.cds
 ```
  
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
  name   : String(50);
  dateOfBirth  : Date;  
  placeOfBirth : String;  
  books  : Association to many Books on books.author_ID = ID;
}


```

 * cvschema.cds
 
 ```

@cds.persistence.exists
entity TF_GET_BOOKDETAILS (AUTHOR_NAME:String(50)){
    key BOOK_ID : Integer;
    TITLE :        String(111);
    DESCR :        String(1111);
    STOCK :        Integer;
    PRICE :        Decimal(9,2);
    AUTHOR_NAME:   String(50);
}

@cds.persistence.exists
entity BooksInfo (BOOK_ID : Integer) {
  key id : Integer;
  title : String(111);
  book_author_info : String;
}

 ```
 
 3. Create table function TF_GET_BOOKDETAILS.hdbfunction under CAPTraining/db/src/function/
 
 ```
 
 FUNCTION "TF_GET_BOOKDETAILS"(AUTHOR_NAME NVARCHAR(50))
RETURNS TABLE (
    "BOOK_ID"       INTEGER,
    "TITLE"         NVARCHAR(111),
    "DESCR"         NVARCHAR(1111),
    "STOCK"         INTEGER,
    "PRICE"         DECIMAL,
    "AUTHOR_NAME"   NVARCHAR(50)
)
       LANGUAGE SQLSCRIPT
       SQL SECURITY INVOKER AS
BEGIN

RETURN select
        books.ID as BOOK_ID,
        books.TITLE,
        books.DESCR,
        books.STOCK,
        books.PRICE,
        author.NAME AS AUTHOR_NAME
        FROM SAP_IBSO_CAPTRAINING_BOOKS books
        LEFT OUTER JOIN SAP_IBSO_CAPTRAINING_AUTHORS author 
        ON books.author_ID=author.ID AND author.NAME= :AUTHOR_NAME;
END;
 
 ```
 
 4. Create View BooksInfo.hdbview
 
 ```
 
VIEW BooksInfo(in BOOK_ID Integer) AS
SELECT 
books.ID,
books.TITLE,
'From my HANA view: The book ' || TITLE || ' is authored by ' || author_ID AS BOOK_AUTHOR_INFO
from SAP_IBSO_CAPTRAINING_BOOKS books
left outer join SAP_IBSO_CAPTRAINING_AUTHORS author on author.ID= books.author_ID
WHERE books.ID = :BOOK_ID;

 ```
 
 
5. Create Admin-Service.cds under CAPTraining>srv for creating admin services.

```
using { sap.ibso.captraining as my } from '../db/schema';
using { TF_GET_BOOKDETAILS,BooksInfo } from '../db/cvschema';

service AdminService {

    // Parameterized table function
    @readonly
    entity BookDetails(AUTHOR_NAME:String) as SELECT FROM TF_GET_BOOKDETAILS(AUTHOR_NAME: :AUTHOR_NAME){*};

    // Parameterized view
    entity BooksInfoView (BOOK_ID : Integer) as select from BooksInfo(BOOK_ID: :BOOK_ID) {*};

    entity Books as SELECT FROM my.Books{*};

    entity Authors as SELECT FROM my.Authors{*};
}


```

6. Remove existing dependencies and add below mentioned dependencies to CAPTraining>srv>pom.xml.

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

7. Add cds service milestone versions ``` 1.8.0-m2028 ``` to main pom.xml CAPTraining>pom.xml

```

	<properties>
		<revision>1.0.0</revision>

		<jdk.version>1.8</jdk.version>
		<cds.services.version>1.8.0-m2028</cds.services.version>
		<cds4j.version>1.12.0-m20200707-143819</cds4j.version>
		<spring.boot.version>2.2.3.RELEASE</spring.boot.version>

		<node.version>v10.4.1</node.version>
		<node.url>http://nexus.wdf.sap.corp:8081/nexus/repository/3rd-party.nodejs.dist.proxy/</node.url>
	</properties>
	
	
	<repositories>
		<repository>
		    <id>nexus.build.milestones</id>
		    <name>Nexus Deploy Milestones</name>
		    <url>http://nexus.wdf.sap.corp:8081/nexus/content/repositories/build.milestones/</url>
		</repository>
		<repository>
		    <id>nexus.build.releases</id>
		    <name>Nexus Deploy Snapshots</name>
		    <url>http://nexus.wdf.sap.corp:8081/nexus/content/repositories/build.releases/</url>
		</repository>
		<repository>
		    <id>nexus.build.snapshots</id>
		    <name>Nexus Deploy Snapshots</name>
		    <url>http://nexus.wdf.sap.corp:8081/nexus/content/repositories/build.snapshots/</url>
		</repository>
	    </repositories>

	    <pluginRepositories>
		<pluginRepository>
		    <id>nexus.deploy.releases</id>
		    <name>Nexus Deploy Snapshots</name>
		    <url>http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.releases/</url>
		</pluginRepository>
		<pluginRepository>
		    <id>nexus.deploy.milestones</id>
		    <name>Nexus Deploy Snapshots</name>
		    <url>http://nexus.wdf.sap.corp:8081/nexus/content/repositories/deploy.milestones/</url>
		</pluginRepository>
    </pluginRepositories>

```


#### 2. Setup hana and deploy the project to cf:

1. Execute the below command to add configuration for SAP HANA deployment

    `cds add hana`
    
2. in package.json change the requires part as shwon below to push the project models to cf.

  Change from 
    ```
    "requires": {
      "db": {
        "kind": "sqlite"
      }
    }
    ```
    
    To 
    ```
    "requires": {
      "db": {
        "kind": "sqlite",
        "[production]": {
          "kind": "hana",
          "model": [
            "db/",
            "srv/",
            "app/",
            "schema",
            "services"
          ]
        }
      }
    }
    ```

3. Execute the below command to add an mta.yaml file out of CDS models and config. The file will be created under project root folder (CAPTraining/mta.yaml)

    `cds add mta`
    
4. Remove the production params from mta.yaml (CAPTraining/mta.yaml) file build-parameters since we will be deploying the mtar file to our dev or test instance.

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

5. Build the project from terminal, that will generate mtar (CAPTraining_1.0.0.mtar) file under CAPTraining/mta_archives/CAPTraining_1.0.0.mtar

    `mbt build`

6. Deploy the project to CF:

    `cf deploy ./mta_archives/CAPTraining_1.0.0.mtar`
    
    On successful deploy the terminal console looks like this and copy the service url from console as highlighted below.
      
    	
	Staging application "CAPTraining-srv"...
	Application "CAPTraining-srv" staged
	Starting application "CAPTraining-srv"...
	Application "CAPTraining-srv" started and available at **2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com**
	Skipping deletion of services, because the command line option "--delete-services" is not specified.
	Process finished.
	Use "cf dmol -i 0b8c38fb-0865-11eb-8372-eeee0a9e2566" to download the logs of the process.
 
    Copy the highlighted url to browser.
    
    https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/
    
    That will look like this with the list of services. Click on any service to fetch the details.
    
   ### Welcome to cds-services
   These are the paths currently served …

   ##### /odata/v4/AdminService / $metadata
       * BookDetails
       * BookDetails
       * Authors  
       * Books

#### 4. Test the services:

##### Create Author service:
* URL : https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/odata/v4/AdminService/Authors
* Method :POST

* Payload
```
    { 
     "ID":2, 
     "name":"Author 2",
     "dateOfBirth": "2017-01-01",  
     "placeOfBirth":"Bangalore"
    }
```

##### Create Books service :
* URL : https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/odata/v4/AdminService/Books
* Method :POST

* Payload :

```
{ 
    "ID":2, 
    "title":"book title2",
    "descr": "book title2cdesc",    
    "stock": 10,
    "price": 50,
    "author_ID" : 2
    }

```

##### Get Book details service:
&nbsp;
* URL : https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/odata/v4/AdminService/BookDetails(AUTHOR_NAME='Author 2')/Set
* Method :GET
* Response: &nbsp;
```
{
    "@context": "../$metadata#BookDetails%28'Author%25202'%29/Set",
    "@metadataEtag": "W/\"06867e7a835c0669ec2a7300bdf3902b999a9ec7a5cb91c97612eaab2f880b6b\"",
    "value": [
        {
            "BOOK_ID": 2,
            "TITLE": "book title2",
            "DESCR": "book title2cdesc",
            "STOCK": 10,
            "PRICE": 50,
            "AUTHOR_NAME": "Author 2"
        }
    ]
}
```


##### Get BookInfo View:
* URL : https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/odata/v4/AdminService/BooksInfoView(BOOK_ID=2)/Set
* Method :GET
* Response: &nbsp;

```
{
    "@context": "../$metadata#BooksInfoView%282%29/Set",
    "@metadataEtag": "W/\"180221c86e281e02d4b6eed7e5fb45b0cd06d6a33afbefb318c782515c2eea21\"",
    "value": [
        {
            "id": 2,
            "title": "book title2",
            "book_author_info": "From my HANA view: The book book title2 is authored by Author 2"
        }
    ]
}
```

