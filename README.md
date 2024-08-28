# Echo Application

This is a mock server application built with Ruby on Rails that allows to create, update, delete, and serve custom endpoints.
Project contains few TODOs that I would like to improve in future. 

## Dependencies

- Ruby 3.2.2
- Rails 7.1.3
- SQLite3

## Setup

1. Set ruby version (I use rbenv):
   ```bash
   rbenv local 3.2.2
   
2. Install rails:
   ```bash
   gem install rails -v 7.1.3
   
3. Install dependencies:
   ```bash
   bundle install

4. Set up the database:
   ```bash
   bundle exec rails db:setup

5. Run tests:
   ```bash
   bundle exec rspec spec
   
6. Start the server:
   ```bash
    bundle exec rails s

## Test 

* List endpoints:
   ```bash
   curl --request GET --url http://localhost:3000/endpoints --header 'Accept: application/vnd.api+json'

* Create new endpoint:
   ```bash
   curl --request POST \
    --url http://localhost:3000/endpoints \
    --header 'Accept: application/vnd.api+json' \
    --header 'Content-Type: application/vnd.api+json' \
    --data '{
	 "data": {
		"type": "endpoints",
		"attributes": {
			"verb": "GET",
			"path": "/say/hello",
			"response": {
				"code": 200,
				"headers": {
					"Content-Type": "application/vnd.api+json"
				},
				"body": "{ \"message\": \"Hello, world\" }"
			}
		}
    }
    }'

*  Request created endpoint:
   ```bash
   curl --request GET --url http://localhost:3000/say/hello --header 'Accept: application/json'

* Update endpoint:
   ```bash
   curl --request PATCH \
    --url http://localhost:3000/endpoints/1 \
    --header 'Accept: application/vnd.api+json' \
    --header 'Content-Type: application/vnd.api+json' \
    --data '{
	 "data": {
		"type": "endpoints",
		"attributes": {
			"verb": "GET",
			"path": "/say/hello",
			"response": {
				"code": 200,
				"headers": {
					"Content-Type": "application/vnd.api+json"
				},
				"body": "{ \"message\": \"Hello, world twice\" }"
			}
		}
    }
    }'

* Delete endpoint:
   ```bash
   curl --request DELETE --url http://localhost:3000/endpoints/1 --header 'Accept: application/vnd.api+json'


