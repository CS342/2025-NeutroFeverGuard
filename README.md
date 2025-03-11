<!--

This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# NeutroFeverGuard

[![Beta Deployment](https://github.com/CS342/2025-NeutroFeverGuard/actions/workflows/beta-deployment.yml/badge.svg)](https://github.com/CS342/2025-NeutroFeverGuard/actions/workflows/beta-deployment.yml)
[![codecov](https://codecov.io/gh/CS342/2025-NeutroFeverGuard/graph/badge.svg?token=2eHfa9JRjS)](https://codecov.io/gh/CS342/2025-NeutroFeverGuard)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14740617.svg)](https://doi.org/10.5281/zenodo.14740617)


This repository contains the NeutroFeverGuard application.
NeutroFeverGuard is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).

> [!TIP]
> Do you want to test the NeutroFeverGuard application on your device? [You can download it on TestFlight](https://testflight.apple.com/join/CAuYHs84).

## Overview
**NeutroFeverGuard** is designed to monitor symptoms of chemotherapy patients and enable early detection of febrile neutropenia. The app empowers users to:  
1. Record and track vitals, lab values, medications, and symptoms.  
2. Sync data with the Apple Health app and view interactive visualizations of health trends.  
3. Receive reminders for uploading lab results and notifications in case of febrile neutropenia risk.

## Features

Screenshots table:

1. Onboarding Pages
2. Connection to bluetooth
3. Add data page
4. Visualizations page
5. Records page (lab + medications)
6. Symptom Survey 
7. Notifications  
8. Contact Page 
9. Firebase (to show things push there?)

### I. Health Record Tracking

#### Health Data Sources:
1. **Bluetooth-enabled Temperature Sensors**: Users can connect their CORE Temperature Sensor to provide continuous skin temperature data.
2. **Apple Health App**: Data recorded by Apple Watch or Apple Health App via HealthKit.  
3. **Manual Entry**: Users can manually add health data, including vital signs and lab values.

> [!NOTE]  
> How is the data being processed and stored? NeutroFeverGuard use [Spezi Local Storage](https://github.com/StanfordSpezi/SpeziStorage) to store lab results and medication data locally. Other health data is stored in [Healthkit](https://github.com/StanfordSpezi/SpeziHealthKit). For cloud storage, all data is stored as [FHIR](https://github.com/StanfordSpezi/SpeziFHIR) elements on [Firebase](https://github.com/StanfordSpezi/SpeziFirebase).

> [!NOTE]  
> Want to understand how CORE Sensor connection, and continuous temperature data flow work? Check out the detailed explanation in [Working with CORE Sensor - Bluetooth Connection](Documentation/BluetoothSensor.md).

#### Visualization:
Interactive graphs display trends for: heart rate, temperature, oxygen saturation, absolute neutrophil count (ANC). Visuals include trend lines and daily average readings to help users and clinicians better understand health fluctuations.

### II. Notifications & Alerts
1. **Critical Health Alerts:**  
   The app sends immediate alerts if:  
   **Fever Detected in case of Neutropenia:** Elevated body temperature (at or over 101 F once or steady at our over 100.4 F in the past hour), especially when ANC is low (< 500/µL).
   
   Users receive a push notification advising them to seek medical attention.

2. **Lab Results Reminders:**  
   If no lab results are logged for over a week, the app sends a reminder to encourage regular data updates.

3. **Neutropenia Severity Classification:**  
   ANC is automatically calculated based on patient-provided lab values, with severity color codes:  
   - ANC ≥ 500: Normal (Green)
   - 100 ≤ ANC < 500: Severe Neutropenia (Orange)  
   - ANC < 100: Profound Neutropenia (Red)

> [!NOTE]  
> Want to understand how fever monitoring alerts and lab results reminders work in the background? Check out the detailed explanation in [Fever Monitoring & Lab Notifications](Documentation/Notification.md).


## Setup Instructions
Use [TestFlight](https://testflight.apple.com/join/CAuYHs84) to download NeutroFeverGuard. Following the instruction when onboarding: sign the consent form, give permissions to health data and notification, sign up and provide your data. 

Enjoy!

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
