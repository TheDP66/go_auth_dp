DB_URL=postgresql://root:admin@localhost:5432/auth_dp?sslmode=disable

postgres:
	docker run --name postgres3.17local -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=admin -d postgres:alpine3.17 
	
createdb:
	docker exec -it postgres3.17local createdb --username=root --owner=root auth_dp

dropdb:
	docker exec -it postgres3.17local dropdb auth_dp
	
migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

statik:
	rm -f doc/swagger/*.swagger.json
	statik -src=./doc/swagger -dest=./doc
	
mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/TheDP66/simple_bank_go/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/store.go github.com/TheDP66/simple_bank_go/worker TaskDistributor

redis_standalone:
	docker run --name redis3.17local -p 6379:6379 -d redis:alpine3.17

.PHONY: network postgres postgres_standalone createdb dropdb migrateup migrateup1 migratedown migratedown1 new_migration sqlc test server mock redis_standalone