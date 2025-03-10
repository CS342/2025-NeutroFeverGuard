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

1. Visualization page
2. Add data page
3. Lab page
4. Medication page
5. Contact page (?)
6. On boarding page / schedule 

### I. Health Record Tracking

#### Health Data Sources:
1. **Apple Health App**: Data recorded by Apple Watch or other Bluetooth-enabled sensors via HealthKit.  
2. **Manual Entry**: Users can manually add health data, including vital signs and lab values.

> [!NOTE]  
> How is the data being processed and stored? NeutroFeverGuard use [Spezi Local Storage](https://github.com/StanfordSpezi/SpeziStorage) to store lab results and medication data locally. Other health data is stored in [Healthkit](https://github.com/StanfordSpezi/SpeziHealthKit). For cloud storage, data is stored as [FHIR](https://github.com/StanfordSpezi/SpeziFHIR) elements on [Firebase](https://github.com/StanfordSpezi/SpeziFirebase).


#### Visualization:
Interactive graphs display trends for: heart rate, temperature, oxygen saturation, absolute neutrophil count (ANC). Visuals include trend lines and daily average readings to help users and clinicians better understand health fluctuations.

### II. Notifications & Alerts
1. **Critical Health Alerts:**  
   The app sends immediate alerts if:  
   - **Fever Detected:** Elevated body temperature, especially when ANC is low (e.g., < 500/µL).  
   - **Increased Resting Heart Rate:** Heart rate exceeds 100 BPM. 
   
   Users receive a push notification advising them to seek medical attention.

2. **Lab Results Reminders:**  
   If no lab results are logged for over a week, the app sends a reminder to encourage regular data updates.

3. **Neutropenia Severity Classification:**  
   ANC is automatically calculated based on patient-provided lab values, with severity color codes:  
   - ANC ≥ 500: Normal (Green)
   - 100 ≤ ANC < 500: Severe Neutropenia (Orange)  
   - ANC < 100: Profound Neutropenia (Red)

> [!NOTE]  
> Want to understand how background checking and lab results reminders work? Check out the detailed explanation in [Background Checking & Lab Notification](Documentation/Notification.md).


## Setup Instructions
Use [TestFlight](https://testflight.apple.com/join/CAuYHs84) to download NeutroFeverGuard. Following the instruction when onboarding: sign the consent form, give permissions to health data and notification, sign up and provide your data. 

Enjoy!

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
