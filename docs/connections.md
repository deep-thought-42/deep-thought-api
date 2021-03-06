# Connections

A connection represents how a application will connection to a database. This connection should has a way to localize model and authenticate

## API

A connection has a complete CRUD endpoint following a rest convension.

Query Params:

    ?namespace=xxx if not defined, will use user namespace as default

    GET /connections/types # retrive a connections types metadata information
    
    status: 200
    [
        {
            "type": "MySQL",
            "fields": {
                "name": {"type": "string", "required": true},
                "host": {"type": "string", "required": true},
                "port": {"type": "interger", "required": true, "default": 3306},
                "username": {"type": "string"},
                "password": {"type": "string"}
            }
        }
    ]
    
    GET /connections # get connections
    
    status: 200
    [
        {"id": "xxx", "name": ...}
    ]

    POST /connections # create a new connection
    {
        "name": "NEW MySQL",
        "type": "MySQL",
        "host": "localhost"
    }

    status: 201
    {
        "id": "xxx",
        "name": "NEW MySQL",
        "type": "MySQL",
        "host": "localhost",
        "port": 3306,
        "username": nil,
        "namespace_id": "xxx",
        "created_at": "2019-06-22T22:31:11+00:00",
        "updated_at": "2019-06-22T22:31:12+00:00"
    }

    GET /connections/:id # get one connection

    status: 200
    {
        "id": "xxx",
        "name": "NEW MySQL",
        "type": "MySQL",
        "host": "localhost",
        "port": 3306,
        "username": nil,
        "namespace_id": "xxx",
        "created_at": "2019-06-22T22:31:11+00:00",
        "updated_at": "2019-06-22T22:31:12+00:00"
    }

    PATCH /connections/:id # update a model
    {
        "name": "NEW MYSQL 2", "namespace_id": "yyy"
    }

    status: 200
    {
        "id": "xxx",
        "name": "NEW MySQL 2",
        "type": "MySQL",
        "host": "localhost",
        "port": 3306,
        "username": nil,
        "namespace_id": "yyy",
        "created_at": "2019-06-22T22:31:11+00:00",
        "updated_at": "2019-06-22T22:31:12+00:00"
    }

    DELETE /connections/:id # to remove a connection
    
    status: 204


    GET /connections/:id/databases
    
    status: 200
    [
        {
            "name": "database_name"
        }
    ]

    GET /connections/:id/databases/:database_name/tables

    status: 200
    [
        {
            "name": "table_name"
        }
    ]

    GET /connections/:id/databases/:database_name/tables/:table_name/describe

    status: 200
    [
        {
            "name": "id",
            "type": "int(11)"
        }
    ]

