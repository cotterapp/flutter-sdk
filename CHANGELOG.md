# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-nullsafety.1] - 2021-05-25

### Changed

- Fixes faulty type casts. Thanks to @tonyf for the PR.

## [0.2.0-nullsafety.0] - 2021-04-01

### Changed

- **BREAKING CHANGE**: Introduce null-safety
- Update dependencies to be null safe

## [0.1.3] - 2021-02-25

### Changed

- Update dependencies

## [0.1.2] - 2020-10-19

### Changed

- Fix refresh token URL to have prefix of `:company_id`.

## 0.1.1 - 2020-08-19

### Changed

- Fix in-app browser on Android for sign in with email and phone number.

## 0.1.0 - 2020-06-20

### Added

- Implement sign in with email and phone number.

## 0.0.2 - 2020-06-11

### Changed

- Fix `signInWithDevice` error handling.

## 0.0.1 - 2020-06-08

### Added

- Implement signing up and signing in with device.
- Add functionality to store and retrieve signed-in user information.
- Add functionality to store and retrieve oauth tokens and automatically refresh them.

[0.1.2]: https://github.com/cotterapp/flutter-sdk/compare/v0.1.1...v0.1.2
[0.1.3]: https://github.com/cotterapp/flutter-sdk/compare/v0.1.2...v0.1.3
