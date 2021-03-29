const properties = {
    'base': {
    },
    'dev': {
        api: ''
    },
    'qa': {
        api: ''
    },
    'prod': {
        api: ''
    }
};

const env = process.env.REACT_APP_ENV.toLowerCase();
const config = Object.assign( properties.base, properties[ env ] ); // REACT_APP_ENV=dev => 'dev'
if(env !== 'prod'){
    console.log(`${env} ENVIRONMENT: ${JSON.stringify(config)}`);
}
export const BACKEND=config.api;
