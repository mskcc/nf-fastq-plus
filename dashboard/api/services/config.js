const properties = {
    'base': {
    },
    'dev': {
        lims_api: 'https://tango.mskcc.org:8443/LimsRest',
        lims_usr: 'pms',
        lims_pwd: 'tiagostarbuckslightbike'
    },
    'qa': {
        lims_api: 'https://igolims.mskcc.org:8443/LimsRest',
        lims_usr: 'pms',
        lims_pwd: 'tiagostarbuckslightbike'
    },
    'prod': {
        lims_api: 'https://igolims.mskcc.org:8443/LimsRest',
        lims_usr: 'pms',
        lims_pwd: 'tiagostarbuckslightbike'
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
