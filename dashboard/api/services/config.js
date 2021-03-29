const properties = {
    'base': {
    },
    'dev': {
        lims_api: '',
        lims_usr: '',
        lims_pwd: ''
    },
    'qa': {
        lims_api: '',
        lims_usr: '',
        lims_pwd: ''
    },
    'prod': {
        lims_api: '',
        lims_usr: '',
        lims_pwd: ''
    }
};

const env = process.env.NODE_ENV.toLowerCase();
const config = Object.assign( properties.base, properties[ env ] ); // REACT_APP_ENV=dev => 'dev'
if(env !== 'prod'){
    console.log(`${env} ENVIRONMENT: ${JSON.stringify(config)}`);
}
exports.LIMS_API=config.lims_api;
exports.LIMS_USR=config.lims_usr;
exports.LIMS_PWD=config.lims_pwd;
