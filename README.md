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

## User Interface and Key Features
| Onboarding | Dashboard | Adding Data Manually |
|----------|----------|----------|
| ![](./Documentation/Images/onboarding.PNG#gh-light-mode-only) ![](./Documentation/Images/onboarding~dark.PNG#gh-dark-mode-only) | ![](./Documentation/Images/dashboard.PNG#gh-light-mode-only) ![](./Documentation/Images/dashboard~dark.PNG#gh-dark-mode-only) | ![](./Documentation/Images/adddata.PNG#gh-light-mode-only) ![](./Documentation/Images/adddata~dark.PNG#gh-dark-mode-only) |


| View Records | Connect to Sensor | Contact Care Provider |
|----------|----------|----------|
| ![](./Documentation/Images/lab.PNG#gh-light-mode-only)![](./Documentation/Images/lab~dark.PNG#gh-dark-mode-only) | ![](./Documentation/Images/bluetooth.PNG#gh-light-mode-only) ![](./Documentation/Images/bluetooth~dark.PNG#gh-dark-mode-only) | ![](./Documentation/Images/contacts.PNG#gh-light-mode-only) ![](./Documentation/Images/contacts~dark.PNG#gh-dark-mode-only) |


### I. Health Record Tracking

1. **Health Data Sources:**
- **Bluetooth-enabled Temperature Sensors**: Users can connect their [CORE Temperature Sensor](https://corebodytemp.com/) to provide continuous skin temperature data.
-  **Apple Health App**: Data recorded by Apple Watch or Apple Health App via HealthKit, including skin temperature, heart rate, and oxygen saturation.  
-  **Manual Entry**: Users can manually add health data, including vitals, lab values, medications, symptoms, and the [MASCC (Multinational Association for Supportive Care in Cancer) Risk Index](https://www.mdcalc.com/calc/3913/mascc-risk-index-febrile-neutropenia).

> [!NOTE]  
> How is the data being processed and stored? NeutroFeverGuard use [Spezi Local Storage](https://github.com/StanfordSpezi/SpeziStorage) to store lab results and medication data locally. Other health data is stored in [Healthkit](https://github.com/StanfordSpezi/SpeziHealthKit). For cloud storage, all data is stored as [FHIR](https://github.com/StanfordSpezi/SpeziFHIR) elements on [Firebase](https://github.com/StanfordSpezi/SpeziFirebase).

> [!NOTE]  
> Want to understand how CORE Sensor connection, and continuous temperature data flow work? Check out the detailed explanation in [Working with CORE Sensor - Bluetooth Connection](Documentation/BluetoothSensor.md).

2. **Visualization:**
    Interactive graphs display trends for: heart rate, temperature, oxygen saturation and absolute neutrophil count. Visuals include trend lines and daily average readings to help users and clinicians better understand health fluctuations. Data is automatically loaded and read from HealthKit.

### II. Notifications & Alerts
1. **Critical Health Alerts:**  
   The app sends immediate alerts if
   **Fever Detected in case of Neutropenia,** defined as an elevated body temperature (≥101°F once or sustained at ≥100.4°F over the past hour), when ANC is low (<500 cells/µL). ([Definition Source](https://www.uptodate.com/contents/diagnostic-approach-to-the-adult-cancer-patient-with-neutropenic-fever))
   
   Users will receive a push notification advising them to seek medical attention.

2. **Lab Results Reminders:**  
   If no lab results are logged for over a week, the app sends a reminder to encourage regular data updates.

> [!NOTE]  
> Want to understand how fever monitoring alerts and lab results reminders work in the background? Check out the detailed explanation in [Fever Monitoring & Lab Notifications](Documentation/Notification.md).

3. **Neutropenia Severity Classification:**  
   ANC is automatically calculated based on patient-provided lab values, with severity color codes ([Definition Source](https://www.uptodate.com/contents/diagnostic-approach-to-the-adult-cancer-patient-with-neutropenic-fever), unit: cells/µL):  
   - ANC ≥ 500: Normal (Green)
   - 100 ≤ ANC < 500: Severe Neutropenia (Orange)  
   - ANC < 100: Profound Neutropenia (Red)

4. **MASCC Risk Index:**
   Users & providers together can fill out a survey for the [MASCC Risk Index](https://www.mdcalc.com/calc/3913/mascc-risk-index-febrile-neutropenia), a validated clinical survey for whether a patient is at high risk for febrile neutropenia-related complications. The patient will receive a warning to seek immediate medical attention if they are at high risk, or will be notified to continue monitoring their symptoms if they are at low risk.
   
5. **Symptoms Warnings:**
   When a users fills out the symptoms form, they will be prompted to rate their symptoms on a scale of 1-10. If they rate a symptom between 4-6, they will receive a warning regarding a moderate severity symptom; if 7+, they will receive a warning regarding a high severity symptom.
   Note: These thresholds were arbitrarily determined and can be modified as seen fit.


## User Instructions
1. **Setup:** Use [TestFlight](https://testflight.apple.com/join/CAuYHs84) to download NeutroFeverGuard. Following the instruction when onboarding: sign the consent form, give permissions to health data and notification, sign up and provide your data. 
2. **Connect to Sensor:** If you have a CORE Sensor, make sure your sensor and bluetooth is on, go to Connect tab and our app will automatically connect, read and save your body temperature data through the CORE Sensor. If you don't have this sensor, this page will suggest you to add your data manually.
3. **Dashboard:** Visualize your heart rate, body temperature, and oxygen saturation trends. The data syncs with the Health app, including readings from Bluetooth sensors and manual entries. Click on each scatter plot data to see a summary of what day it was recorded on and what the average, minimum, and maximum values for that measurement that day was. Note that the Apple Watch doesn’t measure absolute body temperature continuously, only [nightly wrist temperature](https://support.apple.com/en-us/102674), which isn’t supported. For body temperature, you can use the [CORE sensor](https://corebodytemp.com/) or other sensors/apps that push body temperature data to Apple Health app.
4. **Add Data:** Manually log health metrics, including temperature, heart rate, oxygen saturation, and blood pressure — these will also sync to the Health app. You can record lab results for neutropenia-related tests, track medication intake with timestamps, log symptoms like nausea or fatigue, and take MASCC Risk Index survey.
5. **Records:** View past entries in two tabs — Lab Results and Medications. The Lab Results tab shows your latest Absolute Neutrophil Count (ANC) and provides a detailed history where you can view and delete records. In the Medications tab, you can view, edit, or delete your medication logs.

Enjoy!

## Future Improvements

- **Manual data entry validation:** While our manual data entry feature warns users against entering invalid values (e.g., negative blood pressure), it still accepts unrealistic values (e.g., heart rate of 300 bpm). This validation should be improved in future iterations, and [SpeziValidation](https://github.com/StanfordSpezi/SpeziViews/tree/main/Sources/SpeziValidation) can be used.
- **Real-Time data issues with HealthKit when the App is not in the foreground:** As discussed with the Apple Health Research Team, retrieving real-time data from HealthKit while the app is in the background is inconsistent, which is a known issue on their end. Currently, the app receives near-real-time updates even if it is not in the foreground, with HealthKit pushing data approximately once per hour. To enable truly real-time fever monitoring when the app is not in the foreground, the system could query locally stored Bluetooth data instead of relying on HealthKit observer queries.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

## Team and Contributions

Please see [team and contribution details](/Documentation/CONTRIBUTORS.md) for more information.

## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
