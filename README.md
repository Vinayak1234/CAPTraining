## CAP Java Custom Event Handler

#### Download the CAPTraining java project from git

<code>
  git clone https://github.com/Vinayak1234/CAPTraining.git 
  
  cd projects/CAPTraining
</code>

Or you can follow the below steps to create and run/deploy this hands-on exercise.

#### 1.  Create CAPTraining java project
To create CAPTraining project navigate to projects folder and execute the below maven command.

<code>
 mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining  

</code>

1. Create the schema.cds under CAPTraining>db  for creating entities.

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

2. Create Admin-Service.cds under CAPTraining>srv for creating admin services.

```
using { sap.ibso.captraining as my } from '../db/schema';

service AdminService {

    entity Books as projection on my.Books;

    entity Authors as projection on my.Authors;
}

```

3. Create custom handler BookServiceHandler  CAPTraining>srv>src>main>java>com>sap>cap>CAPTraining>handler

```


package com.sap.cap.CAPTraining.handler;

import java.util.List;

import com.sap.cds.Result;
import com.sap.cds.ql.Select;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;
import com.sap.cds.services.cds.CdsService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import cds.gen.sap.ibso.captraining.Books;
import cds.gen.sap.ibso.captraining.Books_;


@Component
@ServiceName("AdminService")
public class BookServiceHandler  implements EventHandler{

    private static final Logger LOG = LoggerFactory.getLogger(BookServiceHandler.class.getName());

    private PersistenceService persistenceService;

     @Autowired
	public BookServiceHandler(PersistenceService persistenceService) {
		this.persistenceService = persistenceService;

	}

    @Before(event = CdsService.EVENT_CREATE, entity = "AdminService.Books")
    public void validateBooks(List<Books> books) {
        LOG.info("Inside the validateBooks");

        for (Books bk : books) {
            Result result = this.persistenceService.run(Select.from(Books_.class).where(b -> b.ID().eq(bk.getId())));
            Long count = result.rowCount();
            if(count > 0){
                  throw new ServiceException(ErrorStatuses.NOT_ACCEPTABLE, "CAPJavaTraining.BookDetailsExists");
            }            
        }   
    }
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


#### 2. Seup SQLITE for local development:

1. Install the sqlite

    `npm install --save-dev sqlite3`

2. Build cds objects

    `cds build/all`

3. Deploy the DB objects to local sqlite

    `cds deploy --to sqlite`

4. Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

    `mvn spring-boot:run`
    

#### 3. Seup hana and deploy the project to cf:

1. Execute the below command to add configuration for SAP HANA deployment

    `cds add hana`

2. Execute the below command to add an mta.yaml file out of CDS models and config. The file will be created under project root folder (CAPTraining/mta.yaml)

    `cds add mta`
    
3. Remove the production params from mta.yaml (CAPTraining/mta.yaml) file build-parameters since we will be deploying the mtar file to our dev or test instance.

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

3. Build the project from terminal, that will generate mtar (CAPTraining_1.0.0.mtar) file under CAPTraining/mta_archives/CAPTraining_1.0.0.mtar

    `mbt build`

4. Deploy the project to CF:

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
     * Authors
     * Books

