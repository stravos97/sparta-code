# Sparta Academy API - Beginner's Guide

A comprehensive REST API for managing Spartans, Courses, and Streams at Sparta Academy. This guide will help you understand and use the API, even if you're new to APIs and web development.

## Table of Contents

1. [What is this API?](#what-is-this-api)
2. [Prerequisites](#prerequisites)
3. [Getting Started](#getting-started)
4. [Architecture Overview](#architecture-overview)
5. [Authentication with JWT](#authentication-with-jwt)
6. [API Endpoints](#api-endpoints)
   - [GET Requests](#get-requests)
   - [POST Requests](#post-requests)
   - [PUT Requests](#put-requests)
   - [DELETE Requests](#delete-requests)
7. [Data Models](#data-models)
8. [Common Use Cases](#common-use-cases)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

## What is this API?

An **API (Application Programming Interface)** is like a waiter in a restaurant - it takes your request, communicates with the kitchen (database), and brings back the response. 

The Sparta Academy API helps you:
- **Manage Spartans**: Create, view, update, and delete student records
- **Manage Courses**: Handle course information and assignments
- **Manage Streams**: Organize different learning paths (like "C# Development", "Java Development")

Think of it as a digital filing system where you can store and retrieve information about students and their courses.

## Prerequisites

Before you start, you'll need:
- **Basic understanding of HTTP** (GET, POST, PUT, DELETE)
- **Command line tool** like Terminal (Mac/Linux) or Command Prompt (Windows)
- **curl** (usually pre-installed) or **Postman** for testing API calls
- **.NET 8 SDK** installed on your machine

## Getting Started

### 1. Start the API Server

```bash
# Navigate to the project directory
cd SpartaAcademyAPI

# Build the project
dotnet build

# Run the API server
dotnet run
```

The API will start running on `http://localhost:5125`

> **Note for macOS Users**: If you encounter .NET version issues, you may need to install and use .NET 8 specifically:
> ```bash
> # Install .NET 8 via Homebrew
> brew install dotnet@8
> 
> # Set up environment variables for .NET 8
> export DOTNET_ROOT="/opt/homebrew/opt/dotnet@8/libexec"
> export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
> 
> # Verify .NET 8 is being used
> dotnet --version  # Should show 8.x.x
> 
> # Then run the API server
> dotnet run
> ```

> **Note: If Port 5125 is Already in Use**: If you get an error saying the port is already in use, you can kill the existing process:
> ```bash
> # Find and kill processes using port 5125
> lsof -ti:5125 | xargs kill -9
> 
> # Alternative: Kill all .NET processes (use with caution)
> pkill -f "dotnet.*SpartaAcademyAPI"
> 
> # Then try running the server again
> dotnet run
> ```

### 2. Test if it's working

Open your browser and go to `http://localhost:5125/swagger` to see the interactive API documentation.

## Architecture Overview

Understanding how the API is structured will help you use it more effectively:

```mermaid
graph TB
    Client[Client Application] --> Controller[Controllers Layer]
    Controller --> Service[Service Layer]
    Service --> Repository[Repository Layer]
    Repository --> Database[(In-Memory Database)]
    
    Controller --> JWT[JWT Authentication]
    Controller --> AutoMapper[AutoMapper]
    Controller --> DTO[Data Transfer Objects]
    
    subgraph "API Structure"
        Controller
        Service
        Repository
    end
    
    subgraph "Supporting Components"
        JWT
        AutoMapper
        DTO
    end
```

**What each layer does:**
- **Controllers**: Handle HTTP requests and responses
- **Service Layer**: Contains business logic
- **Repository Layer**: Manages data access
- **Database**: Stores all the data (uses in-memory database for this demo)

## Authentication with JWT

### What is JWT?
JWT (JSON Web Token) is like a digital ID card that proves you're allowed to access the API. Think of it as a temporary pass that expires after some time.

### Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant AuthService
    participant Database
    
    Client->>API: POST /Auth/login (username, password)
    API->>AuthService: Validate credentials
    AuthService->>AuthService: Check username="sparta", password="global"
    AuthService->>API: Credentials valid
    API->>Client: Return JWT token
    
    Note over Client: Store token for future requests
    
    Client->>API: GET /api/Spartans (with Bearer token)
    API->>API: Validate JWT token
    API->>Database: Fetch Spartans data
    Database->>API: Return data
    API->>Client: Return Spartans list
```

### Step-by-Step: Getting Your JWT Token

#### Step 1: Request a Token
```bash
curl -X POST http://localhost:5125/Auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "sparta", "password": "global"}'
```

#### Step 2: You'll get a response like this:
```json
{
  "token": "YOUR_JWT_TOKEN_WILL_BE_RETURNED_HERE"
}
```

#### Step 3: Copy the token (the long string) and use it in subsequent requests:
```bash
# Use the token in the Authorization header
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" http://localhost:5125/api/Spartans
```

> **Important**: Replace `YOUR_TOKEN_HERE` with the actual token you received!

### Pretty Printing JSON Responses

For better readability, you can pipe curl output through `jq` to format JSON responses:

```bash
# Install jq (if not already installed)
brew install jq  # macOS
# or
sudo apt-get install jq  # Linux

# Pretty print JSON responses
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans | jq '.'

# Example with a real token
curl -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  http://localhost:5125/api/Spartans | jq '.'
```

This will format the JSON output with proper indentation and colors, making it much easier to read.

## API Endpoints

### Request Flow Overview

```mermaid
graph LR
    A[Client Request] --> B{Authentication Required?}
    B -->|Yes| C[Check JWT Token]
    B -->|No| D[Process Request]
    C -->|Valid| D
    C -->|Invalid| E[Return 401 Unauthorized]
    D --> F[Execute Business Logic]
    F --> G[Return Response]
```

### GET Requests
GET requests are used to **retrieve** information. Think of them as "asking for" data.

#### Get All Spartans
```bash
# Request
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans

# Request with pretty printing (recommended)
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans | jq '.'

# Response
[
  {
    "id": 1,
    "firstName": "Michael",
    "lastName": "Johnson",
    "university": "University of Technology",
    "degree": "BSc Computer Science",
    "course": "C# Development",
    "stream": "Software Development",
    "graduated": false,
    "links": [
      {
        "href": "/api/Spartans/1",
        "rel": "self",
        "method": "GET"
      }
    ]
  }
]
```

#### Get Specific Spartan
```bash
# Request
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans/1

# Response
{
  "id": 1,
  "firstName": "Michael",
  "lastName": "Johnson",
  "university": "University of Technology",
  "degree": "BSc Computer Science",
  "course": "C# Development",
  "stream": "Software Development",
  "graduated": false
}
```

#### Get All Courses
```bash
# Request
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Courses

# Response
[
  {
    "id": 1,
    "name": "C# Development",
    "trainer": "Alice Johnson",
    "stream": "Software Development"
  }
]
```

### POST Requests
POST requests are used to **create** new resources. Think of them as "adding" data.

#### Create a New Spartan
```bash
# Request
curl -X POST http://localhost:5125/api/Spartans \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jennifer",
    "lastName": "Williams",
    "university": "Tech University",
    "degree": "MSc Software Engineering",
    "course": {
      "name": "Java Development",
      "trainer": "Sarah Johnson",
      "stream": {
        "name": "Backend Development"
      }
    },
    "graduated": false
  }'

# Response (201 Created)
{
  "id": 34,
  "firstName": "Jennifer",
  "lastName": "Williams",
  "university": "Tech University",
  "degree": "MSc Software Engineering",
  "course": "Java Development",
  "stream": "Backend Development",
  "graduated": false,
  "links": [
    {
      "href": "/api/Spartans/34",
      "rel": "self",
      "method": "GET"
    }
  ]
}
```

### PUT Requests
PUT requests are used to **update** existing resources. Think of them as "editing" data.

#### Update an Existing Spartan
```bash
# Request
curl -X PUT http://localhost:5125/api/Spartans/34 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 34,
    "firstName": "Jennifer",
    "lastName": "Williams",
    "university": "Tech University",
    "degree": "MSc Software Engineering",
    "course": {
      "name": "Java Development",
      "trainer": "Sarah Johnson",
      "stream": {
        "name": "Backend Development"
      }
    },
    "graduated": true
  }'

# Response (204 No Content)
# Success! No response body, but the Spartan has been updated
```

### DELETE Requests
DELETE requests are used to **remove** resources. Think of them as "deleting" data.

#### Delete a Spartan
```bash
# Request
curl -X DELETE http://localhost:5125/api/Spartans/34 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Response (204 No Content)
# Success! The Spartan has been deleted
```

## Data Models

Understanding the data structure helps you create proper requests:

### Entity Relationships

```mermaid
erDiagram
    Spartan ||--|| Course : "belongs to"
    Course ||--|| Stream : "belongs to"
    
    Spartan {
        int Id
        string FirstName
        string LastName
        string University
        string Degree
        bool Graduated
        int CourseId
    }
    
    Course {
        int Id
        string Name
        string Trainer
        int StreamId
    }
    
    Stream {
        int Id
        string Name
    }
```

### JSON Examples

#### Spartan Object
```json
{
  "id": 1,
  "firstName": "Michael",
  "lastName": "Johnson",
  "university": "University of Technology",
  "degree": "BSc Computer Science",
  "course": {
    "id": 1,
    "name": "C# Development",
    "trainer": "Alice Johnson",
    "stream": {
      "id": 1,
      "name": "Software Development"
    }
  },
  "graduated": false
}
```

#### Course Object
```json
{
  "id": 1,
  "name": "C# Development",
  "trainer": "Alice Johnson",
  "stream": {
    "id": 1,
    "name": "Software Development"
  }
}
```

#### Stream Object
```json
{
  "id": 1,
  "name": "Software Development"
}
```

## Field Validation Rules

The API enforces validation rules on input fields. Here are the key constraints you need to know:

### Spartan Fields
- **FirstName**: Required, minimum 6 characters, maximum 50 characters
- **LastName**: Required, minimum 6 characters, maximum 50 characters
- **University**: Optional
- **Degree**: Optional
- **Graduated**: Required boolean (true/false)

### Course Fields
- **Name**: Required
- **Trainer**: Required

### Stream Fields
- **Name**: Required

> **Important**: Always use realistic names that meet the minimum length requirements. For example, use "Jennifer" instead of "Jane", or "Alexander" instead of "Alex".

## Common Use Cases

### Scenario 1: Register a New Student
```bash
# 1. Get authentication token
curl -X POST http://localhost:5125/Auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "sparta", "password": "global"}'

# 2. Create the new student
curl -X POST http://localhost:5125/api/Spartans \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Alexander",
    "lastName": "Anderson",
    "university": "City University",
    "degree": "BSc Computer Science",
    "course": {
      "name": "Python Development",
      "trainer": "Mike Wilson",
      "stream": {
        "name": "Data Science"
      }
    },
    "graduated": false
  }'
```

### Scenario 2: Mark a Student as Graduated
```bash
# 1. Get the student's current information
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans/1

# 2. Update the student's graduation status
curl -X PUT http://localhost:5125/api/Spartans/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "firstName": "Michael",
    "lastName": "Johnson",
    "university": "University of Technology",
    "degree": "BSc Computer Science",
    "course": {
      "name": "C# Development",
      "trainer": "Alice Johnson",
      "stream": {
        "name": "Software Development"
      }
    },
    "graduated": true
  }'
```

### Scenario 3: Get All Students in a Specific Course
```bash
# 1. Get all Spartans
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans

# 2. Filter results on client side or use the data to find specific course students
```

## Troubleshooting

### Common Issues and Solutions

#### 1. 401 Unauthorized Error
```json
{
  "error": "Unauthorized"
}
```
**Solution**: You need to include a valid JWT token in your request.
```bash
# Make sure you include the Authorization header
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" http://localhost:5125/api/Spartans
```

#### 2. 400 Bad Request Error
```json
{
  "error": "Bad Request"
}
```
**Solution**: Check your JSON syntax and required fields.
```bash
# Make sure your JSON is valid
curl -X POST http://localhost:5125/api/Spartans \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Michael",
    "lastName": "Johnson",
    "course": {
      "name": "C# Development",
      "trainer": "Alice Johnson",
      "stream": {
        "name": "Software Development"
      }
    },
    "graduated": false
  }'
```

#### 3. 404 Not Found Error
```json
{
  "error": "Not Found"
}
```
**Solution**: The resource you're looking for doesn't exist.
```bash
# Check if the ID exists
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:5125/api/Spartans/999  # This ID might not exist
```

#### 4. Server Connection Error
```
curl: (7) Failed to connect to localhost port 5125
```
**Solution**: Make sure the API server is running.
```bash
cd SpartaAcademyAPI
dotnet run
```

#### 5. JSON Parsing Error
```json
{
  "error": "Invalid JSON format"
}
```
**Solution**: Validate your JSON using a JSON validator or check for:
- Missing commas
- Unclosed brackets
- Incorrect quotes

#### 6. Field Validation Errors (400 Bad Request with validation details)
```json
{
  "errors": {
    "FirstName": ["The field FirstName must be a string with a minimum length of 6 and a maximum length of 50."],
    "LastName": ["The field LastName must be a string with a minimum length of 6 and a maximum length of 50."]
  },
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "traceId": "00-1c09e089cbd0fa5110c515003bfb2549-8ee4efb4de05e50c-00"
}
```
**Solution**: These errors are actually very helpful! They tell you exactly which fields are invalid and what the requirements are. Check the [Field Validation Rules](#field-validation-rules) section for all constraints.

**Example - This will fail:**
```bash
curl -X POST http://localhost:5125/api/Spartans \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",     # Too short! Needs 6+ characters
    "lastName": "Doe",       # Too short! Needs 6+ characters
    "course": { ... }
  }'
```

**Example - This will work:**
```bash
curl -X POST http://localhost:5125/api/Spartans \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jennifer", # 8 characters ✓
    "lastName": "Williams",  # 8 characters ✓
    "course": { ... }
  }'
```

### HTTP Status Codes Explained

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **204 No Content**: Request successful, no data returned
- **400 Bad Request**: Invalid request format
- **401 Unauthorized**: Authentication required
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

## Additional Resources

### Useful Tools

1. **Postman**: GUI tool for testing APIs
   - Download: https://www.postman.com/downloads/
   - Import the API collection for easy testing

2. **curl**: Command-line tool for HTTP requests
   - Pre-installed on most systems
   - Great for automation and scripting

3. **jq**: Command-line JSON processor for pretty printing
   - Install: `brew install jq` (macOS) or `apt-get install jq` (Linux)
   - Pipe curl output through jq for formatted JSON: `curl ... | jq '.'`

4. **JSON Formatter**: Validate and format JSON
   - Online tool: https://jsonformatter.org/

5. **Swagger UI**: Interactive API documentation
   - Access at: http://localhost:5125/swagger (when server is running)

### Learning Resources

- **REST API Basics**: https://restfulapi.net/
- **HTTP Methods**: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
- **JSON Format**: https://www.json.org/json-en.html
- **JWT Introduction**: https://jwt.io/introduction/

### Contact and Support

If you encounter issues or have questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the API documentation at `/swagger`
3. Contact the development team

---

## Docker Deployment (Optional)

### Containerising the API

You can also run the API using Docker. To do so, follow these steps:

1. **Download Docker Desktop**: https://www.docker.com/products/docker-desktop/

2. **Build the Docker image**:
```bash
docker build -t spartaacademyapi .
```

3. **Run the container**:
```bash
docker run -d -p 8080:8080 -p 8081:8081 spartaacademyapi
```

4. **Access the API**: Open http://localhost:8080/

### Stopping the Container

1. **List running containers**:
```bash
docker ps
```

2. **Stop the container**:
```bash
docker stop <container_id_or_name>
```

3. **Remove the container** (optional):
```bash
docker rm <container_id_or_name>
```

---

**Happy coding! 🚀**

Remember: APIs are just tools to help different applications communicate. Don't be afraid to experiment and learn!