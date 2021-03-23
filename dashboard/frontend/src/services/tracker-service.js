import axios from 'axios';
import { BACKEND } from '../config';

const getData = (resp) => {
    const data = resp.data || {};
    return data;
};

export function getEvents() {
    return axios
        .get(`${BACKEND}/api/nextflow/get-pipeline-update`)
        .then(resp =>  getData(resp))
        .catch(error => {throw new Error('Unable to get Get Events: ' + error); });
}
