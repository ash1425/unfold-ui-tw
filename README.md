 MOdify AWS Amplify build settings to exppose env variables

build:
commands:
- env | grep -e CONTENTFUL_TOKEN >> .env.production
- yarn run build