# RaceDay – API Endpoint Plan

## Authentication Endpoints (Public)

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/auth/register` | Register a new user | None | `{ "email", "password", "firstName", "lastName", "role" }` | 201 Created – user details <br> 400 Bad Request |
| POST | `/api/auth/login` | Authenticate and return JWT token | None | `{ "email", "password" }` | 200 OK – `{ "token", "user" }` <br> 401 Unauthorized |

## User Profile Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/users/me` | Get current user's profile | Any (logged-in) | None | 200 OK – user object |
| PUT | `/api/users/me` | Update current user's profile | Any (logged-in) | `{ "firstName", "lastName" }` | 200 OK – updated user |

## Event Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/events` | Get all events | None (public) | None | 200 OK – array of events |
| GET | `/api/events/{id}` | Get event details with categories | None (public) | None | 200 OK – event with categories <br> 404 Not Found |
| POST | `/api/events` | Create a new event | Organiser | `{ "name", "description", "date", "location", "maxParticipants", "eventTypeId", "status" }` | 201 Created <br> 400 Bad Request |
| PUT | `/api/events/{id}` | Update an event | Organiser (owner) | Same as POST | 200 OK <br> 403 Forbidden |
| DELETE | `/api/events/{id}` | Delete an event | Organiser (owner) | None | 204 No Content |

## Category Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/events/{eventId}/categories` | Get categories for an event | None (public) | None | 200 OK – array of categories |
| POST | `/api/events/{eventId}/categories` | Add a category to an event | Organiser (owner) | `{ "name", "description", "fee" }` | 201 Created <br> 403 Forbidden |
| PUT | `/api/categories/{id}` | Update a category | Organiser (owner) | `{ "name", "description", "fee" }` | 200 OK |
| DELETE | `/api/categories/{id}` | Delete a category | Organiser (owner) | None | 204 No Content |

## Enrolment Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/events/{eventId}/enrol` | Enrol in an event | Participant | `{ "categoryId" }` | 201 Created <br> 400 Bad Request |
| GET | `/api/users/me/enrolments` | Get user's enrolments | Participant | None | 200 OK – array of enrolments |
| GET | `/api/events/{eventId}/enrolments` | Get event enrolments | Organiser (owner) | None | 200 OK – array of enrolments |
| PUT | `/api/enrolments/{id}/cancel` | Cancel an enrolment | Participant or Organiser | None | 200 OK – updated enrolment |

## Result Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/enrolments/{enrolmentId}/result` | Add/update a result | Organiser (owner) | `{ "finishTime", "position", "categoryPosition", "status" }` | 201 Created / 200 OK |
| GET | `/api/events/{eventId}/results` | Get event results | None (public) | None | 200 OK – array of results |
| GET | `/api/users/me/results` | Get user's results history | Participant | None | 200 OK – array of results |