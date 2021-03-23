const properties = {
    'base': {
    },
    'dev': {
        api: 'http://localhost:4500'
    },
    'qa': {
        api: 'https://igodev.mskcc.org/nf-dashboard'
    },
    'prod': {
        api: 'https://igo.mskcc.org/nf-dashboard'
    }
};

const env = process.env.REACT_APP_ENV.toLowerCase();
const config = Object.assign( properties.base, properties[ env ] ); // REACT_APP_ENV=dev => 'dev'
if(env !== 'prod'){
    console.log(`${env} ENVIRONMENT: ${JSON.stringify(config)}`);
}
export const BACKEND=config.api;
