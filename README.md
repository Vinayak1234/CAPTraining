## CAPTraining

<code>
  git clone https://github.com/Vinayak1234/CAPTraining.git 
  
  cd projects/CAPTraining
</code>

#### Create CAPTraining java project
<code>
 mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining  

</code>

#### Seup SQLITE for local development:

1. Install the sqlite

  `npm install --save-dev sqlite3`

2. Deploy the DB objects to local sqlite

  `cds deploy --to sqlite`

3. Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

   `mvn spring-boot:run`


