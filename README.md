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
│   ├── database.py
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── id_generator.py
│   ├── main.py
│   ├── oauth.py
│   ├── passwords.py
│   ├── requirements.txt
│   └── users.py
├── backend/
│   ├── auth.py
│   ├── crud.py
│   ├── database.py
│   ├── Dockerfile
│   ├── fonts
│   │   └── Inter-Bold.ttf
│   ├── image_generation.py
│   ├── images.py
│   ├── main.py
│   ├── models.py
│   ├── pyproject.toml
│   ├── requirements.txt
│   ├── schemas.py
│   ├── sessions.py
│   ├── test_main_groups.py
│   ├── test_main_profiles.py
│   ├── test_main_users.py
│   ├── user_roles.py
│   └── validations.py
├── flutter_application/
│   ├── analysis_options.yaml
│   ├── env.example
│   ├── gitignore
│   ├── lib/
│   │   ├── activity_create.dart
│   │   ├── age_data.dart
│   │   ├── background_for_pages.dart
│   │   ├── bars.dart
│   │   ├── challenges_page.dart
│   │   ├── cities.dart
│   │   ├── components/
│   │   │   ├── checkbox_animation.dart
│   │   │   ├── checkered_background.dart
│   │   │   ├── custom_divider.dart
│   │   │   ├── custom_dropdown.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── gradient_button.dart
│   │   │   ├── interests_grid.dart
│   │   │   ├── my_button.dart
│   │   │   ├── my_textfield.dart
│   │   │   ├── optional_image.dart
│   │   │   ├── profile_avatar.dart
│   │   │   ├── save_profile_popup.dart
│   │   │   ├── scroll_button.dart
│   │   │   ├── sign_in_button/
│   │   │   │   ├── mobile.dart
│   │   │   │   ├── README.md
│   │   │   │   ├── stub.dart
│   │   │   │   └── web.dart
│   │   │   ├── sign_in_button.dart
│   │   │   ├── skill_level_slider.dart
│   │   │   ├── square_tile.dart
│   │   │   └── user_selector.dart
│   │   ├── controllers/
│   │   │   ├── backend_service.dart
│   │   │   ├── backend_service_interface.dart
│   │   │   └── health.dart
│   │   ├── create_profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── forgot_password.dart
│   │   ├── friends_page.dart
│   │   ├── home_page.dart
│   │   ├── images/
│   │   │   ├── apple.png
│   │   │   ├── challenge.jpg
│   │   │   ├── google.png
│   │   │   ├── logga.png
│   │   │   └── splash.png
│   │   ├── launch_injector.dart
│   │   ├── leaderboard_page.dart
│   │   ├── main.dart
│   │   ├── midnattsloppet_activity_page.dart
│   │   ├── models/
│   │   │   ├── achievement.dart
│   │   │   ├── activity.dart
│   │   │   ├── challenges.dart
│   │   │   ├── group.dart
│   │   │   ├── group_invite.dart
│   │   │   ├── profile.dart
│   │   │   ├── role.dart
│   │   │   └── user.dart
│   │   ├── my_achievements.dart
│   │   ├── my_list_tile.dart
│   │   ├── profile_page.dart
│   │   ├── settings.dart
│   │   └── views/
│   │       ├── activity_page.dart
│   │       ├── all_group_pages.dart
│   │       ├── edit_group_page.dart
│   │       ├── generic_info_page.dart
│   │       ├── group_creation_page.dart
│   │       ├── group_invitations_page.dart
│   │       ├── group_members.dart
│   │       ├── group_page.dart
│   │       ├── login_page.dart
│   │       ├── map_screen.dart
│   │       ├── my_groups.dart
│   │       ├── schedule_page.dart
│   │       └── sign_up_page.dart
│   ├── .metadata
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── README.md
│   └── test/
│       ├── backend_service_test.dart
│       ├── components/
│       │   ├── custom_text_field_test.dart
│       │   ├── optional_image_test.dart
│       │   ├── skill_level_slider_test.dart
│       │   └── user_selector_test.dart
│       ├── home_page_test.dart
│       ├── README.md
│       ├── views/
│       │   ├── all_group_pages_test.dart_broken
│       │   └── sign_up_page_test.dart
│       └── widget_test.dart
├── .github/
│   └── workflows/
│       ├── authentication_lint.yml
│       ├── backend_lint.yml
│       └── flutter_test.yml
├── .gitignore
├── images/
│   ├── Dockerfile
│   ├── id_generator.py
│   ├── main.py
│   └── requirements.txt
├── LICENSE
├── proxy/
│   ├── Caddyfile
│   └── docker-compose.yaml
├── README.md
└── sessions/
    ├── cryptolib.py
    ├── docker-compose.yaml
    ├── Dockerfile
    ├── id_generator.py
    ├── main.py
    ├── requirements.txt
    ├── schemas.py
    └── utils.py
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

