# Receipts - Price Comparison iOS App

![image](https://github.com/user-attachments/assets/390ebc6b-0981-4a37-9f39-56281ccf40f2)


## Project Overview
Receipts is an iOS application developed to help expatriates and locals track and compare prices across different stores in Spain. The app streamlines the process of price comparison by automatically scanning and processing receipt data, enabling users to make informed purchasing decisions.

## Technical Stack
- **Platform**: iOS (iPhone)
- **Programming Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Storage**: Core Data with iCloud synchronization
- **Machine Learning**: Core ML and Vision framework for receipt scanning
- **Development Tools**: Xcode, App Store Connect

## Key Features
- **Intelligent Receipt Scanning**: Implemented receipt scanning functionality using Core ML and Vision framework for text recognition and data extraction
- **Smart Data Processing**: Developed custom heuristics algorithms for identifying and categorizing receipt data based on text position and content
- **Cross-Device Synchronization**: Integrated iCloud synchronization for seamless data access across multiple iOS devices
- **Data Management**: 
  - Historical receipt viewing and management
  - Manual data correction capabilities
  - Filtering by stores and product types
- **User-Friendly Interface**: Built entirely with SwiftUI, providing a modern and responsive user experience

## Technical Challenges & Solutions
- **Machine Learning Integration**:
  - Implemented debug visualization system for Core ML output
  - Created sophisticated geometric heuristics for accurate data extraction
  - Developed algorithms to interpret raw text location data into meaningful receipt information

- **SwiftUI Navigation**: Successfully tackled early SwiftUI navigation challenges through iterative development and testing, implementing a robust navigation system despite framework limitations

- **Data Synchronization**: Optimized Core Data model to comply with iCloud synchronization requirements, implementing a simplified yet effective data structure

- **App Store Deployment**: Successfully navigated the complete iOS app deployment pipeline, including:
  - Certificate management
  - Provisioning profile setup
  - App Store submission requirements
  - Marketing material preparation

## Learning Outcomes
This project served as a comprehensive learning experience in iOS development, covering:
- Modern iOS architecture patterns
- Machine learning integration in mobile applications
- Data persistence and cloud synchronization
- App Store publication process
- SwiftUI implementation strategies
- Real-world problem-solving through software development

## Development Philosophy
The project emphasized using first-party Apple technologies and frameworks (SwiftUI, Core Data, Core ML) to ensure optimal integration with the iOS ecosystem while maintaining high performance and reliability.
