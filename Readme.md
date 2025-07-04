# FPL Assistant - AI-Powered Fantasy Premier League Helper

An intelligent AWS-based system that provides personalized Fantasy Premier League recommendations using machine learning and AI.

## 🎯 Project Goals

This project demonstrates AWS services including:
- **EC2**: Web application hosting and data processing
- **Serverless**: Lambda functions for data collection and analysis
- **Pipelines**: CI/CD deployment automation
- **AI/ML**: SageMaker models and Amazon Bedrock for recommendations

## 🏗️ Architecture

- **Data Collection Layer**: EC2 + Lambda for gathering FPL data
- **AI/ML Processing**: SageMaker models for player performance prediction
- **API Layer**: API Gateway + Lambda for serving recommendations
- **Web Application**: React frontend hosted on EC2
- **CI/CD Pipeline**: CodePipeline for automated deployments

## 🚀 Quick Start

### Prerequisites
- AWS Account
- AWS CloudShell access (or AWS CLI configured locally)

### Deployment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/fpl-assistant.git
   cd fpl-assistant
   ```

2. **Deploy infrastructure:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh deploy
   ```

3. **Access your resources:**
   - The script will output your EC2 instance IP and connection details
   - SSH into your instance to start development

### File Structure
```
fpl-assistant/
├── infrastructure.yaml    # CloudFormation template
├── deploy.sh             # Deployment script
├── src/                  # Application source code (coming soon)
├── lambda/               # Lambda function code (coming soon)
├── ml-models/            # SageMaker model code (coming soon)
└── docs/                 # Documentation
```

## 📊 Features (Planned)

- **Player Performance Prediction**: ML models to predict player points
- **Transfer Recommendations**: AI-powered transfer suggestions
- **Captain Selection**: Optimal captaincy choices
- **Price Change Alerts**: Notifications for player price movements
- **Team Analysis**: Compare your team against optimal lineups

## 🛠️ Technology Stack

- **Frontend**: React.js
- **Backend**: Node.js/Python
- **Database**: DynamoDB
- **Storage**: S3
- **Compute**: EC2, Lambda
- **AI/ML**: SageMaker, Amazon Bedrock
- **Infrastructure**: CloudFormation
- **CI/CD**: AWS CodePipeline

## 📈 Development Phases

- [x] **Phase 1**: Basic Infrastructure Setup
- [ ] **Phase 2**: Data Collection & Storage
- [ ] **Phase 3**: ML Model Development
- [ ] **Phase 4**: Web Application
- [ ] **Phase 5**: CI/CD Pipeline
- [ ] **Phase 6**: Advanced AI Features

## 🤝 Contributing

This is a learning project, but suggestions and improvements are welcome!

## 📝 License

MIT License - see LICENSE file for details

## 🔗 Resources

- [Fantasy Premier League API](https://fantasy.premierleague.com/api/bootstrap-static/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [SageMaker Examples](https://github.com/aws/amazon-sagemaker-examples)

---

*This project is for educational purposes and demonstrates AWS cloud architecture patterns.*
