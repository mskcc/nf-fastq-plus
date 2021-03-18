import axios from 'axios';

const getData = (resp) => {
    const data = resp.data || {};
    return data;
};

export function getEvents() {
    return axios
        .get('http://localhost:3221/api/nextflow/get-pipeline-update')
        .then(resp =>  getData(resp))
        .catch(error => {throw new Error('Unable to get Get Events: ' + error) });
}
