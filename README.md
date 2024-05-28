# Group 71 - Lace Up & Lead The Way

## Overview

Lace Up & Lead The Way is a pre-race training app designed to be a companion and social platform for runners interested in running Midnattsloppet. This project is a collaborative effort by group 71 to design and develop a complete mobile app from scratch. The project includes a frontend, UI and a corresponding backend microservice architecture.

## Team Members

- Alfred Berggren — Backend; API development, Database management — [@alfredberggren](https://github.com/alfredberggren)
- [Name] — [Role/Responsibilities] — [github-user]

## Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/)
- **UI Design:** [Figma](https://www.figma.com)
- **Backend:** [FastAPI](https://github.com/tiangolo/fastapi), [SQLAlchemy](https://www.sqlalchemy.org/), [SQLModel](https://github.com/tiangolo/sqlmodel)
- **Database:** [PostgreSQL](https://www.postgresql.org/), [Redis](https://redis.io/)

## Features

- Sign up
  - Passwords are encrypted and safely stored
- Logging in and out
  - Authentication and session handling
- Profiles
  - Each user can create their own profile
  - Profile can be made private
- Groups
  - Users can join or leave them
  - Groups can be private or public
- Activities in groups
  - Can be created by group members
  - Can be scheduled to specific dates
  - Can include planned completion of challenges
- Challenges
  - Can be completed in activities by linking the activity to a certain challenge
  - Example: "Run 2,5km with 100m of elevation change!"
- Achievements
  - Rewarded by completing challenges
  - Or by importing health data from phone
  - Completed achievements will be displayed on users profiles
- Images
  - Ability to upload images to:
    - User profiles
    - Groups
    - Activities
    - and more...
  - Implemented using a microservice connected to S3 Storage
- Sharing
  - Users can share completed achievements or activities
  - The app generates an image specific to each user whenever they complete something
    - This image can be shared to social media (e.g. Instagram or Facebook)
  - Implemented using [Python PIL](https://pypi.org/project/pillow/)

## API Documentation
Documentation of our REST APIs has been generated using [Swagger UI](https://github.com/swagger-api/swagger-ui), through usage of FastAPI, and can be viewed below.

- **Backend:** https://pvt.edt.cx/docs
- **Images:** https://images-pvt.edt.cx/docs

## Project Structure
```bash
dsv-pvt/
├── authentication/
├── backend/
├── flutter_application/
├── .github/
├── .gitignore
├── images/
├── LICENSE
├── proxy/
├── README.md
└── sessions/
```

## Installation and Setup

### Prerequisites

- [List of required software and their versions (e.g. Node.js, Android Studio, Xcode)]

### Installation Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]

## Contributing

We welcome any contributions to the project! Please follow these guidelines:

- Fork the repository and create a new branch for your feature or bug fix.
- Write tests for your changes.
- Submit a pull request describing your changes and why they are needed.

## Screenshots
[Include screenshots or a link to a demo video showcasing your app's UI and functionality.]

## Future enhancements
- Friend list
- Reward system
- Displaying groups on a map

## Acknowledgments
- [FastAPI tutorial](https://fastapi.tiangolo.com/tutorial/) for being an excellent resource on API design

## License

Lace Up & Lead The Way is open source and released under the GPL 3.0 license. See [LICENSE](https://github.com/Edwinexd/dsv-pvt/blob/master/LICENSE) for more information.

## Contact

For any questions or concerns, please reach out to [@Edwinexd](https://github.com/Edwinexd) or open an issue in the repository.

