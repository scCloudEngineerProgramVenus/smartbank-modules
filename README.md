# smartbank-modules
## How to run on docker
### Create network
```
docker network create name-of-network
```
### Database
```
docker run --name db --network name-of-network -e POSTGRES_PASSWORD=postgres -e POSTGRES_USERNAME=postgres -e POSTGRES_DB=smart-bank-db postgres
```
### Backend
Build jar file
```
mvn clean install
```
Build docker image
```
docker build -t smartbankapi .
```
Run docker image
```
docker run --name api --network name-of-network -p 8080:8080 smartbankapi
```
### Frontend
Build docker image
```
docker build -t smartbankreact .
```
Run on docker
```
docker run --name smartbankreact --network name-of-network -p 3002:3000 smartbankreact
```
Open web browser and access
```
localhost:3002
```
