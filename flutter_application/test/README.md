# Generated tests
## Process
Most unit tests have been partially or fully been generated with the use of large language models. Prompting consisted of relevant code from each widget and/or component and were then iteratively refined by providing compilation errors and/or test failures that should pass.

All tests have been reviewed by at least two project members (the developer and one or more reviewers before merging).

## Human Involvement
While a lot of work could be automated, there were a lot of problems related to interaction between components which context llms couldn't understand. Issues that required significant human involvement included:
- Framework for backend service mocking
- Expected behaviors (e.x. concept of fuzzy matching for searches)
- Code generalization / refactoring
- Which components to test

## Test Coverage
Far from all widgets and components have been tested. Effort and time was primarly put into components that had computational logic. Testing of views/actual pages is limited due to most of their logic being fetching data from the backend which is tested in backend service tests anyway.
