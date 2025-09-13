# Simple Note

Simple Note is a full-stack note-taking application featuring a Django REST Framework backend and a native iOS client built with SwiftUI. It allows users to create, manage, and synchronize their notes seamlessly between their device and the server, with offline support.

## Features

-   **User Authentication**: Secure user registration, login, and password management using JWT.
-   **CRUD Operations**: Full create, read, update, and delete functionality for notes.
-   **Bulk Operations**: Efficiently create multiple notes in a single request.
-   **Offline Support**: Utilizes SwiftData for local persistence, allowing users to view and edit notes even without an internet connection.
-   **Automatic Synchronization**: Notes are automatically synchronized between the local device and the remote server when a connection is available.
-   **Advanced Filtering**: Server-side filtering of notes by title, description, and date.
-   **Modern iOS UI**: A clean and intuitive user interface built entirely with SwiftUI, following modern design principles.
-   **API Documentation**: Auto-generated API documentation available via Swagger UI and Redoc.

## Architecture

The project is divided into two main components: a backend server and a frontend iOS application.

-   **Backend**:
    -   **Framework**: Django REST Framework
    -   **Database**: PostgreSQL
    -   **Authentication**: `djangorestframework-simplejwt` for token-based authentication.
    -   **API Schema**: `drf-spectacular` for generating OpenAPI 3 schemas.
    -   **Containerization**: Docker and Docker Compose for easy setup and deployment.

-   **Frontend (iOS)**:
    -   **UI Framework**: SwiftUI
    -   **Data Persistence**: SwiftData for local database management and offline support.
    -   **Concurrency**: Swift Concurrency (`async/await`) for handling asynchronous operations.
    -   **Networking**: Combine framework and URLSession for making API requests.
    -   **Architecture**: MVVM (Model-View-ViewModel) with a Repository pattern for data handling.

## Getting Started

### Prerequisites

-   **Backend**: Docker and Docker Compose
-   **Frontend**: macOS with Xcode installed

### Backend Setup

The backend is containerized using Docker, making the setup process straightforward.

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Create an environment file:**
    Create a file named `.env` in the `backend` directory and add the following configuration. Replace the placeholder values with your desired database credentials.

    ```env
    POSTGRES_DB=simplenote_db
    POSTGRES_USER=your_username
    POSTGRES_PASSWORD=your_password

    # Optional: For development, you can enable debug mode
    # DEBUG=True
    # ALLOWED_HOSTS=localhost,127.0.0.1
    ```

3.  **Build and run the containers:**
    ```bash
    docker-compose up --build
    ```

The backend server will be running at `http://localhost:8000`. Migrations are applied automatically on startup.

-   **API Access**: The API is available at `http://localhost:8000/api/`. If you want to use the provided service, you can replace the URL `http://localhost:8000/api/` in `NoteService` and `AuthService` with `https://simple.darkube.app/api/`!
-   **API Documentation**:
    -   Swagger UI: `http://localhost:8000/api/schema/swagger-ui/`
    -   Redoc: `http://localhost:8000/api/schema/redoc/`

### iOS Frontend Setup

1.  **Ensure the backend server is running.**

2.  **Open the Xcode project:**
    Navigate to the `src` directory and open the `SimpleNote.xcodeproj` file with Xcode.

    ```bash
    open src/SimpleNote.xcodeproj
    ```

3.  **Run the app:**
    Select an iOS simulator or a connected physical device and press the "Run" button (or `Cmd+R`). The app will launch and connect to the local backend server.

## Project Structure

```
.
├── backend/          # Django REST Framework application
│   ├── SimpleNote/   # Core project settings and configuration
│   ├── authentication/ # User authentication, registration, and profile management
│   ├── core/         # Core utilities like custom error handling
│   ├── notes/        # CRUD operations, filtering, and management of notes
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── src/              # iOS SwiftUI application
    ├── SimpleNote/
    │   ├── Models/       # Data models (SwiftData and remote API)
    │   ├── Views/        # SwiftUI views for each screen
    │   ├── ViewModels/   # Business logic and state management
    │   ├── Services/     # API communication (AuthService, NoteService)
    │   ├── Repositories/ # Data synchronization logic (NoteRepository)
    │   └── Assets.xcassets/
    └── SimpleNote.xcodeproj
