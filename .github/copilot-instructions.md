Dont explain your procedure.
Use PowerShell best practices for writing scripts and modules.
Use PowerShell 5.1 features where applicable.
Use descriptive variable names and comments to enhance code readability.
In help documentation, follow the standard format for PowerShell comment-based help, and make sure to include examples, and description of the function should be clear and concise, and at least 40 characters long.
Use `Should` and `Assert-MockCalled` for testing to ensure that the code behaves as expected.
Use `InModuleScope` for testing private functions to ensure that the module's context is preserved
Follow the module structure and naming conventions.
Ensure all public functions are documented with comment-based help.
Use consistent indentation and formatting throughout the codebase.
In Pester tests create them one by one with a number for each test and test them one by one until you have 86% code coverage.
Use `Mock` to simulate external dependencies in tests.
